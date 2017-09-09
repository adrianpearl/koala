//
//  AppDelegate.swift
//  koala
//
//  Created by Adrian Pearl on 1/3/16.
//  Copyright © 2016 Adrian Pearl. All rights reserved.
//

import UIKit
import CoreLocation
//import Bean_iOS_OSX_SDK

let CatID = "KOALA_CATEGORY"
let AddID = "ADD_ACTION"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private enum exerciseClass {
        case Cardio
        case Selectraise
    }
    
    private var knownExerciseClasses = [String:exerciseClass]()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let joinDate = NSCalendar.currentCalendar().dateByAddingUnit([.Day], value: -10, toDate: NSDate(), options: [])!
        let dateOfWorkouts = NSCalendar.currentCalendar().dateByAddingUnit([.Day], value: -1, toDate: NSDate(), options: [])!
        let date2 = NSCalendar.currentCalendar().dateByAddingUnit([.Day], value: -2, toDate: NSDate(), options: [])!
        let date3 = NSCalendar.currentCalendar().dateByAddingUnit([.Day], value: -4, toDate: NSDate(), options: [])!
        let date4 = NSCalendar.currentCalendar().dateByAddingUnit([.Day], value: -7, toDate: NSDate(), options: [])!
        koalaUser.dateJoined = joinDate
        
        knownExerciseClasses["Treadmill"] = exerciseClass.Cardio
        knownExerciseClasses["Leg Press"] = exerciseClass.Selectraise
        knownExerciseClasses["Chest Press"] = exerciseClass.Selectraise
        knownExerciseClasses["Bicep Curl"] = exerciseClass.Selectraise
        knownExerciseClasses["Upright Row"] = exerciseClass.Selectraise
        
        let exercise1 = TreadmillExercise(start: dateOfWorkouts, duration: 25, revDistance: 12, intervals: [1.2, 2.4, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.5, 13.6, 14.7, 15.8, 16.9, 18.0, 19.1, 20.2, 21.4, 22.6, 23.8], stats: [0, 0, 0, 0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 7, 7, 7, 7, 5, 2])
        let exercise2 = StackweightExercise(name: "Leg Press", start: dateOfWorkouts, duration: 19, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        let exercise3 = StackweightExercise(name: "Chest Press", start: dateOfWorkouts, duration: 15, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        let exercise4 = StackweightExercise(name: "Bicep Curl", start: dateOfWorkouts, duration: 10, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        
        let exercise5 = StackweightExercise(name: "Upright Row", start: date2, duration: 15, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        let exercise6 = TreadmillExercise(start: date2, duration: 25, revDistance: 12, intervals: [1.2, 2.4, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.5, 13.6, 14.7, 15.8, 16.9, 18.0, 19.1, 20.2, 21.4, 22.6, 23.8], stats: [0, 0, 0, 0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 7, 7, 7, 7, 5, 2])
        
        let exercise7 = TreadmillExercise(start: date3, duration: 40, revDistance: 12, intervals: [1.2, 2.4, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.5, 13.6, 14.7, 15.8, 16.9, 18.0, 19.1, 20.2, 21.4, 22.6, 23.8], stats: [0, 0, 0, 0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 7, 7, 7, 7, 5, 2])
        
        let exercise8 = StackweightExercise(name: "Bicep Curl", start: date4, duration: 40, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        let exercise9 = StackweightExercise(name: "Chest Press", start: date4, duration: 10, intervals: [2, 4, 6, 8, 11, 14, 17, 20, 23, 27, 31, 35, 39, 43, 47, 51, 55, 57, 59], stats: [10, 10, 10, 15, 15, 15, 20, 20, 20, 20, 20, 20, 20, 20, 25, 25, 25, 25, 25])
        
        koalaUser.exercises.append(exercise9)
        koalaUser.exercises.append(exercise8)
        koalaUser.exercises.append(exercise7)
        koalaUser.exercises.append(exercise6)
        koalaUser.exercises.append(exercise5)
        koalaUser.exercises.append(exercise4)
        koalaUser.exercises.append(exercise3)
        koalaUser.exercises.append(exercise2)
        koalaUser.exercises.append(exercise1)
        // Override point for customization after application launch.
        
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.titleTextAttributes = [NSFontAttributeName: UIFont(name: "CenturyGothic", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBarAppearance.translucent = false
        navBarAppearance.barStyle = .BlackTranslucent
        navBarAppearance.barTintColor = UIColor(red: 64 / 255, green: 149 / 255, blue: 246 / 255, alpha: 1.0)
        
        setupNotifications()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        // koalaUser.saveData()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func setupNotifications() {
        
        let addAction = UIMutableUserNotificationAction()
        addAction.identifier = AddID
        addAction.title = "Yes!"
        addAction.activationMode = UIUserNotificationActivationMode.Background
        addAction.authenticationRequired = false
        addAction.destructive = false
        
        let ignoreAction = UIMutableUserNotificationAction()
        ignoreAction.identifier = "IGNORE_ACTION"
        ignoreAction.title = "Nope"
        ignoreAction.activationMode = UIUserNotificationActivationMode.Background
        ignoreAction.authenticationRequired = false
        ignoreAction.destructive = false
        
        // Category
        let koalaCategory = UIMutableUserNotificationCategory()
        koalaCategory.identifier = CatID
        
        // A. Set actions for the default context
        koalaCategory.setActions([addAction, ignoreAction], forContext: UIUserNotificationActionContext.Default)
        
        // B. Set actions for the minimal context
        koalaCategory.setActions([addAction, ignoreAction], forContext: UIUserNotificationActionContext.Minimal)
        let categories: Set = Set(arrayLiteral: koalaCategory)
        
        let types = UIUserNotificationType.Alert
        let settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if notification.category == CatID && identifier == AddID {
            BLEManager.sharedInstance.connect(notification)
        }
        
        completionHandler()
    }
    
}

