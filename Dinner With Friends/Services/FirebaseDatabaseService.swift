//
//  FirebaseDatabaseService.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/12/17.
//  Copyright © 2017 1976. All rights reserved.
//

import Firebase

enum AllergySensitivity {
    case sensative
    case alergic
}

enum PersonType {
    case user
    case family
}

struct FirebaseDatabaseNotifications {
    static let allergiesListHasUpdated = "AllergiesListHasUpdated"
    static let dietaryPreferencesListHasUpdated = "DietaryPreferencesListHasUpdated"
    static let userProfileHasUpdated = "UserProfileHasUpdated"
    static let userFamilyHasUpdated = "UserFamilyHasUpdated"
}


class FirebaseDatabaseService {
    static let sharedInstance = FirebaseDatabaseService.init();
    
    let reference = Database.database().reference()
    let allergiesRef = Database.database().reference(withPath: "allergies")
    let dietaryPrefsRef = Database.database().reference(withPath: "dietary-preferences")
    
    var userProfileRef:DatabaseReference?
    var familyRef:DatabaseReference?
    
    var allergies:Array <Allergy> = []
    var dietaryPrefs:Array <DietaryPref> = []

    
    var userProfile = UserProfile()
    
    //MARK - Setup
    func configure() {
        self.allergiesRef.keepSynced(true)
        self.dietaryPrefsRef.keepSynced(true)
        
        // load allergies
        _ = self.allergiesRef.observe(.value, with: { (snapshot) in
            self.allergies.removeAll()
            if let unwrappedValue = snapshot.value as? NSArray {
                for item:Any in unwrappedValue {
                    if let item = item as? NSDictionary {
                        let allergy = Allergy.init(rawData: item)
                        self.allergies.append(allergy)
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(FirebaseDatabaseNotifications.allergiesListHasUpdated), object: nil)
            }
        })
        
        //load dietary prefs
        _ = self.dietaryPrefsRef.observe(.value, with: { (snapshot) in
            self.dietaryPrefs.removeAll()
            
            if let unwrappedValue = snapshot.value as? NSArray {
                for item:Any in unwrappedValue {
                    if let item = item as? NSDictionary {
                        let dietaryPref = DietaryPref.init(rawData: item)
                        self.dietaryPrefs.append(dietaryPref)
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(FirebaseDatabaseNotifications.dietaryPreferencesListHasUpdated), object: nil)
            }
        
        })
        
        self.setupReferences()

    }
    
    func setupReferences() {
        guard let currentUser = FirebaseAuthService.sharedInstance.currentUser() else {
            print("no current user")
            return
        }
        
        if self.userProfileRef == nil {
            self.userProfileRef = Database.database().reference(withPath:"users/\(currentUser.uid)/")
            self.userProfileRef?.keepSynced(true)
        }
        
        if self.familyRef == nil {
            self.familyRef = Database.database().reference(withPath:"family-members/\(currentUser.uid)/")
            self.familyRef?.keepSynced(true)
        }
        
    }
    
    func loadUserProfile() {
        
        
        guard let userProfileRef = self.userProfileRef, let currentUser = FirebaseAuthService.sharedInstance.currentUser() else {
            print("no current user")
            return
        }
        
        userProfileRef.observe(.value, with: {[weak self] (snapshot) in
            
            if let userData = snapshot.value as? NSDictionary {
                
                self?.userProfile = UserProfile.init(rawData: userData)
                self?.userProfile.uid = currentUser.uid
                
                NotificationCenter.default.post(name: Notification.Name(FirebaseDatabaseNotifications.userProfileHasUpdated), object: nil)
                
                self?.loadFamilyMembersForUser()
            }
        })
        
    }
    
    func loadFamilyMembersForUser() {
        
        self.familyRef?.observe(.value, with: {[weak self] (snapshot) in
            
            if snapshot.exists() {
                if let familyMembers = snapshot.value as? NSDictionary {
                    self?.userProfile.updateWith(familyMembers: familyMembers)
                }
            } else {
                self?.userProfile.familyMembers.removeAll()
            }
            
            NotificationCenter.default.post(name: Notification.Name(FirebaseDatabaseNotifications.userProfileHasUpdated), object: nil)
            
        })
        
    }
    
    //MARK: Allergies
    func userProfileHasAllergyFor(id:NSInteger) ->Bool {
        let filteredArray = self.userProfile.allergies.filter { (allergy) -> Bool in
            allergy.id == id
        }
        return filteredArray.first != nil
    }
    
    func allergyFor(id:NSInteger) ->Allergy? {
        let filteredArray = self.allergies.filter { (allergy) -> Bool in
            allergy.id == id
        }
        return filteredArray.first
    }
    
    //MARK: DietaryPrefs
    func dietaryPrefFor(id:NSInteger) ->DietaryPref? {
        let filteredArray = self.dietaryPrefs.filter { (dietaryPref) -> Bool in
            dietaryPref.id == id
        }
        return filteredArray.first
    }
    
    func userProfileHasDietaryPrefFor(id:NSInteger) ->Bool {
        let filteredArray = self.userProfile.dietaryPrefs.filter { (dietaryPref) -> Bool in
            dietaryPref.id == id
        }
        return filteredArray.first != nil
    }
}


//MARK - ADD
extension FirebaseDatabaseService {
    
    func add(user:UserProfile) {
        self.userProfileRef?.setValue(user.dataAsDictionary())
    }
    
    func userProfileAdd(key:String, value:Any) {
        self.userProfileRef?.child(key).setValue(value)
    }
    
    func userAdd(familyMember:FamilyMember) {
        let uid = self.familyRef?.childByAutoId().key
        if let uid = uid {
            familyMember.uid = uid
            self.familyRef?.child("\(uid)/").setValue(familyMember.dataAsDictionary())
        }
    }
    
    func addAllergyFor(personeType:PersonType, uid:String, allergyid:Int, sensitivity:AllergySensitivity) {
        
        switch personeType {
        case .user:
            self.userProfileAdd(key:"allergies/\(allergyid)", value: ["id":allergyid, "sensitivity":sensitivity.hashValue])
            break
        case .family:
            
            self.userFamilyMembersAdd(key: "\(uid)/allergies/\(allergyid)", value: ["id":allergyid, "sensitivity":sensitivity.hashValue])
            break
        }
    }
    
    func addDietaryPrefFor(personeType:PersonType, uid:String, prefid:Int) {
        switch personeType {
        case .user:
            self.userProfileAdd(key:"dietary-preferences/\(prefid)", value: ["id":prefid])
            break
        case .family:
            self.userFamilyMembersAdd(key: "\(uid)/dietary-preferences/\(prefid)", value: ["id":prefid])
            break
        }
    }
    
    func userFamilyMembersAdd(key:String, value:Any) {
        self.familyRef?.child("\(key)").setValue(value)
    }
    
    func userAddFriend(uid:String) {
        self.userProfileAdd(key: "friends/", value: ["id":uid])
    }

}


//MARK - UPDATE
extension FirebaseDatabaseService {
    func update(user:UserProfile) {
        
    }
    
    func userUpdate(familyMember:FamilyMember) {
        self.userFamilyMembersUpdate(key: "\(familyMember.uid)/", value: familyMember.dataAsDictionary())
    }
    
    func userFamilyMembersUpdate(key:String, value:Any) {
        self.familyRef?.child("\(key)").updateChildValues(value as! [AnyHashable : Any])
    }

}


//MARK - REMOVE
extension FirebaseDatabaseService {
    
    func userProfileRemove(key:String) {
        self.userProfileRef?.child(key).removeValue()
    }
    
    func removeAllergyFor(personeType:PersonType, uid:String, allergyid:Int) {
        switch personeType {
        case .user:
            self.userProfileRemove(key: "allergies/\(allergyid)")
            break
        case .family:
            self.userFamilyMembersRemove(key: "\(uid)/allergies/\(allergyid)")
            break
        }
    }
    
    func removeDietaryPrefFor(personeType:PersonType, uid:String, prefid:Int) {
        switch personeType {
        case .user:
            self.userProfileRemove(key: "dietary-preferences/\(prefid)")
            break
        case .family:
            self.userFamilyMembersRemove(key: "\(uid)/dietary-preferences/\(prefid)")
            break
        }
    }
    
    func userRemoveFriend(uid:String) {
        
    }
    
    func userRemove(familyMember:FamilyMember) {
        self.familyRef?.child(familyMember.uid).removeValue()
    }
    
    func userFamilyMembersRemove(key:String) {
        self.familyRef?.child("\(key)").removeValue()
    }

}
