//
//  AppDelegate.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // setup location mananger
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // setup local notification.
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.delegate = self
        setupGeofencingNotification()
        return true
    }
    
}

extension AppDelegate: CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    func setupGeofencingNotification(){
        notificationCenter.getNotificationSettings {[weak self] (notificationSetting) in
            let authorisationStatus = notificationSetting.authorizationStatus
            if authorisationStatus == .notDetermined {
                self?.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                    if success {
                        print("this is success")
                    }
                }
            }else if authorisationStatus == .authorized{
                //self?.scheduleLocationNotification()
            }else if authorisationStatus == .denied{
                Utility.showAlert(in: (self!.window?.rootViewController)!, title: Strings.kError, message:Strings.kAllowNotificationAccess )
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge,.alert])
    }
    

    
}


