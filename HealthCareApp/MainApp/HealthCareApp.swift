//
//  HealthCareApp.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
//

import SwiftUI
import SwiftData
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Handle notification action (e.g., mark as taken)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let idString = identifier.components(separatedBy: "_").first
        let uuid = idString.flatMap { UUID(uuidString: $0) }

        if response.actionIdentifier == "MARK_AS_TAKEN" {
            if let uuid = uuid {
                HealthAppViewModel.shared.markMedicationAsTaken(withId: uuid)
                DispatchQueue.main.async {
                    HealthAppViewModel.shared.highlightedMedicationId = uuid
                    HealthAppViewModel.shared.openMedicationsTab = true
                    HealthAppViewModel.shared.pendingShowTakenConfirmationId = uuid
                }
            } else {
                DispatchQueue.main.async {
                    HealthAppViewModel.shared.openMedicationsTab = true
                }
            }

        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User tapped the notification (default action)
            if let uuid = uuid {
                DispatchQueue.main.async {
                    HealthAppViewModel.shared.highlightedMedicationId = uuid
                    HealthAppViewModel.shared.openMedicationsTab = true
                }
            } else {
                DispatchQueue.main.async {
                    HealthAppViewModel.shared.openMedicationsTab = true
                }
            }
        }
        completionHandler()
    }
}

@main
struct HealthCareApp: App {

    // Notification delegate instance
    static let notificationDelegate = NotificationDelegate()

     @State private var showSplash = true

    init() {
        // Register notification actions
        NotificationManager.shared.registerNotificationActions()
        NotificationManager.shared.requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = Self.notificationDelegate
    }


      var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .environmentObject(HealthAppViewModel.shared)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }
}
