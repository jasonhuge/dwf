//
//  MeViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit


class MeViewController: UserProfileViewController {
    
    @IBOutlet weak var familyStackView:UIStackView?
    
    //MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setupFamilyStackView()
        
        var userName = "What's your name?"
        
        if let user = FirebaseAuthService.sharedInstance.currentUser() {
            if let unwrappedDisplayName = user.displayName {
                userName = unwrappedDisplayName;
            }
        }
        
        self.userNameTextField?.text = userName
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUserProfileUpdated), name:Notification.Name(FirebaseDatabaseNotifications.userProfileHasUpdated), object: nil)
        
        FirebaseDatabaseService.sharedInstance.loadUserProfile()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func userAvatarURL() ->String? {
        var avatarURL:String?
        
        if let user = FirebaseAuthService.sharedInstance.currentUser(), let photoURL = user.photoURL {
            avatarURL = photoURL.absoluteString
        }
        
        return avatarURL
    }
    
    override func addAllergies() {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "SelectAllergiesViewController") as? SelectAllergiesViewController {
            vc.isForUser = true
            vc.userProfile = FirebaseDatabaseService.sharedInstance.userProfile
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func addDietaryPreferences() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "SelectDietaryPrefsViewController") as? SelectDietaryPrefsViewController {
            vc.isForUser = true
            vc.userProfile = FirebaseDatabaseService.sharedInstance.userProfile
            self.present(vc, animated: true, completion: nil)
        }
    }

    
    func setupFamilyStackView() {
        
        guard let unwrappedStackView = self.familyStackView else {
            print("family stackview is nil")
            return
        }
        
        unwrappedStackView.translatesAutoresizingMaskIntoConstraints = false
        unwrappedStackView.topAnchor.constraint(equalTo: unwrappedStackView.superview!.topAnchor).isActive = true
        unwrappedStackView.bottomAnchor.constraint(equalTo: unwrappedStackView.superview!.bottomAnchor).isActive = true
        unwrappedStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        unwrappedStackView.centerXAnchor.constraint(equalTo: unwrappedStackView.superview!.centerXAnchor).isActive = true
        
    }
    
    func updateFamilyStackView() {
        
        guard let unwrappedStackView = self.familyStackView else {
            print("family stackview is nil")
            return
        }
        
        for view in unwrappedStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for familyMember in FirebaseDatabaseService.sharedInstance.userProfile.familyMembers {
            let memberButton = FamilyMemberButton.init()
            memberButton.translatesAutoresizingMaskIntoConstraints = false
            
            unwrappedStackView.addArrangedSubview(memberButton)
            
            memberButton.widthAnchor.constraint(equalTo: self.familyStackView!.heightAnchor).isActive = true
            memberButton.heightAnchor.constraint(equalTo: self.familyStackView!.heightAnchor).isActive = true
            
            memberButton.setupWith(familyMember: familyMember)
            
            memberButton.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.onFamilyMemberButtonTap)))
            
            //memberButton.addTarget(self, action: #selector(self.onFamilyMemberButtonTap), for: .touchUpInside)
            
            
        }
    }
    
    func addEditFamilyMember(isEditing:Bool, familyMember:FamilyMember?) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "AddEditFamilyMemberViewController") as? AddEditFamilyMemberViewController {
            vc.isEditingFamilyMember = isEditing
            
            if let unwrappedFamilyMember = familyMember {
                vc.familyMember = unwrappedFamilyMember
            }
            
            self.present(vc, animated: true, completion: nil)
        }
    }
 
    //MARK - Notifications
    func onUserProfileUpdated(notification:NSNotification) {
        self.tableView.reloadData()
        self.updateFamilyStackView();
    }
    
    func onFamilyMemberButtonTap(_ sender:UITapGestureRecognizer) {
        
        guard let button = sender.view as? FamilyMemberButton else {
            return
        }
        
        if let familyMember = FirebaseDatabaseService.sharedInstance.userProfile.familyMemberFor(uid:button.uid) {
            self.addEditFamilyMember(isEditing: true, familyMember: familyMember)
        }
    }
    
    @IBAction func onAddFamilyMemberBtnTap(_ sender: UIButton) {
        self.addEditFamilyMember(isEditing: false, familyMember: nil)
        
    }
    
}

//MARK: TableViewDatasource + Delegate
extension MeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0;
        
        if section == 0 {
            numRows = FirebaseDatabaseService.sharedInstance.userProfile.allergies.count
        } else if section == 1 {
            numRows = FirebaseDatabaseService.sharedInstance.userProfile.dietaryPrefs.count
        }
        
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meTableViewCell")
        
        if indexPath.section == 0 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(allergy: FirebaseDatabaseService.sharedInstance.userProfile.allergies[indexPath.row])
            }
        } else if indexPath.section == 1 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(dietaryPref: FirebaseDatabaseService.sharedInstance.userProfile.dietaryPrefs[indexPath.row])
            }
        }
        
        return cell!
    }
}


