//
//  UserNotifications.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import Foundation
import FirebaseAuth
import UserNotifications
import UIKit
import SwiftUI

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    var viewController: UIViewController?
    
    static let shared = NotificationDelegate()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                // Request notification permission
                center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if granted {
                        // Schedule the initial notification
                        self.scheduleDailyNotification()
                        self.scheduleInitialNotification()
                        completion(true)
                    } else {
                        // Inform the user that notification permission is required
                        self.showNotificationPermissionAlert()
                        completion(false)
                    }
                }
            } else if settings.authorizationStatus == .authorized {
                // Schedule the initial notification
                center.getPendingNotificationRequests { requests in
                    if !requests.contains(where: { $0.identifier == "initial_notification" }) {
                        // Schedule the initial notification if it has not been scheduled yet
                        self.scheduleDailyNotification()
                        self.scheduleInitialNotification()
                    }
                    completion(true)
                }
            } else {
                self.showNotificationPermissionAlert()
                completion(false)
            }
        }
    }
    
    func scheduleDailyNotification() {
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Are you working today?"
        content.body = "Don't forget to sign in for the day."
        content.sound = .default
        content.categoryIdentifier = "daily_notification"
        
        let signInAction = UNNotificationAction(identifier: "sign_in", title: "Sign In", options: [.foreground])
        let notWorkingAction = UNNotificationAction(identifier: "not_working", title: "Not working today", options: [])
        let dailyCategory = UNNotificationCategory(identifier: "daily_notification", actions: [signInAction, notWorkingAction], intentIdentifiers: [], options: [.customDismissAction])
        
        center.setNotificationCategories([dailyCategory])
        
        // Schedule a notification for Monday
        var dateComponents = DateComponents()
        dateComponents.hour = 7 // hour of the day to fire the notification
        dateComponents.weekday = 2 // Monday
        let mondayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let mondayRequest = UNNotificationRequest(identifier: "daily_notification_monday", content: content, trigger: mondayTrigger)
        center.add(mondayRequest)
        
        // Schedule a notification for Tuesday
        dateComponents.weekday = 3 // Tuesday
        let tuesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let tuesdayRequest = UNNotificationRequest(identifier: "daily_notification_tuesday", content: content, trigger: tuesdayTrigger)
        center.add(tuesdayRequest)
        
        // Schedule a notification for Wednesday
        dateComponents.weekday = 4 // Wednesday
        let wednesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let wednesdayRequest = UNNotificationRequest(identifier: "daily_notification_wednesday", content: content, trigger: wednesdayTrigger)
        center.add(wednesdayRequest)
        
        // Schedule a notification for Thursday
        dateComponents.weekday = 5 // Thursday
        let thursdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let thursdayRequest = UNNotificationRequest(identifier: "daily_notification_thursday", content: content, trigger: thursdayTrigger)
        center.add(thursdayRequest)
        
        // Schedule a notification for Friday
        dateComponents.weekday = 6 // Friday
        let fridayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let fridayRequest = UNNotificationRequest(identifier: "daily_notification_friday", content: content, trigger: fridayTrigger)
        center.add(fridayRequest)
    }
    
    
    func scheduleInitialNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Are you working overtime today?"
        content.body = "Press continue if you are working overtime. Otherwise please sign out."
        content.sound = .default
        content.categoryIdentifier = "overtime_notification"
        
        let continueWorkingAction = UNNotificationAction(identifier: "continue_working", title: "Continue", options: [])
        let stopWorkingAction = UNNotificationAction(identifier: "stop_working", title: "Sign Out", options: [.destructive,.foreground])
        let overtimeCategory = UNNotificationCategory(identifier: "overtime_notification", actions: [continueWorkingAction, stopWorkingAction], intentIdentifiers: [], options: [.customDismissAction])
        
        center.setNotificationCategories([overtimeCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: "initial_notification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling initial notification: \(error)")
            } else {
                print("Initial notification scheduled successfully")
            }
        }
    }
    
    func showNotificationPermissionAlert() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Notifications Permission", message: "Notification permission is required to schedule the initial notification. Do you want to go to the app's settings to enable notifications?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                let notificationSettingsURL = URL(string: UIApplication.openSettingsURLString)!.appendingPathComponent("notification")
                UIApplication.shared.open(notificationSettingsURL, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            windowScene.windows.first!.rootViewController?.present(alert, animated: true, completion: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didBecomeActive() {
        checkNotificationPermission { granted in
            if granted {
                self.scheduleDailyNotification()
                self.scheduleInitialNotification()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "sign_in" {
            
            let scene = UIApplication.shared.connectedScenes.first!
            if let windowScene = scene as? UIWindowScene {
                let window = windowScene.windows.first!
                window.rootViewController = UIHostingController(rootView: MotherView().environmentObject(ViewRouter.shared))
                window.makeKeyAndVisible()
            }
        }
        if response.actionIdentifier == "continue_working" {
            scheduleRenotification()
            
        } else if response.actionIdentifier == "stop_working" {
            
            UserProfileRepository().isLoggedOut(userId: Auth.auth().currentUser!.uid)
            { success in
                if success {
                    do {
                        
                        try Auth.auth().signOut()
                        
                        let scene = UIApplication.shared.connectedScenes.first!
                        if let windowScene = scene as? UIWindowScene {
                            let window = windowScene.windows.first!
                            window.rootViewController = UIHostingController(rootView: MotherView().environmentObject(ViewRouter.shared))
                            window.makeKeyAndVisible()
                        }
                        
                        print("User successfully signed out after notification response")
                        
                    } catch {
                        print("Error signing out user after notification response")
                    }
                }
                
            }
            completionHandler()
        }
    }
    
    func scheduleRenotification() {
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Are you still working overtime?"
        content.body = "Do you want to continue working?"
        content.sound = .default
        content.categoryIdentifier = "overtime_notification"
        
        let continueWorkingAction = UNNotificationAction(identifier: "continue_working", title: "Continue", options: [])
        let stopWorkingAction = UNNotificationAction(identifier: "stop_working", title: "Sign Out", options: [.destructive, .foreground])
        let overtimeCategory = UNNotificationCategory(identifier: "overtime_notification", actions: [continueWorkingAction, stopWorkingAction], intentIdentifiers: [], options: [.customDismissAction])
        
        center.setNotificationCategories([overtimeCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1 * 60 * 60, repeats: true)
        
        let request = UNNotificationRequest(identifier: "renotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling renotification: \(error)")
            } else {
                print("Renotification scheduled successfully")
            }
        }
    }
}

func registerNotificationDelegate() {
    let center = UNUserNotificationCenter.current()
    center.delegate = NotificationDelegate.shared
}


