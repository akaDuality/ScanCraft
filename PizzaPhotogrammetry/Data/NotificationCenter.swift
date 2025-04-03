//
//  NotificationCenter.swift
//  PizzaPhotogrammetry
//
//  Created by Mikhail Rubanov on 29.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationCenter {
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications are set!")
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func showCompletePush(_ url: URL) {
        let content = UNMutableNotificationContent()
        content.title = "Complete processing"
        content.subtitle = url.pathTrailing
        content.sound = UNNotificationSound.default
        
        // choose a random identifier
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content, trigger: nil)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func showFailurePush(_ url: URL) {
        let content = UNMutableNotificationContent()
        content.title = "Fail processing"
        content.subtitle = url.pathTrailing
        content.sound = UNNotificationSound.defaultCritical
        
        // choose a random identifier
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content, trigger: nil)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}
