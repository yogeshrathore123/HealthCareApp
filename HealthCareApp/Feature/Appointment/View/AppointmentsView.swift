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
    @State private var forceRefresh = 0
    @State private var editingAppointment: Appointment? = nil
    
    var body: some View {
        let appointments = viewModel.appointmentViewModel.appointments
        let _ = print("AppointmentsView recomputed, count: \(appointments.count)")
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Upcoming Appointments Section
                    if appointments.contains(where: { !$0.isCompleted && $0.date > Date() }) {
                        Text("Upcoming Appointments")
                            .font(.headline)
                            .padding(.top)
                        ForEach(appointments.indices, id: \.self) { idx in
                            if !appointments[idx].isCompleted && appointments[idx].date > Date() {
                                HStack(alignment: .top) {
                                    AppointmentRow(appointment: appointments[idx], isCompleted: false, onComplete: { forceRefresh += 1 })
                                    Spacer()
                                    Button(action: { editingAppointment = appointments[idx] }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    Button(action: {
                                        viewModel.appointmentViewModel.deleteAppointment(at: IndexSet(integer: idx))
                                        forceRefresh += 1
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No upcoming appointments")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    // Completed Appointments Section
                    if appointments.contains(where: { $0.isCompleted }) {
                        Text("Completed Appointments")
                            .font(.headline)
                            .padding(.top)
                        ForEach(appointments.indices, id: \.self) { idx in
                            if appointments[idx].isCompleted {
                                HStack(alignment: .top) {
                                    AppointmentRow(appointment: appointments[idx], isCompleted: true)
                                    Spacer()
                                    Button(action: { editingAppointment = appointments[idx] }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    Button(action: {
                                        viewModel.appointmentViewModel.deleteAppointment(at: IndexSet(integer: idx))
                                        forceRefresh += 1
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .id(forceRefresh)
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
                AddAppointmentView(onAdd: {
                    forceRefresh += 1
                })
                .environmentObject(viewModel)
            }
            .sheet(item: $editingAppointment) { appointment in
                EditAppointmentView(appointment: appointment, onSave: {
                    forceRefresh += 1
                })
            }
        }
    }
}

// MARK: - Appointment Row
struct AppointmentRow: View {
    @ObservedObject var appointment: Appointment
    let isCompleted: Bool
    var onComplete: (() -> Void)? = nil
    
    init(appointment: Appointment, isCompleted: Bool = false, onComplete: (() -> Void)? = nil) {
        self.appointment = appointment
        self.isCompleted = isCompleted
        self.onComplete = onComplete
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
                        onComplete?()
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
    var onAdd: (() -> Void)? = nil
    
    @State private var title = ""
    @State private var doctor = ""
    @State private var location = ""
    @State private var date = Date().addingTimeInterval(86400) // Default to 1 day from now
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
        print("Adding appointment: \(newAppointment)")
        viewModel.appointmentViewModel.addAppointment(newAppointment)
        print("All appointments: \(viewModel.appointmentViewModel.appointments)")
        print("Upcoming appointments: \(viewModel.appointmentViewModel.upcomingAppointments)")
        onAdd?()
        dismiss()
    }
}

// Add EditAppointmentView for editing an existing appointment:
struct EditAppointmentView: View {
    @ObservedObject var appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    var onSave: (() -> Void)? = nil
    @State private var title: String
    @State private var doctor: String
    @State private var location: String
    @State private var date: Date
    @State private var notes: String
    
    init(appointment: Appointment, onSave: (() -> Void)? = nil) {
        self.appointment = appointment
        self.onSave = onSave
        _title = State(initialValue: appointment.title)
        _doctor = State(initialValue: appointment.doctor)
        _location = State(initialValue: appointment.location)
        _date = State(initialValue: appointment.date)
        _notes = State(initialValue: appointment.notes ?? "")
    }
    
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
            .navigationTitle("Edit Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        appointment.title = title
                        appointment.doctor = doctor
                        appointment.location = location
                        appointment.date = date
                        appointment.notes = notes.isEmpty ? nil : notes
                        onSave?()
                        dismiss()
                    }
                    .disabled(title.isEmpty || doctor.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(HealthAppViewModel())
} 
