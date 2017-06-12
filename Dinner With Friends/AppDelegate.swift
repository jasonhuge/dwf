//
//  AppDelegate.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import TwitterKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //FIROptions.default()?.deepLinkURLScheme = "com.1976.Dinner-With-Friends"
        
        FirebaseApp.configure()
        
        if !Database.database().isPersistenceEnabled {
            Database.database().isPersistenceEnabled = true
        }
        
        FirebaseDatabaseService.sharedInstance.configure()
        
        //FirebaseAuthService.sharedInstance.logoutUser()
        
        let twitterKey = Bundle.main.object(forInfoDictionaryKey: "TwitterConsumerKey")
        let twitterSecret = Bundle.main.object(forInfoDictionaryKey: "TwitterConsumerSecret")
        
        if let twitterKey = twitterKey as? String, let twitterSecret = twitterSecret as? String {
            Twitter.sharedInstance().start(withConsumerKey: twitterKey, consumerSecret: twitterSecret)
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
        
        if FirebaseAuthService.sharedInstance.hasCurrentUser() {
            self.showMainStoryboard()
        } else {
            self.showAuthStoryboard()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataController.sharedInstance.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        var returnType = false
        
        if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncoming(dynamiclink: dynamicLink)
            returnType = true
        } else {
            returnType = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String!, annotation: options[.annotation])

        }
        
        return returnType
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       


        
        /*let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }*/
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
            return false
        }
        guard let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        let handled = dynamicLinks.handleUniversalLink(incomingURL) { (dynamiclink, error) in
            if error != nil {
                
            } else {
                if let link = dynamiclink {
                    self.handleIncoming(dynamiclink: link)
                }
            }
        }
        
        
        return handled
    }
    
    func handleIncoming(dynamiclink:DynamicLink) {
        print("here is a link \(String(describing: dynamiclink.url))")
        
        guard let pathComponents = dynamiclink.url?.pathComponents else {
            return
        }
        
        for component in pathComponents {
            
        }
    }
    
    func showAuthStoryboard() {
        let auth = UIStoryboard.init(name: "Authentication", bundle: nil)
        
        self.window?.rootViewController = auth.instantiateInitialViewController()
    }
    
    func showMainStoryboard() {
        let main = UIStoryboard.init(name: "Main", bundle: nil)
        
        self.window?.rootViewController = main.instantiateInitialViewController()
    }

}

