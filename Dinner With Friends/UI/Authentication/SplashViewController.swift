//
//  SplashViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navController.navigationBar.shadowImage = UIImage()
            navController.navigationBar.isTranslucent = true
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInWithTwitter(_ sender: Any) {
        FirebaseAuthService.sharedInstance.createUserWithTwitterFrom(viewController: self, completionBlock: { (success, error) in
            if error != nil {
                
            } else {
                self.createUserProfile()
            }
        })
    }
    
    @IBAction func signInWithFacebook(_ sender: Any) {
        FirebaseAuthService.sharedInstance.createUseWithFacebookFrom(viewController: self, completionBlock: { (success, error) in
            if error != nil {
                
            } else {
                self.createUserProfile()
            }
        })
    }
    
    func createUserProfile() {
        if let currentUser = FirebaseAuthService.sharedInstance.currentUser() {
            let userProfile = UserProfile();
            userProfile.uid = currentUser.uid
            
            if let displayName = currentUser.displayName {
                userProfile.displayName = displayName
            }
            
            if let photoURL = currentUser.photoURL {
                userProfile.photoURL = photoURL.absoluteString
            }
            
            FirebaseDatabaseService.sharedInstance.add(user: userProfile)
            
            self.completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        
        AppSettings.setOnboarding(complete: true)
    
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showMainStoryboard()
        }
    }
    
}
