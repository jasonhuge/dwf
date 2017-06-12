//
//  UserProfile.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/16/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class UserProfile: DWFModel {
    var uid = ""
    var photoURL = ""
    var displayName = ""
    var firstName = ""
    var lastName = ""
    var allergies:Array <Allergy> = []
    var dietaryPrefs:Array <DietaryPref> = []
    var familyMembers:Array <FamilyMember> = []
    
    //MARK - Parse data types
    override func parseArray(key:String, array:NSArray) {
        
        for item:Any in array {
            if key == "allergies" {
                if let item = item as? NSDictionary {
                    self.parse(allergyDict: item)
                }
            } else if key == "dietary-preferences" {
                if let item = item as? NSDictionary {
                    self.parse(dietaryDict: item);
                }
            }
        }
        
    }
    
    //MARK - Update
    
    
    override func updateWith(rawData: NSDictionary) {
        
        for (key, value) in rawData {
            
            if let key = key as? String {
                
                if let value = value as? NSDictionary {
                    if key == "allergies"  {
                        self.parse(allergyDict:value)
                    } else if key == "dietary-preferences" {
                        self.parse(dietaryDict: value)
                    } else {
                        self.parseDictionary(dict: value)
                    }
                } else if let value = value as? NSArray {
                    self.parseArray(key:key, array: value)
                } else {
                    
                    self.set(key: key, value: value)
                }
            }
        }
    }
}

//MARK - Allergies
extension UserProfile {
    
    func parse(allergyDict:NSDictionary) {
        let allergy = Allergy.init(rawData: allergyDict)
        
        if let loadedAllergy = FirebaseDatabaseService.sharedInstance.allergyFor(id: allergy.id) {
            allergy.name = loadedAllergy.name
        }
        
        self.add(allergy: allergy)
    }
    
    func add(allergy:Allergy) {
        if !self.hasAllergyFor(allergyID: allergy.id) {
            self.allergies.append(allergy)
        }
    }
    
    func remove(allergy:Allergy) {
        
        let filtered = self.allergies.filter { (savedAllergy) -> Bool in
            var keep = true
            
            if savedAllergy.id == allergy.id {
                keep = false
            }
            
            return keep
            
        }
        
        self.allergies = filtered
    }
    
    func hasAllergyFor(allergyID:Int) ->Bool {
        let filtered = self.allergies.filter({ (savedAllergy) -> Bool in
            var has = false
            
            if savedAllergy.id == allergyID {
                has = true
            }
            
            return has
        })
        
        return filtered.count > 0 ? true : false
    }
}

//MARK Dietary Prefs
extension UserProfile {
    
    func parse(dietaryDict:NSDictionary) {
        let dietaryPref = DietaryPref.init(rawData: dietaryDict)
        
        if let loadedDietaryPref = FirebaseDatabaseService.sharedInstance.dietaryPrefFor(id: dietaryPref.id) {
            dietaryPref.name = loadedDietaryPref.name
        }
        
        self.add(dietaryPref: dietaryPref)
    }

    func add(dietaryPref:DietaryPref) {
        if !self.hasDietaryPrefFor(dietaryPrefID: dietaryPref.id) {
            self.dietaryPrefs.append(dietaryPref)
        }
    }
    
    func remove(dietaryPref:DietaryPref) {
        
        let filtered = self.dietaryPrefs.filter { (savedDietaryPref) -> Bool in
            var keep = true
            
            if savedDietaryPref.id == dietaryPref.id {
                keep = false
            }
            
            return keep
        }
        
        self.dietaryPrefs = filtered
    }
    
    func hasDietaryPrefFor(dietaryPrefID:Int) ->Bool {
        let filtered = self.dietaryPrefs.filter({ (savedDietaryPref) -> Bool in
            var has = false
            
            if savedDietaryPref.id == dietaryPrefID {
                has = true
            }
            
            return has
        })
        
        return filtered.count > 0 ? true : false
    }
}

//MARK - Family
extension UserProfile {
    
    func parse(familyMemberDict:NSDictionary) ->FamilyMember {
        let familyMember = FamilyMember.init()
        
        familyMember.updateWith(rawData: familyMemberDict)
        
        return familyMember
    }
    
    func updateWith(familyMembers:NSDictionary) {
        
        // We have added family members
        if familyMembers.count > self.familyMembers.count {
            for (_,value) in familyMembers {
                if let unwrappedValue = value as? NSDictionary, let uid = unwrappedValue["uid"] as? String {
                    if !self.hasFamilyMemberFor(familyMemberID: uid) {
                        let familyMember = self.parse(familyMemberDict: unwrappedValue)
                        self.add(familyMember: familyMember)
                    }
                }
            }
        } else if familyMembers.count < self.familyMembers.count {
            // We have deleted family members
            for familyMember in self.familyMembers {
                var keep = false
                for (_,value) in familyMembers {
                    if let unwrappedValue = value as? NSDictionary, let uid = unwrappedValue["uid"] as? String {
                        if uid == familyMember.uid {
                            keep = true
                        }
                    }
                }
                
                if !keep {
                    self.removeFamilyMemberFor(uid: familyMember.uid)
                }
            }
        } else {
            // We have updated family members
            for (_,value) in familyMembers {
                if let unwrappedValue = value as? NSDictionary, let uid = unwrappedValue["uid"] as? String {
                    if self.hasFamilyMemberFor(familyMemberID: uid) {
                        let familyMember = self.parse(familyMemberDict: unwrappedValue)
                        self.updateFamilyMemberWith(familyMember: familyMember)
                    }
                }
            }
        }
    }

    func add(familyMember:FamilyMember) {
        if !hasFamilyMemberFor(familyMemberID: familyMember.uid) {
            self.familyMembers.append(familyMember)
        }
    }
    
    func updateFamilyMemberWith(familyMember:FamilyMember) {
        let index = self.familyMembers.index { (savedFamilyMember) -> Bool in
            var has = false
            
            if savedFamilyMember.uid == familyMember.uid {
                has = true
            }
            
            return has
        }
        
        if let unwrappedIndex = index {
            self.familyMembers[unwrappedIndex] = familyMember
        }
    }
    
    func removeFamilyMemberFor(uid:String) {
        
        let filtered = self.familyMembers.filter { (savedFamilyMember) -> Bool in
            var keep = true
            
            if savedFamilyMember.uid == uid {
                keep = false
            }
            
            return keep
        }
        
        self.familyMembers = filtered
    }
    
    func hasFamilyMemberFor(familyMemberID:String) ->Bool {
        let filtered = self.familyMembers.filter({ (familyMember) -> Bool in
            var has = false
            
            if familyMember.uid == familyMemberID {
                has = true
            }
            
            return has
        })
        
        return filtered.count > 0 ? true : false
    }
    
    func familyMemberFor(uid:String) ->FamilyMember? {
        var familyMember:FamilyMember?
        
        let results = self.familyMembers.filter { (familyMember) -> Bool in
            
            var has = false
            
            if familyMember.uid == uid {
                has = true
            }
            
            return has
        }
        
        if results.count > 0 {
            familyMember = results.first
        }
        
        return familyMember
    }

}
