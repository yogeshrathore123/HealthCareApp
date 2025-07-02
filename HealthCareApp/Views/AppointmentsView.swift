//
//  AppointmentsView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var showingAddAppointment = false
    
    var body: some View {
        NavigationView {
            List {
                // Upcoming Appointments Section
                if !viewModel.appointmentViewModel.upcomingAppointments.isEmpty {
                    Section("Upcoming Appointments") {
                        ForEach(viewModel.appointmentViewModel.upcomingAppointments) { appointment in
                            if let index = viewModel.appointmentViewModel.appointments.firstIndex(where: { $0.id == appointment.id }) {
                                AppointmentRow(
                                    appointment: $viewModel.appointmentViewModel.appointments[index],
                                    isCompleted: false
                                )
                            }
                        }
                        .onDelete(perform: viewModel.appointmentViewModel.deleteAppointment)
                    }
                } else {
                    Section("Upcoming Appointments") {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.blue)
                            Text("No upcoming appointments")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Completed Appointments Section
                if !viewModel.appointmentViewModel.completedAppointments.isEmpty {
                    Section("Completed Appointments") {
                        ForEach(viewModel.appointmentViewModel.completedAppointments) { appointment in
                            if let index = viewModel.appointmentViewModel.appointments.firstIndex(where: { $0.id == appointment.id }) {
                                AppointmentRow(
                                    appointment: $viewModel.appointmentViewModel.appointments[index],
                                    isCompleted: true
                                )
                            }
                        }
                        .onDelete(perform: viewModel.appointmentViewModel.deleteAppointment)
                    }
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAppointment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentView()
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Appointment Row
struct AppointmentRow: View {
    @Binding var appointment: Appointment
    let isCompleted: Bool
    
    init(appointment: Binding<Appointment>, isCompleted: Bool = false) {
        self._appointment = appointment
        self.isCompleted = isCompleted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.title)
                        .font(.headline)
                        .foregroundColor(isCompleted ? .secondary : .primary)
                    
                    Text(appointment.doctor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isCompleted {
                    Button(action: {
                        appointment.isCompleted = true
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text(appointment.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(DateUtils.formatDate(appointment.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let notes = appointment.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .opacity(isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Add Appointment View
struct AddAppointmentView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var doctor = ""
    @State private var location = ""
    @State private var date = Date().addingTimeInterval(3600)
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appointment Details") {
                    TextField("Title", text: $title)
                    TextField("Doctor", text: $doctor)
                    TextField("Location", text: $location)
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(title.isEmpty || doctor.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    private func saveAppointment() {
        let newAppointment = Appointment(
            title: title,
            doctor: doctor,
            date: date,
            location: location,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.appointmentViewModel.addAppointment(newAppointment)
        dismiss()
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(HealthAppViewModel())
} 
