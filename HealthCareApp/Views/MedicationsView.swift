//
//  MedicationsView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI
import Combine

struct MedicationsView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var showingAddMedication = false
    @State private var showTakenAlert = false
    @State private var forceRefresh = 0
    @State private var editingMedication: Medication? = nil
    
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
                ScrollView {
                    VStack(alignment: .leading) {
                        // Daily Progress
                        dailyProgressSection
                        // Medications grouped by time of day and food relation
                        ForEach(groupedMedications, id: \.timeOfDay) { group in
                            MedicationGroupSection(
                                group: group,
                                viewModel: viewModel,
                                forceRefresh: $forceRefresh,
                                editingMedication: $editingMedication
                            )
                        }
                    }
                    .padding()
                    .id(forceRefresh)
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
                AddMedicationView(onAdd: {
                    forceRefresh += 1
                })
                .environmentObject(viewModel)
            }
            .sheet(item: $editingMedication) { medication in
                if let index = viewModel.medicationViewModel.medications.firstIndex(where: { $0.id == medication.id }) {
                    EditMedicationView(medication: $viewModel.medicationViewModel.medications[index], onSave: {
                        forceRefresh += 1
                    })
                }
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

struct MedicationGroupSection: View {
    let group: (timeOfDay: Medication.TimeOfDay, foodGroups: [(foodRelation: Medication.FoodRelation, meds: [Medication])])
    @ObservedObject var viewModel: HealthAppViewModel
    @Binding var forceRefresh: Int
    @Binding var editingMedication: Medication?

    var body: some View {
        Text(group.timeOfDay.rawValue)
            .font(.headline)
            .padding(.top)
        ForEach(group.foodGroups, id: \.foodRelation) { foodGroup in
            Text(foodGroup.foodRelation.rawValue)
                .font(.subheadline)
                .padding(.top, 4)
            ForEach(foodGroup.meds) { medication in
                MedicationRowWithActions(
                    medication: medication,
                    viewModel: viewModel,
                    forceRefresh: $forceRefresh,
                    editingMedication: $editingMedication
                )
            }
        }
    }
}

struct MedicationRowWithActions: View {
    let medication: Medication
    @ObservedObject var viewModel: HealthAppViewModel
    @Binding var forceRefresh: Int
    @Binding var editingMedication: Medication?

    var body: some View {
        if let index = viewModel.medicationViewModel.medications.firstIndex(where: { $0.id == medication.id }) {
            HStack(alignment: .top) {
                MedicationRow(
                    medication: $viewModel.medicationViewModel.medications[index],
                    highlight: medication.id == viewModel.highlightedMedicationId,
                    onToggle: { forceRefresh += 1 }
                )
                Spacer()
                Button(action: { editingMedication = viewModel.medicationViewModel.medications[index] }) {
                    Image(systemName: "pencil").foregroundColor(.blue)
                }
                Button(action: {
                    viewModel.medicationViewModel.deleteMedication(at: IndexSet(integer: index))
                    forceRefresh += 1
                }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - Medication Row
struct MedicationRow: View {
    @Binding var medication: Medication
    var highlight: Bool = false
    var onToggle: (() -> Void)? = nil
    
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
                onToggle?()
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
    var onAdd: (() -> Void)? = nil
    
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
        onAdd?()
        dismiss()
    }
}

// MARK: - Edit Medication View
struct EditMedicationView: View {
    @Binding var medication: Medication
    @Environment(\.dismiss) private var dismiss
    var onSave: (() -> Void)? = nil
    @State private var name: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var reminderTimes: [Date]
    @State private var timeOfDay: Medication.TimeOfDay
    @State private var foodRelation: Medication.FoodRelation
    
    init(medication: Binding<Medication>, onSave: (() -> Void)? = nil) {
        self._medication = medication
        self.onSave = onSave
        _name = State(initialValue: medication.wrappedValue.name)
        _dosage = State(initialValue: medication.wrappedValue.dosage)
        _frequency = State(initialValue: medication.wrappedValue.frequency)
        _reminderTimes = State(initialValue: medication.wrappedValue.reminderTimes)
        _timeOfDay = State(initialValue: medication.wrappedValue.timeOfDay)
        _foodRelation = State(initialValue: medication.wrappedValue.foodRelation)
    }
    
    var body: some View {
        NavigationView {
            Form {
                medicationDetailsSection
                reminderTimesSection
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        $medication.wrappedValue.name = name
                        $medication.wrappedValue.dosage = dosage
                        $medication.wrappedValue.frequency = frequency
                        $medication.wrappedValue.reminderTimes = reminderTimes
                        $medication.wrappedValue.timeOfDay = timeOfDay
                        $medication.wrappedValue.foodRelation = foodRelation
                        onSave?()
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || frequency.isEmpty || reminderTimes.isEmpty)
                }
            }
        }
    }
    
    private var medicationDetailsSection: some View {
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
    }
    
    private var reminderTimesSection: some View {
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
}

#Preview {
    MedicationsView()
        .environmentObject(HealthAppViewModel())
} 
