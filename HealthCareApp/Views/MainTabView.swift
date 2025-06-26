//
//  MainTabView.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = HealthAppViewModel.shared
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
    }
}

#Preview {
    MainTabView()
} 
