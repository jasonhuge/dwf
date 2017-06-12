//
//  DWFModel.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/10/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class DWFModel: NSObject {
    
    override init() {
        super.init();
    }
    
    init(rawData:NSDictionary) {
        super.init();
        
        self.updateWith(rawData:rawData);
    }
    
    func dataAsDictionary() ->NSDictionary {
        
        return self.dictionaryWithValues(forKeys: self.propertyNames()) as NSDictionary;
    }
    
    func set(key:String, value:Any) {
        let selector = NSSelectorFromString(key)
        
        if self.responds(to: selector) {
            if let _ = value as? NSNull {
                
            }else{
                
                self.setValue(value, forKey: key);
            }
        }
    }
    
    func parseDictionary(dict:NSDictionary) {
        for(key, value) in dict {
            if let key = key as? String {
                self.set(key: key, value: value)
            }
        }
    }
    
    func parseArray(array:NSArray) {
        
    }
    
    func parseArray(key:String, array:NSArray) {
        
    }
    
    func updateWith(rawData:NSDictionary) {
        
        for (key, value) in rawData {
            print(key, value)

            if let key = key as? String {
                
                if let value = value as? NSDictionary {
                    self.parseDictionary(dict: value)
                } else if let value = value as? NSArray {
                    
                    self.parseArray(key:key, array: value)
                    
                } else {
                    self.set(key: key, value: value)
                }
            }
        }
    }
    
    func updateWith(suplimentalData: NSDictionary) {
        for (key, value) in suplimentalData {
            if let key = key as? String {
                let selector = NSSelectorFromString(key)
                
                if self.responds(to: selector) {
                    if let _ = value as? NSNull {
                        
                    }else{
                        
                        self.setValue(value, forKey: key);
                    }
                }
            }
        }
    }
    
    func reset(){
        
    }

}
