import Foundation
import UserNotifications
import SwiftUI

final class EngagementManager {
    static let shared = EngagementManager()
    private init() {}

    func scheduleReminder(title: String, body: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func referralURL() -> URL {
        return URL(string: "https://astrostackerpro.example/referral")!
    }
}
