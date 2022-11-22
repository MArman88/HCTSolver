//
//  Hct.swift
//  ColorPallete
//
//  Created by M Arman on 22/11/22.
//

import Foundation

public class Hct {
    private var hue: Double = 0.0
    private var chroma: Double = 0.0
    private var tone: Double = 0.0
    private var argb: Int = 0

    /**
     * Create an HCT color from hue, chroma, and tone.
     *
     * @param hue 0 <= hue < 360; invalid values are corrected.
     * @param chroma 0 <= chroma < ?; Informally, colorfulness. The color returned may be lower than
     *     the requested chroma. Chroma has a different maximum for any given hue and tone.
     * @param tone 0 <= tone <= 100; invalid values are corrected.
     * @return HCT representation of a color in default viewing conditions.
     */
    static func from(_ hue: Double, _ chroma: Double, _ tone: Double) -> Hct {
        let argb = HctSolver.solveToInt(hue, chroma, tone)
        return Hct(argb)
    }

    /**
     * Create an HCT color from a color.
     *
     * @param argb ARGB representation of a color.
     * @return HCT representation of a color in default viewing conditions
     */
    public static func fromInt(_ argb: Int) -> Hct {
        return Hct(argb)
    }

    private init(_ argb: Int) {
        setInternalState(argb)
    }

    public func getHue() -> Double {
        return hue
    }

    public func getChroma() -> Double {
        return chroma
    }

    public func getTone() -> Double {
        return tone
    }

    public func toInt() -> Int {
        return argb
    }

    /**
     * Set the hue of this color. Chroma may decrease because chroma has a different maximum for any
     * given hue and tone.
     *
     * @param newHue 0 <= newHue < 360; invalid values are corrected.
     */
    public func setHue(_ newHue: Double)->Hct {
        setInternalState(HctSolver.solveToInt(newHue, chroma, tone))
        return self
    }

    /**
     * Set the chroma of this color. Chroma may decrease because chroma has a different maximum for
     * any given hue and tone.
     *
     * @param newChroma 0 <= newChroma < ?
     */
    public func setChroma(_ newChroma: Double)->Hct {
        setInternalState(HctSolver.solveToInt(hue, newChroma, tone))
        return self
    }

    /**
     * Set the tone of this color. Chroma may decrease because chroma has a different maximum for any
     * given hue and tone.
     *
     * @param newTone 0 <= newTone <= 100; invalid valids are corrected.
     */
    public func setTone(_ newTone: Double)->Hct {
        setInternalState(HctSolver.solveToInt(hue, chroma, newTone))
        return self
    }

    private func setInternalState(_ argb: Int) {
        self.argb = argb
        let cam = Cam16.fromInt(argb)
        self.hue = cam.getHue()
        self.chroma = cam.getChroma()
        self.tone = ColorUtils.lstarFromArgb(argb)
    }
}
