//
//  ProfileView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedAge = ""
    @State private var editedGender = User.Gender.male
    @State private var editedHeight = ""
    @State private var editedWeight = ""
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                profileHeaderSection
                
                // Personal Information
                personalInfoSection
                
                // Health Metrics
                healthMetricsSection
                
                // App Settings
                appSettingsSection
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveProfile()
                        } else {
                            startEditing()
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            cancelEditing()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                // Profile Image
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(viewModel.user.age) years old")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.user.gender.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Personal Information Section
    private var personalInfoSection: some View {
        Section("Personal Information") {
            if isEditing {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $editedName)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Age")
                    Spacer()
                    TextField("Age", text: $editedAge)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Gender")
                    Spacer()
                    Picker("Gender", selection: $editedGender) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("Height")
                    Spacer()
                    TextField("Height (cm)", text: $editedHeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("Weight (kg)", text: $editedWeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            } else {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(viewModel.user.name)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Age")
                    Spacer()
                    Text("\(viewModel.user.age) years")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Gender")
                    Spacer()
                    Text(viewModel.user.gender.rawValue)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Height")
                    Spacer()
                    Text("\(String(format: "%.1f", viewModel.user.height)) cm")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Weight")
                    Spacer()
                    Text("\(String(format: "%.1f", viewModel.user.weight)) kg")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Health Metrics Section
    private var healthMetricsSection: some View {
        Section("Health Metrics") {
            HStack {
                Text("BMI")
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", viewModel.calculateBMI()))
                        .fontWeight(.semibold)
                    Text(viewModel.getBMICategory())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("BMI Category")
                Spacer()
                Text(viewModel.getBMICategory())
                    .foregroundColor(bmiCategoryColor)
                    .fontWeight(.medium)
            }
        }
    }
    
    // MARK: - App Settings Section
    private var appSettingsSection: some View {
        Section("App Settings") {
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text("Notifications")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text("Privacy & Security")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text("Help & Support")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text("About")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var bmiCategoryColor: Color {
        let bmi = viewModel.calculateBMI()
        switch bmi {
        case ..<18.5:
            return .orange
        case 18.5..<25:
            return .green
        case 25..<30:
            return .orange
        default:
            return .red
        }
    }
    
    // MARK: - Methods
    private func startEditing() {
        editedName = viewModel.user.name
        editedAge = String(viewModel.user.age)
        editedGender = viewModel.user.gender
        editedHeight = String(format: "%.1f", viewModel.user.height)
        editedWeight = String(format: "%.1f", viewModel.user.weight)
        isEditing = true
    }
    
    private func saveProfile() {
        guard let age = Int(editedAge),
              let height = Double(editedHeight),
              let weight = Double(editedWeight) else {
            return
        }
        
        viewModel.updateUserProfile(
            name: editedName,
            age: age,
            gender: editedGender,
            height: height,
            weight: weight
        )
        
        isEditing = false
    }
    
    private func cancelEditing() {
        isEditing = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(HealthAppViewModel())
} 
