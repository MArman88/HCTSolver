//
//  ViewingConditions.swift
//  ColorPallete
//
//  Created by M Arman on 22/11/22.
//

import Foundation

class ViewingConditions {
    /**
     * Parameters are intermediate values of the CAM16 conversion process. Their names are shorthand
     * for technical color science terminology, this class would not benefit from documenting them
     * individually. A brief overview is available in the CAM16 specification, and a complete overview
     * requires a color science textbook, such as Fairchild's Color Appearance Models.
     */
    private init(aw: Double, nbb: Double, ncb: Double, c: Double, nc: Double, n: Double, rgbD: [Double], fl: Double, flRoot: Double, z: Double) {
        self.aw = aw
        self.nbb = nbb
        self.ncb = ncb
        self.c = c
        self.nc = nc
        self.n = n
        self.rgbD = rgbD
        self.fl = fl
        self.flRoot = flRoot
        self.z = z
    }

    /** sRGB-like viewing conditions. */
    static let DEFAULT: ViewingConditions =
        ViewingConditions.make(whitePoint: [
            ColorUtils.whitePointD65()[0],
            ColorUtils.whitePointD65()[1],
            ColorUtils.whitePointD65()[2],
        ],
        adaptingLuminance: 200.0 / Double.pi * ColorUtils.yFromLstar(50.0) / 100.0,
        backgroundLstar: 50.0,
        surround: 2.0,
        discountingIlluminant: false)

    private let aw: Double
    private let nbb: Double
    private let ncb: Double
    private let c: Double
    private let nc: Double
    private let n: Double
    private let rgbD: [Double]
    private let fl: Double
    private let flRoot: Double
    private let z: Double

    func getAw() -> Double {
        return aw
    }

    func getN() -> Double {
        return n
    }

    func getNbb() -> Double {
        return nbb
    }

    func getNcb() -> Double {
        return ncb
    }

    func getC() -> Double {
        return c
    }

    func getNc() -> Double {
        return nc
    }

    func getRgbD() -> [Double] {
        return rgbD
    }

    func getFl() -> Double {
        return fl
    }

    func getFlRoot() -> Double {
        return flRoot
    }

    func getZ() -> Double {
        return z
    }

    /**
     * Create ViewingConditions from a simple, physically relevant, set of parameters.
     *
     * @param whitePoint White point, measured in the XYZ color space. default = D65, or sunny day
     *     afternoon
     * @param adaptingLuminance The luminance of the adapting field. Informally, how bright it is in
     *     the room where the color is viewed. Can be calculated from lux by multiplying lux by
     *     0.0586. default = 11.72, or 200 lux.
     * @param backgroundLstar The lightness of the area surrounding the color. measured by L* in
     *     L*a*b*. default = 50.0
     * @param surround A general description of the lighting surrounding the color. 0 is pitch dark,
     *     like watching a movie in a theater. 1.0 is a dimly light room, like watching TV at home at
     *     night. 2.0 means there is no difference between the lighting on the color and around it.
     *     default = 2.0
     * @param discountingIlluminant Whether the eye accounts for the tint of the ambient lighting,
     *     such as knowing an apple is still red in green light. default = false, the eye does not
     *     perform this process on self-luminous objects like displays.
     */
    static func make(whitePoint: [Double], adaptingLuminance: Double, backgroundLstar: Double, surround: Double, discountingIlluminant: Bool) -> ViewingConditions {
        // Transform white point XYZ to 'cone'/'rgb' responses
        let matrix = Cam16.XYZ_TO_CAM16RGB
        let xyz = whitePoint
        let rW = (xyz[0] * matrix[0][0]) + (xyz[1] * matrix[0][1]) + (xyz[2] * matrix[0][2])
        let gW = (xyz[0] * matrix[1][0]) + (xyz[1] * matrix[1][1]) + (xyz[2] * matrix[1][2])
        let bW = (xyz[0] * matrix[2][0]) + (xyz[1] * matrix[2][1]) + (xyz[2] * matrix[2][2])
        let f = 0.8 + (surround / 10.0)
        let c =
            (f >= 0.9)
                ? MathUtils.lerp(0.59, 0.69, (f - 0.9) * 10.0)
                : MathUtils.lerp(0.525, 0.59, (f - 0.8) * 10.0)
        var d =
            discountingIlluminant
                ? 1.0
                : f * (1.0 - ((1.0 / 3.6) * exp((-adaptingLuminance - 42.0) / 92.0)))
        d = MathUtils.clampDouble(0.0, 1.0, d)
        let nc = f
        let rgbD =
            [
                d * (100.0 / rW) + 1.0 - d, d * (100.0 / gW) + 1.0 - d, d * (100.0 / bW) + 1.0 - d,
            ]

        let k = 1.0 / (5.0 * adaptingLuminance + 1.0)
        let k4 = k * k * k * k
        let k4F = 1.0 - k4
        let fl = (k4 * adaptingLuminance) + (0.1 * k4F * k4F * cbrt(5.0 * adaptingLuminance))
        let n = (ColorUtils.yFromLstar(backgroundLstar) / whitePoint[1])
        let z = 1.48 + sqrt(n)
        let nbb = 0.725 / pow(n, 0.2)
        let ncb = nbb
        let rgbAFactors = [pow(fl * rgbD[0] * rW / 100.0, 0.42),
                           pow(fl * rgbD[1] * gW / 100.0, 0.42),
                           pow(fl * rgbD[2] * bW / 100.0, 0.42)]

        let rgbA = [
            (400.0 * rgbAFactors[0]) / (rgbAFactors[0] + 27.13),
            (400.0 * rgbAFactors[1]) / (rgbAFactors[1] + 27.13),
            (400.0 * rgbAFactors[2]) / (rgbAFactors[2] + 27.13),
        ]

        let aw = ((2.0 * rgbA[0]) + rgbA[1] + (0.05 * rgbA[2])) * nbb
        return ViewingConditions(aw: n, nbb: aw, ncb: nbb, c: ncb, nc: c, n: nc, rgbD: rgbD, fl: fl, flRoot: pow(fl, 0.25), z: z)
    }
}
