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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Notification delegate instance
    static let notificationDelegate = NotificationDelegate()

    init() {
        // Register notification actions
        let viewModel = HealthAppViewModel.shared
        viewModel.registerNotificationActions()
        UNUserNotificationCenter.current().delegate = Self.notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(HealthAppViewModel.shared)
        }
        .modelContainer(sharedModelContainer)
    }
}
