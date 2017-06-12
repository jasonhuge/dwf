//
//  SelectAllergyTableViewCell.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/12/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

protocol SelectAllergyTableViewCellDelegate {
    func tableView(cell:SelectAllergyTableViewCell, selected:Bool)
}

class SelectAllergyTableViewCell: AllergyTableViewCell {

    @IBOutlet weak var selectButton: UIButton!
    
    var delegate:SelectAllergyTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onSelectButtonTap(_ sender: UIButton) {
        
        self.set(selected: !self.selectButton.isSelected)
        
        self.delegate?.tableView(cell: self, selected: self.selectButton.isSelected)
        
    }
    
    override func updateWith(allergy: Allergy, selected:Bool) {
        super.updateWith(allergy: allergy, selected:selected)
        
        self.set(selected: selected)
    }
    
    override func updateWith(dietaryPref:DietaryPref, selected:Bool) {
        super.updateWith(dietaryPref: dietaryPref, selected: selected)
        
        self.set(selected: selected)
    }
    
    func set(selected:Bool) {
        if selected {
            self.selectButton.setTitle("-", for: .normal)
            self.selectButton.isSelected = true
        } else {
            self.selectButton.setTitle("+", for: .normal)
            self.selectButton.isSelected = false
        }
    }
}
