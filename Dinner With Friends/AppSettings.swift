//
//  AppSettings.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/9/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

struct AppSettingsKeys {
    static let onboardingComplete = "onboardingComplete"
    static let userLoggedIn = "userLoggedIn"
}

class AppSettings {
    
    static func clearUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    static func setUserDefaults(object:Any, forKey:String) {
        UserDefaults.standard.set(object, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    static func getUserDefaultsObjectFor(key:String) -> Any? {
        
        var objectToReturn:Any?
        
        if let object = UserDefaults.standard.object(forKey: key) {
            objectToReturn = object
        }
        
        return objectToReturn
    }
    
    static func setOnboarding(complete:Bool) {
        UserDefaults.standard.set(complete, forKey: AppSettingsKeys.onboardingComplete)
        UserDefaults.standard.synchronize();
    }
    
    static func isOnboardingComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: AppSettingsKeys.onboardingComplete)
    }
    
    static func setUser(loggedIn:Bool) {
        UserDefaults.standard.set(loggedIn, forKey: AppSettingsKeys.userLoggedIn)
        UserDefaults.standard.synchronize();
    }
    
    static func isUserLoggedIn() ->Bool {
        return UserDefaults.standard.bool(forKey: AppSettingsKeys.userLoggedIn)
    }
    
    
    
    
    
    
    
    
}
