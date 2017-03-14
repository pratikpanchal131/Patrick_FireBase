//
//  PKChatVC.swift
//  FireBase
//
//  Created by indianic on 11/03/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit

class PKChatVC: UIViewController {

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        

    }
    
    
    // MARK: - Action Event
    
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //From Main Storyboard instantiate a navigation controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "PKLoginVC") as! PKLoginVC
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Set navigation controller as root view controller
        appDelegate.window?.rootViewController = loginVC
    }
   

}
