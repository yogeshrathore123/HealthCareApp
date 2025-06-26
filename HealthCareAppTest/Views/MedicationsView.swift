//
//  MedicationsView.swift
//  HealthCareAppTest
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct MedicationsView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            List {
                // Daily Progress
                dailyProgressSection
                
                // Medications by Time of Day
                ForEach(Medication.TimeOfDay.allCases, id: \.self) { timeOfDay in
                    if let medications = viewModel.medicationsByTimeOfDay[timeOfDay] {
                        Section(timeOfDay.rawValue) {
                            ForEach(medications) { medication in
                                MedicationRow(medication: medication) {
                                    viewModel.toggleMedicationTaken(medication)
                                }
                            }
                            .onDelete(perform: viewModel.deleteMedication)
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
                
                if let lastTaken = medication.lastTaken {
                    Text("Taken at \(formatTime(lastTaken))")
                        .font(.caption)
                        .foregroundColor(.green)
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
    @State private var timeOfDay = Medication.TimeOfDay.morning
    
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
                    .disabled(name.isEmpty || dosage.isEmpty || frequency.isEmpty)
                }
            }
        }
    }
    
    private func saveMedication() {
        let newMedication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            timeOfDay: timeOfDay
        )
        
        viewModel.addMedication(newMedication)
        dismiss()
    }
}

#Preview {
    MedicationsView()
        .environmentObject(HealthAppViewModel())
} 