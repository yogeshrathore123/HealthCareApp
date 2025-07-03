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
    
    // Sub-view models
    @Published var userViewModel: UserViewModel
    @Published var appointmentViewModel: AppointmentViewModel
    @Published var medicationViewModel: MedicationViewModel
    @Published var healthSummaryViewModel: HealthSummaryViewModel
    
    // UI State
    @Published var showingAddAppointment = false
    @Published var showingAddMedication = false
    @Published var showTakenConfirmation = false
    @Published var openMedicationsTab = false
    @Published var highlightedMedicationId: UUID? = nil
    @Published var pendingShowTakenConfirmationId: UUID? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userViewModel: UserViewModel = UserViewModel(),
        appointmentViewModel: AppointmentViewModel = AppointmentViewModel(),
        medicationViewModel: MedicationViewModel = MedicationViewModel(),
        healthSummaryViewModel: HealthSummaryViewModel = HealthSummaryViewModel()
    ) {
        self.userViewModel = userViewModel
        self.appointmentViewModel = appointmentViewModel
        self.medicationViewModel = medicationViewModel
        self.healthSummaryViewModel = healthSummaryViewModel
        
        // Forward change notifications from sub-view models
        userViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        appointmentViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        medicationViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        healthSummaryViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // MARK: - User Profile Methods
    func updateUserProfile(name: String, age: Int, gender: User.Gender, height: Double, weight: Double) {
        userViewModel.updateUserProfile(name: name, age: age, gender: gender, height: height, weight: weight)
    }
    
    // MARK: - Appointment Methods
    func addAppointment(_ appointment: Appointment) {
        appointmentViewModel.addAppointment(appointment)
    }
    
    func deleteAppointment(at indexSet: IndexSet) {
        appointmentViewModel.deleteAppointment(at: indexSet)
    }
    
    func markAppointmentAsCompleted(_ appointment: Appointment) {
        appointmentViewModel.markAppointmentAsCompleted(appointment)
    }
    
    var upcomingAppointments: [Appointment] {
        appointmentViewModel.upcomingAppointments
    }
    
    var completedAppointments: [Appointment] {
        appointmentViewModel.completedAppointments
    }
    
    // MARK: - Medication Methods
    func addMedication(_ medication: Medication) {
        medicationViewModel.addMedication(medication)
    }
    
    func deleteMedication(at indexSet: IndexSet) {
        medicationViewModel.deleteMedication(at: indexSet)
    }
    
    func toggleMedicationTaken(_ medication: Medication) {
        medicationViewModel.toggleMedicationTaken(medication)
    }
    
    func resetDailyMedications() {
        medicationViewModel.resetDailyMedications()
    }
    
    // MARK: - Health Summary Methods
    func updateHealthSummary(steps: Int, heartRate: Int, calories: Int, sleepHours: Double, waterIntake: Double) {
        healthSummaryViewModel.updateHealthSummary(steps: steps, heartRate: heartRate, calories: calories, sleepHours: sleepHours, waterIntake: waterIntake)
    }
        
    // MARK: - Utility Methods
    func calculateBMI() -> Double {
        userViewModel.calculateBMI()
    }
    
    func getBMICategory() -> String {
        userViewModel.getBMICategory()
    }
    
    // Add this method to mark a medication as taken by UUID
    func markMedicationAsTaken(withId id: UUID) {
        medicationViewModel.markMedicationAsTaken(withId: id)
    }
} 
