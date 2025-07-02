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
    
    // Precompute grouped and filtered medications
    private var groupedMedications: [(timeOfDay: Medication.TimeOfDay, foodGroups: [(foodRelation: Medication.FoodRelation, meds: [Medication])])] {
        Medication.TimeOfDay.allCases.map { timeOfDay in
            let medsForTime = viewModel.medicationViewModel.medications.filter { $0.timeOfDay == timeOfDay }
            let foodGroups = Medication.FoodRelation.allCases.map { foodRelation in
                (foodRelation, medsForTime.filter { $0.foodRelation == foodRelation })
            }.filter { !$0.1.isEmpty }
            return (timeOfDay, foodGroups)
        }.filter { !$0.foodGroups.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    // Daily Progress
                    dailyProgressSection
                    
                    // Medications grouped by time of day and food relation
                    MedicationSectionList(groupedMedications: groupedMedications, viewModel: viewModel)
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
                        viewModel.medicationViewModel.resetDailyMedications()
                    }
                    .disabled(viewModel.medicationViewModel.medications.allSatisfy { !$0.isTaken })
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            NotificationManager.shared.requestNotificationPermission()
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
                        
                        Text("\(viewModel.medicationViewModel.medications.filter { $0.isTaken }.count) of \(viewModel.medicationViewModel.medications.count) medications taken")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: Double(viewModel.medicationViewModel.medications.filter { $0.isTaken }.count) / Double(max(viewModel.medicationViewModel.medications.count, 1)),
                        size: 60
                    )
                }
                
                // Progress Bar
                ProgressView(value: Double(viewModel.medicationViewModel.medications.filter { $0.isTaken }.count), total: Double(max(viewModel.medicationViewModel.medications.count, 1)))
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Medication Row
struct MedicationRow: View {
    @Binding var medication: Medication
    var highlight: Bool = false
    
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
                        Text("Taken at \(DateUtils.formatTime(lastTaken))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Toggle Button
            Button(action: {
                medication.isTaken.toggle()
                medication.lastTaken = medication.isTaken ? Date() : nil
            }) {
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
        
        viewModel.medicationViewModel.addMedication(newMedication)
        dismiss()
    }
}

struct MedicationSectionList: View {
    let groupedMedications: [(timeOfDay: Medication.TimeOfDay, foodGroups: [(foodRelation: Medication.FoodRelation, meds: [Medication])])]
    @ObservedObject var viewModel: HealthAppViewModel

    var body: some View {
        ForEach(groupedMedications, id: \.timeOfDay) { group in
            Section(group.timeOfDay.rawValue) {
                ForEach(group.foodGroups, id: \.foodRelation) { foodGroup in
                    Section(foodGroup.foodRelation.rawValue) {
                        ForEach(foodGroup.meds) { medication in
                            if let index = viewModel.medicationViewModel.medications.firstIndex(where: { $0.id == medication.id }) {
                                MedicationRow(
                                    medication: $viewModel.medicationViewModel.medications[index],
                                    highlight: medication.id == viewModel.highlightedMedicationId
                                )
                                .id(medication.id)
                            }
                        }
                        .onDelete { indexSet in
                            let globalIndices = indexSet.compactMap { idx in
                                viewModel.medicationViewModel.medications.firstIndex(where: { $0.id == foodGroup.meds[idx].id })
                            }
                            viewModel.medicationViewModel.deleteMedication(at: IndexSet(globalIndices))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MedicationsView()
        .environmentObject(HealthAppViewModel())
} 
