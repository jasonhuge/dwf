//
//  DWFObject.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/10/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class DWFObject: NSObject {

}

extension NSObject {
    
    func propertyNames() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        
        // Uses the Objc Runtime to get the property list
        guard let properties = class_copyPropertyList(classForCoder, &count) else {
            return names
        }
        
        for i in 0 ..< Int(count) {
            let property: objc_property_t = properties[i]!
            
            if let name = String(cString: property_getName(property), encoding: .utf8) {
                names.append(name);
            }

        }
        
        free(properties)
        
        return names
    }
    
}
