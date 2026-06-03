import Foundation

/// Provides error function approximations for difficulty calculations.
enum ErrorFunction {
    /// A fast approximation of the error function (erf).
    ///
    /// Uses the Abramowitz and Stegun approximation (formula 7.1.26) which provides
    /// a maximum error of 1.5×10⁻⁷.
    ///
    /// - Parameter x: The input value.
    /// - Returns: An approximation of erf(x).
    static func erfFast(_ x: Double) -> Double {
        // Save the sign of x
        let sign: Double = x >= 0 ? 1.0 : -1.0
        let absX = abs(x)

        // Constants for the Abramowitz and Stegun approximation
        let a1 =  0.254829592
        let a2 = -0.284496736
        let a3 =  1.421413741
        let a4 = -1.453152027
        let a5 =  1.061405429
        let p  =  0.3275911

        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)

        return sign * y
    }
}
