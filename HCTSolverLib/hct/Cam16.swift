//
//  ColorUtils.swift
//  ColorPallete
//
//  Created by M Arman on 22/11/22.
//

import Foundation

class Cam16 {
    private init(hue: Double, chroma: Double, j: Double, q: Double, m: Double, s: Double, jstar: Double, astar: Double, bstar: Double) {
        self.hue = hue
        self.chroma = chroma
        self.j = j
        self.q = q
        self.m = m
        self.s = s
        self.jstar = jstar
        self.astar = astar
        self.bstar = bstar
    }

    static let XYZ_TO_CAM16RGB: [[Double]] = [
        [0.401288, 0.650173, -0.051461],
        [-0.250268, 1.204414, 0.045854],
        [-0.002079, 0.048952, 0.953127],
    ]

    // Transforms 'cone'/'RGB' responses in CAM16 to XYZ color space coordinates.
    static let CAM16RGB_TO_XYZ: [[Double]] = [
        [1.8620678, -1.0112547, 0.14918678],
        [0.38752654, 0.62144744, -0.00897398],
        [
            -0.01584150, -0.03412294, 1.0499644,
        ],
    ]

    // CAM16 color dimensions, see getters for documentation.
    private let hue: Double
    private let chroma: Double
    
    func getHue()->Double {
        return hue
    }
    
    func getChroma()->Double {
        return chroma
    }
    
    private let j: Double
    private let q: Double
    private let m: Double
    private let s: Double

    // Coordinates in UCS space. Used to determine color distance, like delta E equations in L*a*b*.
    private let jstar: Double
    private let astar: Double
    private let bstar: Double

    public static func fromInt(_ argb: Int) -> Cam16 {
        return fromIntInViewingConditions(argb: argb, viewingConditions: ViewingConditions.DEFAULT)
    }

    static func fromIntInViewingConditions(argb: Int, viewingConditions: ViewingConditions) -> Cam16 {
        // Transform ARGB int to XYZ
        let red = (argb & 0x00FF0000) >> 16
        let green = (argb & 0x0000FF00) >> 8
        let blue = (argb & 0x000000FF)
        let redL = ColorUtils.linearized(red)
        let greenL = ColorUtils.linearized(green)
        let blueL = ColorUtils.linearized(blue)
        let x = 0.41233895 * redL + 0.35762064 * greenL + 0.18051042 * blueL
        let y = 0.2126 * redL + 0.7152 * greenL + 0.0722 * blueL
        let z = 0.01932141 * redL + 0.11916382 * greenL + 0.95034478 * blueL

        // Transform XYZ to 'cone'/'rgb' responses
        let matrix = XYZ_TO_CAM16RGB
        let rT = (x * matrix[0][0]) + (y * matrix[0][1]) + (z * matrix[0][2])
        let gT = (x * matrix[1][0]) + (y * matrix[1][1]) + (z * matrix[1][2])
        let bT = (x * matrix[2][0]) + (y * matrix[2][1]) + (z * matrix[2][2])

        // Discount illuminant
        let rD = viewingConditions.getRgbD()[0] * rT
        let gD = viewingConditions.getRgbD()[1] * gT
        let bD = viewingConditions.getRgbD()[2] * bT

        // Chromatic adaptation
        let rAF = pow(viewingConditions.getFl() * abs(rD) / 100.0, 0.42)
        let gAF = pow(viewingConditions.getFl() * abs(gD) / 100.0, 0.42)
        let bAF = pow(viewingConditions.getFl() * abs(bD) / 100.0, 0.42)
        let rA = Double(MathUtils.signum(num: rD)) * 400.0 * rAF / (rAF + 27.13)
        let gA = Double(MathUtils.signum(num: gD)) * 400.0 * gAF / (gAF + 27.13)
        let bA = Double(MathUtils.signum(num: bD)) * 400.0 * bAF / (bAF + 27.13)

        // redness-greenness
        let a = (11.0 * rA + -12.0 * gA + bA) / 11.0
        // yellowness-blueness
        let b = (rA + gA - 2.0 * bA) / 9.0

        // auxiliary components
        let u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0
        let p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0

        // hue
        let atan2 = atan2(b, a)
        let atanDegrees = MathUtils.toDegrees(atan2)
        let hue =
            atanDegrees < 0
                ? atanDegrees + 360.0
                : atanDegrees >= 360 ? atanDegrees - 360.0 : atanDegrees
        let hueRadians = MathUtils.toRadians(hue)

        // achromatic response to color
        let ac = p2 * viewingConditions.getNbb()

        // CAM16 lightness and brightness
        let j =
            100.0
                * pow(
                    ac / viewingConditions.getAw(),
                    viewingConditions.getC() * viewingConditions.getZ())
        let q: Double =
            4.0 / viewingConditions.getC()
                * sqrt(j / 100.0)
                * (viewingConditions.getAw() + 4.0)
                * viewingConditions.getFlRoot()

        // CAM16 chroma, colorfulness, and saturation.
        let huePrime = (hue < 20.14) ? hue + 360 : hue
        let eHue = 0.25 * (cos(MathUtils.toRadians(huePrime) + 2.0) + 3.8)
        let p1 = 50000.0 / 13.0 * eHue * viewingConditions.getNc() * viewingConditions.getNcb()
        let t = p1 * hypot(a, b) / (u + 0.305)
        let alpha =
            pow(1.64 - pow(0.29, viewingConditions.getN()), 0.73) * pow(t, 0.9)
        // CAM16 chroma, colorfulness, saturation
        let c = alpha * sqrt(j / 100.0)
        let m = c * viewingConditions.getFlRoot()
        let s =
            50.0 * sqrt((alpha * viewingConditions.getC()) / (viewingConditions.getAw() + 4.0))

        // CAM16-UCS components
        let jstar = (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j)
        let mstar = 1.0 / 0.0228 * log1p(0.0228 * m)
        let astar = mstar * cos(hueRadians)
        let bstar = mstar * sin(hueRadians)

        return Cam16(hue: hue, chroma: c, j: j, q: q, m: m, s: s, jstar: jstar, astar: astar, bstar: bstar)
    }
}
