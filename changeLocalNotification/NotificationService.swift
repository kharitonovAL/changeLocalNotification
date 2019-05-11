//
//  NotificationService.swift
//  changeLocalNotification
//
//  Created by Aleksey Kharitonov on 11/05/2019.
//  Copyright © 2019 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Shared Instance
    
    static let shared = NotificationService()
    
    // MARK: - Define UNUserNotificationCenter instance
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Setup notification's user request
    
    func userRequest(_ completed: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
                completed(false)
                
            } else {
                print("User has accepted notifications")
                self.notificationCenter.delegate = self
                completed(true)
            }
            
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
    // 1
    /// We define a method that takes a tuple with two String parameters.
    ///
    /// - Parameters:
    ///   - item: Tuple with two text parameters.
    ///   - showBody: showBody is a parameter with a Bool type, and it allows us to show or hide the subtext in our notification.
    ///   - withAction: withAction is also a Bool type parameter, and it uses to hide action button if "Show me" action was hited.
    ///   - date: atDate date - is a Date type parameter, and we use it to scheldue a trigger for our notification.
    func showNotification(with item: (String, String), showBody: Bool, withAction: Bool, atDate date: Date) {
        // 2
        // Here we define our content instance
        let content = UNMutableNotificationContent()
        
        // 3
        // Assigning an identifier for our action
        let userActionsIdentifier = "showMe"
        
        // 4
        // Set our main text to notification.
        content.title = item.0
        
        // 5
        // For the first call of this method, I set showBody parameter
        // to false, so user can't see it in notification.
        if showBody { content.body = item.1 }
        
        // 6
        // Here is the most important part - I assign to content's
        // userInfo parameter the item with main text and subtext.
        content.userInfo = [item.0: item.1]
        content.sound = UNNotificationSound.default
        
        // 7
        // At first call of this method I set withAction parameter to
        // true, to let user be able to hit the "Show me" button.
        // To do this, we sets the categoryIdentifier parameter.
        if withAction { content.categoryIdentifier = userActionsIdentifier }
        
        // 8
        // Every notification need a unic identifier, so they won't
        // replace each othe in the queue.
        let notificationID = item.0
        
        // 9
        // Define a date parameters to use appropriate trigger in next.
        // In this case I'm using only hour, minute and second
        // from date.
        var dc = DateComponents()
        dc.hour = Calendar.current.component(.hour, from: date)
        dc.minute = Calendar.current.component(.minute, from: date)
        dc.second = Calendar.current.component(.second, from: date)
        
        // 10
        // Define our trigger. You can use other triggers, but in this
        // case I used UNCalendarNotificationTrigger.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
        
        // 11
        // Define our notification's request with identifier,
        // content and trigger.
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // 12
        // Add our request to notificationCenter, and also
        // handling errors.
        notificationCenter.add(request) { (error) in
            error == nil ? print("notifacation request was added at ", trigger.nextTriggerDate()!) :
                           print(error.debugDescription)
        }
        
        // 13
        // Define our action. It will create a button that user can
        // hit and see our subtext. We define it's identifier and title.
        // Options are unused.
        let action = UNNotificationAction(identifier: "showMe", title: "Show me", options: [])
        
        // 14
        // Define our category for notification, which includes
        // our action.
        let category = UNNotificationCategory(identifier:userActionsIdentifier, actions: [action],
                                              intentIdentifiers: [], options: [])
        
        // 15
        // Finaly, add our category to notificationCenter.
        notificationCenter.setNotificationCategories([category])
    }
    
    // MARK: - Delegates Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("... notification presented")        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("didReceive response")
        
        // 1
        // With switch operator I'm catching an action's identifier
        switch response.actionIdentifier {
        case "showMe":
            print("showMe action")
            
            // 2
            // Here we get our userInfo's data that we passed in showNotificationlet method on stage 6 and cast it
            // to String type.
            let mainText = response.notification.request.content.userInfo.keys.first! as! String
            
            // 3
            // Here we again get our userInfo's data that we passed in showNotificationlet method on stage 6 and cast it
            // to String again.
            let subText = response.notification.request.content.userInfo.values.first! as! String
            
            // 4
            // Here I call our method with new parameters: showBody now is true, and withAction is false
            // (just because there is no need in action any more).
            self.showNotification(with: (mainText, subText), showBody: true, withAction: false,
                                  atDate: Date(timeIntervalSinceNow: 2))
            
        default:
            print("defaul action")
        }
        
        completionHandler()
    }

}
