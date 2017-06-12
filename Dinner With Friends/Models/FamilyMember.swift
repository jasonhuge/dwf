//
//  FamilyMember.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 6/2/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class FamilyMember: UserProfile {
    var memberuid = ""
    
    override func dataAsDictionary() ->NSDictionary {
        var dict = self.dictionaryWithValues(forKeys: self.propertyNames())
        dict["uid"] = self.uid
        dict["displayName"] = self.displayName
        dict["photoURL"] = self.photoURL
        return dict as NSDictionary;
    }
}
