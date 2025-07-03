//
//  HealthData.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import Foundation

// MARK: - Mock Data
struct MockData {
    static let sampleUser = User(
        name: "Yogesh Rathore",
        age: 34,
        gender: .male,
        height: 175.0,
        weight: 70.0
    )
    
    static let sampleAppointments = [
        Appointment(
            title: "Annual Checkup",
            doctor: "Dr. Sarah Johnson",
            date: Date().addingTimeInterval(86400), // Tomorrow
            location: "City Medical Center",
            notes: "Bring your recent blood test results"
        ),
        Appointment(
            title: "Dental Cleaning",
            doctor: "Dr. Michael Chen",
            date: Date().addingTimeInterval(172800), // Day after tomorrow
            location: "Bright Smile Dental",
            notes: "Regular cleaning and checkup"
        ),
        Appointment(
            title: "Cardiology Consultation",
            doctor: "Dr. Emily Rodriguez",
            date: Date().addingTimeInterval(604800), // Next week
            location: "Heart Care Institute",
            notes: "Follow-up appointment"
        )
    ]
    
    static let sampleMedications = [
        Medication(
            name: "Vitamin D3",
            dosage: "1000 IU",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*8)],
            timeOfDay: .morning,
            foodRelation: .afterFood
        ),
        Medication(
            name: "Omega-3",
            dosage: "1000 mg",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*18)],
            timeOfDay: .evening,
            foodRelation: .beforeFood
        ),
        Medication(
            name: "Blood Pressure Medication",
            dosage: "10 mg",
            frequency: "Daily",
            reminderTimes: [Date().addingTimeInterval(60*60*8), Date().addingTimeInterval(60*60*20)],
            timeOfDay: .morning,
            foodRelation: .beforeFood
        ),
        Medication(
            name: "Sleep Aid",
            dosage: "5 mg",
            frequency: "As needed",
            reminderTimes: [Date().addingTimeInterval(60*60*22)],
            timeOfDay: .night,
            foodRelation: .none
        )
    ]
    
    static let sampleHealthSummary = HealthSummary(
        steps: 8420,
        heartRate: 72,
        calories: 1850,
        sleepHours: 7.5,
        waterIntake: 2.1,
        date: Date()
    )
} 
