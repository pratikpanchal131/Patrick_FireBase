//
//  PKHelper.swift
//  Patrick_FireBase
//
//  Created by indianic on 14/03/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn

class PKHelper {
    
    static let helper = PKHelper()
    
    func loginAnonymously() {
        
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error == nil
            {
                print("userid \(user?.uid)!")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let appDelegate = UIApplication.shared.delegate  as! AppDelegate
                
                
                let navVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
//                navVC.pushViewController(navVC, animated: true)
                appDelegate.window?.rootViewController = navVC;
            }
            else{
                print(error?.localizedDescription)
            }
            
        })
        
        
    }

    func loginWithGoogle() {
        
//        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()

        
        
    }
    
    
}
