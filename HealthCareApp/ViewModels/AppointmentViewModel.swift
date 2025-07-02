import Foundation
import SwiftUI
import Combine

class AppointmentViewModel: ObservableObject {
    @Published var appointments: [Appointment]
    
    init(appointments: [Appointment] = MockData.sampleAppointments) {
        self.appointments = appointments
    }
    
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
} 
