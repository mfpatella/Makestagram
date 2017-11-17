//
//  MainTabBarController.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/10/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    let photoHelper = MGPhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoHelper.completionHandler = { image in
            PostService.create(for: image)
            
        }
        delegate = self
        tabBar.unselectedItemTintColor = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController ) -> Bool {
        
        if viewController.tabBarItem.tag == 1 {
            // print("take photo")
            photoHelper.presentActionSheet(from: self)
            return false
        }
        else {
            return true
        }
    }
}
