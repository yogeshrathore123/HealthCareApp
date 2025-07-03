import Foundation
import SwiftUI
import Combine

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication]
    private let notificationManager: NotificationManager
    
    init(medications: [Medication] = MockData.sampleMedications, notificationManager: NotificationManager = .shared) {
        self.medications = medications
        self.notificationManager = notificationManager
    }
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        notificationManager.scheduleMedicationNotification(for: medication)
    }
    
    func deleteMedication(at indexSet: IndexSet) {
        medications.remove(atOffsets: indexSet)
    }
    
    func toggleMedicationTaken(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            var updated = medications[index]
            updated.isTaken.toggle()
            updated.lastTaken = updated.isTaken ? Date() : nil
            medications[index] = updated
        }
    }
    
    func resetDailyMedications() {
        for index in medications.indices {
            medications[index].isTaken = false
            medications[index].lastTaken = nil
        }
    }
    
    func markMedicationAsTaken(withId id: UUID) {
        if let index = medications.firstIndex(where: { $0.id == id }) {
            medications[index].isTaken = true
            medications[index].lastTaken = Date()
        }
    }
} 
