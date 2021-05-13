//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Apollo Callero on 4/3/21.
//
import CoreData
import UIKit
import Firebase
import FirebaseFirestore
@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func applicationDidEnterBackground(_ application: UIApplication){
        print("enetered backgroiund")
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //for notifiactions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.badge,.sound],completionHandler: { (granted, error) in
            
        })
        
        UNUserNotificationCenter.current().delegate = self
        // Override point for customization after application launch.
        UITabBar.appearance().barTintColor = .lightGray
        UITabBar.appearance().tintColor = .blue
        
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        // Do stuff with response here (non-blocking)
        let navVC = UIApplication.shared.windows.first!.rootViewController as! UITabBarController
        let vcs = navVC.viewControllers
        for vc in vcs! {
            if let mainVC = vc as? TimerVC {
                print("found vc")
                mainVC.handleNotification(response)
        }
        completionHandler()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        let navVC = UIApplication.shared.windows.first!.rootViewController as! UITabBarController
        let vcs = navVC.viewControllers
        for vc in vcs! {
            if let mainVC = vc as? TimerVC {
                print("found vc with app open")
                mainVC.notificationAppOpen()
        }
    }
    
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LeaderBoardData")
        container.loadPersistentStores(completionHandler: {(storDescription,error) in
            if let error = error as NSError?{
                fatalError("unresolved error \(error) , \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            }catch{
                let nserror = error as NSError
                fatalError("unresolved error \(nserror) , \(nserror.userInfo)")
            }
        }
    }
}
