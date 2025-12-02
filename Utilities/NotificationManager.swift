//
//  NotificationManager.swift
//  LifeHub
//
//  Enhanced notification system with categories, actions, and scheduling
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Categories

enum NotificationCategory: String {
    case task = "TASK_CATEGORY"
    case habit = "HABIT_CATEGORY"
    case reminder = "REMINDER_CATEGORY"
    case achievement = "ACHIEVEMENT_CATEGORY"
    
    var identifier: String {
        return rawValue
    }
}

// MARK: - Notification Actions

enum NotificationAction: String {
    case complete = "COMPLETE_ACTION"
    case snooze = "SNOOZE_ACTION"
    case dismiss = "DISMISS_ACTION"
    case viewDetails = "VIEW_DETAILS_ACTION"
    
    var identifier: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .complete: return "Complete"
        case .snooze: return "Snooze 15 min"
        case .dismiss: return "Dismiss"
        case .viewDetails: return "View Details"
        }
    }
    
    var options: UNNotificationActionOptions {
        switch self {
        case .complete: return [.foreground]
        case .snooze: return []
        case .dismiss: return [.destructive]
        case .viewDetails: return [.foreground]
        }
    }
}

// MARK: - Notification Manager

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
        setupNotificationCategories()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert])
            await MainActor.run {
                isAuthorized = granted
            }
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    private func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Setup Categories
    
    private func setupNotificationCategories() {
        // Task notification actions
        let completeAction = UNNotificationAction(
            identifier: NotificationAction.complete.identifier,
            title: NotificationAction.complete.title,
            options: NotificationAction.complete.options
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze.identifier,
            title: NotificationAction.snooze.title,
            options: NotificationAction.snooze.options
        )
        
        let viewDetailsAction = UNNotificationAction(
            identifier: NotificationAction.viewDetails.identifier,
            title: NotificationAction.viewDetails.title,
            options: NotificationAction.viewDetails.options
        )
        
        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss.identifier,
            title: NotificationAction.dismiss.title,
            options: NotificationAction.dismiss.options
        )
        
        // Task category
        let taskCategory = UNNotificationCategory(
            identifier: NotificationCategory.task.identifier,
            actions: [completeAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Habit category
        let habitCategory = UNNotificationCategory(
            identifier: NotificationCategory.habit.identifier,
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Reminder category
        let reminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.reminder.identifier,
            actions: [viewDetailsAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Achievement category
        let achievementCategory = UNNotificationCategory(
            identifier: NotificationCategory.achievement.identifier,
            actions: [viewDetailsAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([taskCategory, habitCategory, reminderCategory, achievementCategory])
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleTaskNotification(
        id: String,
        title: String,
        body: String,
        date: Date,
        repeats: Bool = false
    ) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.task.identifier
        content.userInfo = ["type": "task", "taskId": id]
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            return true
        } catch {
            print("Error scheduling task notification: \(error)")
            return false
        }
    }
    
    func scheduleHabitReminder(
        id: String,
        habitName: String,
        hour: Int,
        minute: Int,
        repeatsDaily: Bool = true
    ) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habitName)!"
        content.body = "Keep your streak going! 🔥"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.habit.identifier
        content.userInfo = ["type": "habit", "habitId": id]
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatsDaily)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            return true
        } catch {
            print("Error scheduling habit reminder: \(error)")
            return false
        }
    }
    
    func scheduleAchievementNotification(
        title: String,
        body: String,
        badge: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "🎉 \(title)"
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.achievement.identifier
        content.userInfo = ["type": "achievement", "badge": badge]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("Error scheduling achievement notification: \(error)")
        }
    }
    
    func scheduleSnoozeNotification(originalId: String, content: UNNotificationContent) async {
        let snoozeContent = content.mutableCopy() as! UNMutableNotificationContent
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false) // 15 minutes
        let request = UNNotificationRequest(identifier: "\(originalId)_snoozed", content: snoozeContent, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("Error scheduling snooze notification: \(error)")
        }
    }
    
    // MARK: - Manage Notifications
    
    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await center.deliveredNotifications()
    }
    
    func getBadgeCount() -> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    
    func setBadgeCount(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        Task {
            switch actionIdentifier {
            case NotificationAction.complete.identifier:
                await handleCompleteAction(userInfo: userInfo)
                
            case NotificationAction.snooze.identifier:
                await handleSnoozeAction(
                    id: response.notification.request.identifier,
                    content: response.notification.request.content
                )
                
            case NotificationAction.viewDetails.identifier:
                handleViewDetailsAction(userInfo: userInfo)
                
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification
                handleNotificationTap(userInfo: userInfo)
                
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    private func handleCompleteAction(userInfo: [AnyHashable: Any]) async {
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "task":
            if let taskId = userInfo["taskId"] as? String {
                NotificationCenter.default.post(name: .completeTask, object: taskId)
            }
        case "habit":
            if let habitId = userInfo["habitId"] as? String {
                NotificationCenter.default.post(name: .completeHabit, object: habitId)
            }
        default:
            break
        }
    }
    
    private func handleSnoozeAction(id: String, content: UNNotificationContent) async {
        await scheduleSnoozeNotification(originalId: id, content: content)
    }
    
    private func handleViewDetailsAction(userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .viewNotificationDetails, object: userInfo)
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .notificationTapped, object: userInfo)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let completeTask = Notification.Name("completeTask")
    static let completeHabit = Notification.Name("completeHabit")
    static let viewNotificationDetails = Notification.Name("viewNotificationDetails")
    static let notificationTapped = Notification.Name("notificationTapped")
}
