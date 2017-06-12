//
//  AddEditFamilyMemberViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/31/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class AddEditFamilyMemberViewController: UserProfileViewController {

    @IBOutlet weak var saveButton: UIButton!
    
    var isEditingFamilyMember = false
    var familyMember = FamilyMember()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.userNameTextField.attributedPlaceholder = NSAttributedString(string: "Enter a name", attributes: [NSForegroundColorAttributeName : UIColor.black])
        
        
        if !self.isEditingFamilyMember {
            if let user = FirebaseAuthService.sharedInstance.currentUser() {
                self.familyMember.uid = NSUUID().uuidString
                self.familyMember.memberuid = user.uid
            }
        } else {
            self.userNameTextField.text = self.familyMember.displayName
        }
        
        self.setupUserAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func userAvatarURL() -> String? {
        var url:String?
        
        if familyMember.photoURL.characters.count > 0 {
            url = familyMember.photoURL
        }
        
        return url
    }
    
    override func addAllergies() {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "SelectAllergiesViewController") as? SelectAllergiesViewController {
            vc.userProfile = self.familyMember
            vc.isForUser = false
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func addDietaryPreferences() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let vc = storyBoard.instantiateViewController(withIdentifier: "SelectDietaryPrefsViewController") as? SelectDietaryPrefsViewController {
            vc.userProfile = self.familyMember
            vc.isForUser = false
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func onUserProfileUpdated() {
       
        self.tableView.reloadData()
    }
    
        
    func saveFamilyMember() {
        
        guard let user = FirebaseAuthService.sharedInstance.currentUser() else {
            print("AddEditFailyMember has no currentUser")
            return
        }
        
        if let userName = self.userNameTextField.text {
            if userName != self.familyMember.displayName {
                self.familyMember.displayName = userName
            }
        }
        
        if self.isEditingFamilyMember {
            FirebaseDatabaseService.sharedInstance.userProfile.updateFamilyMemberWith(familyMember:familyMember)
            FirebaseDatabaseService.sharedInstance.userUpdate(familyMember: self.familyMember)
        } else {
            FirebaseDatabaseService.sharedInstance.userProfile.add(familyMember: familyMember)
            FirebaseDatabaseService.sharedInstance.userAdd(familyMember: self.familyMember)
        }
        
        
        
        self.onCloseButtonTap()

    }
    
    //MARK - Notifications
    @IBAction func onSaveButtonTap(_ sender: UIButton) {
        
        if self.hasUpdateProfileImage {
            self.saveProfileImage(completionBlock: {[weak self] (success, imageURL) in
                
                if let unwrappedImageURL = imageURL {
                    self?.familyMember.photoURL = unwrappedImageURL
                }
                
                self?.hasUpdateProfileImage = false
                
                self?.saveFamilyMember()
            })
        } else {
            self.saveFamilyMember()
        }

    }
    
    @IBAction func onCloseButtonTap() {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: TableViewDatasource + Delegate
extension AddEditFamilyMemberViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0;
        
        if section == 0 {
            numRows = self.familyMember.allergies.count
        } else if section == 1 {
            numRows = self.familyMember.dietaryPrefs.count
        }
        
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meTableViewCell")
        
        if indexPath.section == 0 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(allergy: self.familyMember.allergies[indexPath.row])
            }
        } else if indexPath.section == 1 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(dietaryPref: self.familyMember.dietaryPrefs[indexPath.row])
            }
        }
        
        return cell!
    }
}
