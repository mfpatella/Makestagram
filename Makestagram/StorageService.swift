//
//  StorageService.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/15/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

struct StorageService {
    
    static func uploadImage(_ image:UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            completion(metadata?.downloadURL())
        })
    }
}
