import Foundation
import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var user: User
    
    init(user: User = MockData.sampleUser) {
        self.user = user
    }
    
    func updateUserProfile(name: String, age: Int, gender: User.Gender, height: Double, weight: Double) {
        user.name = name
        user.age = age
        user.gender = gender
        user.height = height
        user.weight = weight
    }
    
    func calculateBMI() -> Double {
        let heightInMeters = user.height / 100
        return user.weight / (heightInMeters * heightInMeters)
    }
    
    
    func getBMICategory() -> String {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
} 
