//
//  HealthAppViewModel.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
class HealthAppViewModel: ObservableObject {
    static let shared = HealthAppViewModel()
    
    // MARK: - Published Properties
    @Published var user: User
    @Published var appointments: [Appointment]
    @Published var medications: [Medication]
    @Published var healthSummary: HealthSummary
    @Published var showingAddAppointment = false
    @Published var showingAddMedication = false
    @Published var showTakenConfirmation = false
    @Published var openMedicationsTab = false
    @Published var highlightedMedicationId: UUID? = nil
    @Published var pendingShowTakenConfirmationId: UUID? = nil
    
    // MARK: - Initialization
    init() {
        self.user = MockData.sampleUser
        self.appointments = MockData.sampleAppointments
        self.medications = MockData.sampleMedications
        self.healthSummary = MockData.sampleHealthSummary
    }
    
    // MARK: - User Profile Methods
    func updateUserProfile(name: String, age: Int, gender: User.Gender, height: Double, weight: Double) {
        user.name = name
        user.age = age
        user.gender = gender
        user.height = height
        user.weight = weight
    }
    
    // MARK: - Appointment Methods
    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        appointments.sort { $0.date < $1.date }
    }
    
    func deleteAppointment(at indexSet: IndexSet) {
        appointments.remove(atOffsets: indexSet)
    }
    
    func markAppointmentAsCompleted(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index].isCompleted = true
        }
    }
    
    var upcomingAppointments: [Appointment] {
        appointments.filter { !$0.isCompleted && $0.date > Date() }
    }
    
    var completedAppointments: [Appointment] {
        appointments.filter { $0.isCompleted }
    }
    
    // MARK: - Medication Methods
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        scheduleMedicationNotification(for: medication)
    }
    
    func deleteMedication(at indexSet: IndexSet) {
        medications.remove(atOffsets: indexSet)
    }
    
    func toggleMedicationTaken(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index].isTaken.toggle()
            medications[index].lastTaken = medications[index].isTaken ? Date() : nil
        }
    }
    
    func resetDailyMedications() {
        for index in medications.indices {
            medications[index].isTaken = false
            medications[index].lastTaken = nil
        }
    }
    
    // MARK: - Health Summary Methods
    func updateHealthSummary(steps: Int, heartRate: Int, calories: Int, sleepHours: Double, waterIntake: Double) {
        healthSummary.steps = steps
        healthSummary.heartRate = heartRate
        healthSummary.calories = calories
        healthSummary.sleepHours = sleepHours
        healthSummary.waterIntake = waterIntake
        healthSummary.date = Date()
    }
    
    // MARK: - Notification Methods
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    func scheduleMedicationNotification(for medication: Medication) {
        for (index, reminderTime) in medication.reminderTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "It's time to take your medication: \(medication.name) (\(medication.dosage))"
            content.sound = .defaultRingtone
            content.categoryIdentifier = "MEDICATION_REMINDER"

            // Extract hour and minute from reminderTime
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
            var dateComponents = DateComponents()
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute

            let identifier = "\(medication.id.uuidString)_\(index)"
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Call this once in app launch to register the notification category and action
    func registerNotificationActions() {
        let markAsTakenAction = UNNotificationAction(identifier: "MARK_AS_TAKEN", title: "Mark as Taken", options: [.authenticationRequired])
        let category = UNNotificationCategory(identifier: "MEDICATION_REMINDER", actions: [markAsTakenAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Utility Methods
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
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Add this method to mark a medication as taken by UUID
    func markMedicationAsTaken(withId id: UUID) {
        if let index = medications.firstIndex(where: { $0.id == id }) {
            medications[index].isTaken = true
            medications[index].lastTaken = Date()
        }
    }
} 
