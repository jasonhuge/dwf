//
//  FirebaseService.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit

enum AuthProvider {
    case email
    case anonymous
    case facebook
    case twitter
    case google
}

class FirebaseAuthService {
    static let sharedInstance = FirebaseAuthService();
    
    func hasCurrentUser() -> Bool {
        return ((Auth.auth().currentUser) != nil)
    }
    
    func currentUser() -> User? {
        return (Auth.auth().currentUser)
    }
    
    func requestPasswordResetWith(email:String, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if let error = error {
                completionBlock(false, error)
            } else {
                completionBlock(true, nil)
            }
        })
    }
    
    //MARK: Login / out Methods
    func loginUserWith(credentials:AuthCredential, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        if let user = Auth.auth().currentUser {
            user.link(with: credentials, completion: { (user, error) in
                if let error = error {
                    completionBlock(false, error)
                } else {
                    completionBlock(true, nil)
                }
            })
        } else {
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if let error = error {
                    completionBlock(false, error)
                } else {
                    completionBlock(true, nil)
                }
            })
        }
    }
    
    func loginUserWith(email:String, password:String, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                completionBlock(false, error)
            } else {
                completionBlock(true, nil)
            }
        })
    }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print(signOutError)
        }
    }
    
    //MARK: User Creation Methods
    func createUserWith(email:String, password:String, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                completionBlock(false, error)
            } else {
                completionBlock(true, nil)
            }
        })
    }
    
    func createUseWithFacebookFrom(viewController:UIViewController, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "user_friends", "email"], from: viewController, handler: { (result, error) in
            
            if let error = error {
                completionBlock(false, error)
            } else if result!.isCancelled {
                let customError = NSError.init(domain: "login", code: 1010, userInfo: ["localizedDescription":"user canceled login with facebook"])
                
                completionBlock(false, customError)
            } else {
                let credentials = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.loginUserWith(credentials: credentials, completionBlock: { (success, error) in
                    if let error = error {
                        completionBlock(false, error)
                    } else {
                        completionBlock(true, nil)
                    }
                })
            }
        })
    }
    
    func createUserWithTwitterFrom(viewController:UIViewController, completionBlock:@escaping ((Bool, Error?) -> Void)) {
        Twitter.sharedInstance().logIn(with: viewController, completion: { (session, error) in
            if let session = session {
                let credentials = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                
                self.loginUserWith(credentials: credentials, completionBlock: { (success, error) in
                    if let error = error {
                        completionBlock(false, error)
                    } else {
                        completionBlock(true, nil)
                    }
                })
            } else if let error = error {
                completionBlock(false, error)
            } else {
                let customError = NSError.init(domain: "login", code: 1010, userInfo: ["localizedDescription":"unknown error logging in with twitter"])
                
                completionBlock(false, customError)
            }
        })
    }
}
