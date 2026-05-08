import Foundation
import EventKit
import UIKit

class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    private var isEventsEnabled: Bool {
        return UserDefaults.standard.object(forKey: "eventManagementEnabled") as? Bool ?? true
    }
    
    //Request access to both calender and reminders
    func requestAccess(completion: @escaping (Bool) -> Void) {
        guard isEventsEnabled else {
            completion(false)
            return
        }
        
        eventStore.requestAccess(to: .event) { granted, _ in
            if granted {
                self.eventStore.requestAccess(to: .reminder) { grantedReminders, _ in
                    completion(grantedReminders)
                }
            } else {
                completion(false)
            }
        }
    }
    
    //function for add a session to ios calendar app
    func addEventToCalendar(title: String, description: String, startDate: Date) {
        requestAccess { granted in
            guard granted else { return }
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.notes = description
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(3600)
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                print("Event added to iOS Calendar!")
            } catch {
                print("Error saving calendar event: \(error.localizedDescription)")
            }
        }
    }
    
    //Function to add session to the ios reminder app
    func addReminderToSystem(title: String, dueDate: Date) {
        requestAccess { granted in
            guard granted else { return }
            
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = title
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            
            do {
                try self.eventStore.save(reminder, commit: true)
                print("Reminder added to iOS Reminders app!")
            } catch {
                print("Error saving system reminder: \(error.localizedDescription)")
            }
        }
    }

    //Open the officila apple calendar
    func openSystemCalendar() {
        if let url = URL(string: "calshow://") {
            UIApplication.shared.open(url)
        }
    }
    
    //Open the official apple reminder app
    func openSystemReminders() {
        if let url = URL(string: "x-apple-reminder://") {
            UIApplication.shared.open(url)
        }
    }
}
