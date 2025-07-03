//
//  MainTabView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: HealthAppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            AppointmentsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(1)
            
            MedicationsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(2)
            
            ProfileView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onReceive(viewModel.$openMedicationsTab) { open in
            if open {
                selectedTab = 2
                viewModel.openMedicationsTab = false
            }
        }
        .sheet(isPresented: $viewModel.showingAddAppointment, onDismiss: {
            viewModel.showingAddAppointment = false
        }) {
            AddAppointmentView(onAdd: {
                viewModel.showingAddAppointment = false
                selectedTab = 1
            })
            .environmentObject(viewModel)
        }
        .sheet(isPresented: $viewModel.showingAddMedication, onDismiss: {
            viewModel.showingAddMedication = false
        }) {
            AddMedicationView(onAdd: {
                viewModel.showingAddMedication = false
                selectedTab = 2
            })
            .environmentObject(viewModel)
        }
    }
}

#Preview {
    MainTabView()
} 
