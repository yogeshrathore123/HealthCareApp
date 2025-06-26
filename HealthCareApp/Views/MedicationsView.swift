//
//  MedicationsView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct MedicationsView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var showingAddMedication = false
    @State private var showTakenAlert = false
    
    // Group medications by time of day
    private var medicationsByTimeOfDay: [Medication.TimeOfDay: [Medication]] {
        Dictionary(grouping: viewModel.medications) { $0.timeOfDay }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    // Daily Progress
                    dailyProgressSection
                    
                    // Medications grouped by time of day and food relation
                    ForEach(Medication.TimeOfDay.allCases, id: \.self) { timeOfDay in
                        if let medications = medicationsByTimeOfDay[timeOfDay], !medications.isEmpty {
                            Section(timeOfDay.rawValue) {
                                ForEach(Medication.FoodRelation.allCases, id: \.self) { foodRelation in
                                    let filteredMeds = medications.filter { $0.foodRelation == foodRelation }
                                    if !filteredMeds.isEmpty {
                                        Section(foodRelation.rawValue) {
                                            ForEach(filteredMeds) { medication in
                                                MedicationRow(medication: medication, highlight: medication.id == viewModel.highlightedMedicationId) {
                                                    viewModel.toggleMedicationTaken(medication)
                                                }
                                                .id(medication.id)
                                            }
                                            .onDelete { indexSet in
                                                let globalIndices = indexSet.compactMap { idx in
                                                    viewModel.medications.firstIndex(where: { $0.id == filteredMeds[idx].id })
                                                }
                                                viewModel.deleteMedication(at: IndexSet(globalIndices))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.highlightedMedicationId) { id in
                    if let id = id {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .center)
                        }
                        // Optionally clear highlight after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.highlightedMedicationId = nil
                        }
                    }
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetDailyMedications()
                    }
                    .disabled(viewModel.medications.allSatisfy { !$0.isTaken })
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.requestNotificationPermission()
            if let _ = viewModel.pendingShowTakenConfirmationId {
                viewModel.showTakenConfirmation = true
                viewModel.pendingShowTakenConfirmationId = nil
            }
            if viewModel.showTakenConfirmation {
                showTakenAlert = true
            }
        }
        .onChange(of: viewModel.showTakenConfirmation) { newValue in
            if newValue {
                showTakenAlert = true
            }
        }
        .alert(isPresented: $showTakenAlert) {
            Alert(title: Text("Medication Taken"), message: Text("You have marked your medication as taken from a notification."), dismissButton: .default(Text("OK"), action: {
                viewModel.showTakenConfirmation = false
            }))
        }
    }
    
    // MARK: - Daily Progress Section
    private var dailyProgressSection: some View {
        Section {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(viewModel.medications.filter { $0.isTaken }.count) of \(viewModel.medications.count) medications taken")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: Double(viewModel.medications.filter { $0.isTaken }.count) / Double(max(viewModel.medications.count, 1)),
                        size: 60
                    )
                }
                
                // Progress Bar
                ProgressView(value: Double(viewModel.medications.filter { $0.isTaken }.count), total: Double(max(viewModel.medications.count, 1)))
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Medication Row
struct MedicationRow: View {
    let medication: Medication
    var highlight: Bool = false
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Medication Icon
            Image(systemName: "pills.fill")
                .font(.title2)
                .foregroundColor(medication.isTaken ? .green : .blue)
                .frame(width: 30)
            
            // Medication Details
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                    .foregroundColor(medication.isTaken ? .secondary : .primary)
                
                HStack {
                    Text(medication.dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(medication.frequency)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(medication.foodRelation.rawValue)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if let lastTaken = medication.lastTaken {
                        Text("Taken at \(formatTime(lastTaken))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Toggle Button
            Button(action: onToggle) {
                Image(systemName: medication.isTaken ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(medication.isTaken ? .green : .gray)
            }
        }
        .padding(.vertical, 4)
        .opacity(medication.isTaken ? 0.7 : 1.0)
        .background(highlight ? Color.yellow.opacity(0.3) : Color.clear)
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Add Medication View
struct AddMedicationView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = ""
    @State private var reminderTimes: [Date] = [Date()]
    @State private var timeOfDay: Medication.TimeOfDay = .morning
    @State private var foodRelation: Medication.FoodRelation = .none
    
    var body: some View {
        NavigationView {
            Form {
                Section("Medication Details") {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    TextField("Frequency", text: $frequency)
                    Picker("Time of Day", selection: $timeOfDay) {
                        ForEach(Medication.TimeOfDay.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    Picker("Before/After Food", selection: $foodRelation) {
                        ForEach(Medication.FoodRelation.allCases, id: \.self) { relation in
                            Text(relation.rawValue).tag(relation)
                        }
                    }
                }
                Section("Reminder Times") {
                    ForEach(reminderTimes.indices, id: \.self) { index in
                        DatePicker("Reminder #\(index + 1)", selection: $reminderTimes[index], displayedComponents: .hourAndMinute)
                    }
                    Button(action: {
                        reminderTimes.append(Date())
                    }) {
                        Label("Add Another Time", systemImage: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.top, 4)
                    if reminderTimes.count > 1 {
                        Button(action: {
                            reminderTimes.removeLast()
                        }) {
                            Label("Remove Last Time", systemImage: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || frequency.isEmpty || reminderTimes.isEmpty)
                }
            }
        }
    }
    
    private func saveMedication() {
        let newMedication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            reminderTimes: reminderTimes,
            timeOfDay: timeOfDay,
            foodRelation: foodRelation
        )
        
        viewModel.addMedication(newMedication)
        dismiss()
    }
}

#Preview {
    MedicationsView()
        .environmentObject(HealthAppViewModel())
} 
