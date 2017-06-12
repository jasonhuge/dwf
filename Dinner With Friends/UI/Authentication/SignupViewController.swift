//
//  SignupViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField:UITextField?
    @IBOutlet weak var continueButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onContinueButtonTap(_ sender: Any) {
        
        guard let emailTextField = self.emailTextField else {
            return;
        }
        
        guard let passwordTextField = self.passwordTextField else {
            return;
        }
        
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            FirebaseAuthService.sharedInstance.createUserWith(email: email, password: password, completionBlock: { success, error in
                if success {
                    self.createUserProfile()
                } else {
                    print(error!)
                }
            });
        }
        
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
        AppSettings.setUser(loggedIn: true)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showMainStoryboard()
        }
    }
}
