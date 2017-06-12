//
//  FacebookService.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookService {
    static let sharedInstance = FacebookService()
    
    func facebookAuthToken() ->String? {
        var token:String?
        
        if let accessToken = FBSDKAccessToken.current() {
            token = accessToken.tokenString;
        }
        
        return token;
    }
    
    func loginFrom(viewController:UIViewController, loginBehavior:FBSDKLoginBehavior? = .systemAccount, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        let loginManager = FBSDKLoginManager.init()
        
        if let unwrappedLoginBehavior = loginBehavior {
            loginManager.loginBehavior = unwrappedLoginBehavior
        }
        
        loginManager.logIn(withReadPermissions: ["public_profile", "user_friends", "email"], from: viewController, handler: { (result, error) -> Void in
            
            if error != nil {
                completionBlock(false, error)
            } else {
                guard let unwrappedResult = result else {
                    let unknownError = NSError.init(domain: "login", code: 1010, userInfo: ["localizedDescription":"unknown error occured logging in with facebook"])
                    
                    completionBlock(false, unknownError)
                    
                    return;
                }
                
                if unwrappedResult.isCancelled {
                    let unknownError = NSError.init(domain: "login", code: 1010, userInfo: ["localizedDescription":"user canceled login with facebook"])
                    
                    completionBlock(false, unknownError)

                } else if unwrappedResult.grantedPermissions.contains("email") {
                    completionBlock(true, nil)
                } else {
                    let unknownError = NSError.init(domain: "login", code: 1010, userInfo: ["localizedDescription":"unknown error occured logging in with facebook"])
                    
                    completionBlock(false, unknownError)
                }
            }
        })
    }
    
}
