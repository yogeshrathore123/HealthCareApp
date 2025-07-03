import Foundation
import SwiftUI
import Combine

class HealthSummaryViewModel: ObservableObject {
    @Published var healthSummary: HealthSummary
    
    init(healthSummary: HealthSummary = MockData.sampleHealthSummary) {
        self.healthSummary = healthSummary
    }
    
    func updateHealthSummary(steps: Int, heartRate: Int, calories: Int, sleepHours: Double, waterIntake: Double) {
        healthSummary.steps = steps
        healthSummary.heartRate = heartRate
        healthSummary.calories = calories
        healthSummary.sleepHours = sleepHours
        healthSummary.waterIntake = waterIntake
        healthSummary.date = Date()
    }
} 
