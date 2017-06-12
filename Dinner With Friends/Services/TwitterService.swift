//
//  TwitterService.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterService {
    static let sharedInstance = TwitterService()
    
    init() {
        
    }
    
    func twitterSession() ->TWTRAuthSession? {
        return Twitter.sharedInstance().sessionStore.session()
    }
    
    func twitterAuthTokenFor(provider:String) ->String? {
        var token:String?
        
        if let session = self.twitterSession() {
            token = session.authToken
        }
        
        return token;
    }
    
    func login(completionBlock:@escaping ((Bool, Error?) -> Void)) {
        Twitter.sharedInstance().logIn(completion: {(session, error) in
            if session != nil {
                completionBlock(true, nil)
            } else {
                completionBlock(false, error)
            }
        })
    }
    
}
