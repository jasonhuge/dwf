//
//  FamilyMemberButton.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 6/6/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class FamilyMemberButton: UIView {
    var uid = ""
    let imageView = UIImageView.init(frame: .zero)
    let titleLabel = UILabel.init(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 40 / 2
        self.backgroundColor = .white
        self.clipsToBounds = true
        
        self.imageView.contentMode = .scaleAspectFill
        
        self.titleLabel.textAlignment = .center
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
    
    }
    
    func setupWith(familyMember:FamilyMember) {
        self.uid = familyMember.uid
        
        if familyMember.photoURL.characters.count > 0 {
            let request = URLRequest.init(url: URL.init(string: familyMember.photoURL)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            
            self.imageView.setImageWith(request, placeholderImage: nil, success: { (request, response, image) in
                self.imageView.image = image
            }, failure: { (request, response, error) in
                
            })
            
        } else {
            let firstLastName = familyMember.displayName.characters.split(separator: " ")
            var initials = ""
            
            for name in firstLastName {
                if let firstInitial = name.first {
                   initials += "\(firstInitial)"
                }
            }
            
            self.titleLabel.text = initials.uppercased()
        }
    }
}
