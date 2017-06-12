//
//  FirebaseStorageService.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 6/5/17.
//  Copyright © 2017 1976. All rights reserved.
//

import Firebase

enum ImageUploadType {
    case jpeg
    case png
}

class FirebaseStorageService {
    static let sharedInstance = FirebaseStorageService();
    
    let storage = Storage.storage()
    let reference = Storage.storage().reference()
    let imageRef = Storage.storage().reference().child("images")
    
    func upload(image:UIImage, type:ImageUploadType, completionBlock: @escaping (Bool, String?, Error?) -> Void) {
        var data:Data?
        let metaData = StorageMetadata()
        var imageName = NSUUID().uuidString
        
        switch type {
        case .jpeg:
            data = UIImageJPEGRepresentation(image, 0.6)
            imageName += ".jpg"
            metaData.contentType = "image/jpeg"
            break
        case .png:
            data = UIImagePNGRepresentation(image)
            imageName += ".png"
            metaData.contentType = "image/png"
            break
        }
        
        let imageToUploadRef = self.imageRef.child(imageName)
        
        guard let unwrappedData = data else {
            print("No Data exists for Upload")
            return
        }
    
        imageToUploadRef.putData(unwrappedData, metadata: metaData) { (storageMetaData, error) in
            if error != nil {
                completionBlock(false, nil, error)
            } else {
                completionBlock(true, storageMetaData?.downloadURL()?.absoluteString, nil)
            }
        }
    }
}
