//
//  AllergyTableViewCell.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/11/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class AllergyTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var id:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWith(allergy:Allergy, selected:Bool) {
        self.updateWith(allergy: allergy)
    }
    
    func updateWith(dietaryPref:DietaryPref, selected:Bool) {
        self.updateWith(dietaryPref: dietaryPref)
    }
    
    func updateWith(allergy:Allergy) {
        self.id = allergy.id
        self.titleLabel.text = allergy.name
    }
    
    func updateWith(dietaryPref:DietaryPref) {
        self.id = dietaryPref.id
        self.titleLabel.text = dietaryPref.name
    }
    
    func updateWith(dictionary:NSDictionary) {
        if let allergyID = dictionary["id"] as? Int {
            self.id = allergyID
        }
        
        if let title = dictionary["name"] as? String {
            self.titleLabel.text = title
        }
    }
    
}
