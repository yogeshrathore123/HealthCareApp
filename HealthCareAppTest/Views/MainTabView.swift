//
//  MainTabView.swift
//  HealthCareAppTest
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = HealthAppViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            AppointmentsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
            
            MedicationsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
            
            ProfileView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
} 