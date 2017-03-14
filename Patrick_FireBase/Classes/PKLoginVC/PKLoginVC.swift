//
//  PKLoginVC.swift
//  FireBase
//
//  Created by indianic on 11/03/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class PKLoginVC: UIViewController ,GIDSignInUIDelegate,GIDSignInDelegate {
 

    @IBOutlet weak var btnLoginAnonymously: UIButton!
    

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        btnLoginAnonymously.layer.borderWidth = 1
        btnLoginAnonymously.layer.borderColor = UIColor.white.cgColor
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "912966482379-1g3mfhlh7alhm2q32106upjm0l0i9qak.apps.googleusercontent.com"
        
        
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func btnLoginAnonymouslyClicked(_ sender: Any) {
        

        PKHelper.helper.loginAnonymously()
        
        
    }
    // MARK: - Action Event
   
   
  
    @IBAction func btnLoginWithGoogle(_ sender: Any) {
        
//        PKHelper.helper.loginWithGoogle()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if error != nil {
            // ...
            return
        }
        
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            print(user?.displayName)
            print(user?.email)
            
            if error != nil {
                // ...
                return
            }
            
        }
    }
   

 

}
