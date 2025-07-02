import Foundation
import SwiftUI
import Combine

class AppointmentViewModel: ObservableObject {
    @Published var appointments: [Appointment]
    
    init(appointments: [Appointment] = MockData.sampleAppointments) {
        self.appointments = appointments
    }
    
    func addAppointment(_ appointment: Appointment) {
        appointments = appointments + [appointment]
    }
    
    func deleteAppointment(at indexSet: IndexSet) {
        var copy = appointments
        copy.remove(atOffsets: indexSet)
        appointments = copy
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
} 
