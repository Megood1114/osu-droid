import Foundation

public enum StrainUtils {
    public static func countTopWeightedSliders(sliderStrains: [Double], difficultyValue: Double) -> Double {
        if sliderStrains.isEmpty {
            return 0.0
        }

        // What would the top strain be if all strain values were identical
        let consistentTopStrain = difficultyValue / 10.0

        if consistentTopStrain == 0.0 {
            return 0.0
        }

        // Use a weighted sum of all strains. Constants are arbitrary and give nice values
        return sliderStrains.reduce(0.0) { sum, strain in
            sum + DifficultyCalculationUtils.logistic(x: strain / consistentTopStrain, midpointOffset: 0.88, multiplier: 10.0, maxValue: 1.1)
        }
    }
}
