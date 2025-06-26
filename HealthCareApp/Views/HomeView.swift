//
//  HomeView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Health Summary Cards
                    healthSummarySection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Health Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back,")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(viewModel.user.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Today's Health Summary")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Health Summary Section
    private var healthSummarySection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            HealthMetricCard(
                title: "Steps",
                value: "\(viewModel.healthSummary.steps)",
                subtitle: "Goal: 10,000",
                icon: "figure.walk",
                color: .blue
            )
            
            HealthMetricCard(
                title: "Heart Rate",
                value: "\(viewModel.healthSummary.heartRate)",
                subtitle: "BPM",
                icon: "heart.fill",
                color: .red
            )
            
            HealthMetricCard(
                title: "Calories",
                value: "\(viewModel.healthSummary.calories)",
                subtitle: "Burned",
                icon: "flame.fill",
                color: .orange
            )
            
            HealthMetricCard(
                title: "Sleep",
                value: String(format: "%.1f", viewModel.healthSummary.sleepHours),
                subtitle: "Hours",
                icon: "bed.double.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Add Appointment",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    viewModel.showingAddAppointment = true
                }
                
                QuickActionButton(
                    title: "Log Medication",
                    icon: "pills.fill",
                    color: .green
                ) {
                    // Handle medication logging
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if let nextAppointment = viewModel.upcomingAppointments.first {
                    ActivityRow(
                        icon: "calendar",
                        title: "Next Appointment",
                        subtitle: nextAppointment.title,
                        time: viewModel.formatDate(nextAppointment.date),
                        color: .blue
                    )
                }
                
                ActivityRow(
                    icon: "pills",
                    title: "Medications",
                    subtitle: "\(viewModel.medications.filter { $0.isTaken }.count) of \(viewModel.medications.count) taken",
                    time: "Today",
                    color: .green
                )
                
                ActivityRow(
                    icon: "heart.fill",
                    title: "Health Check",
                    subtitle: "Last updated: \(viewModel.formatTime(viewModel.healthSummary.date))",
                    time: "Today",
                    color: .red
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct HealthMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
        .environmentObject(HealthAppViewModel())
} 
