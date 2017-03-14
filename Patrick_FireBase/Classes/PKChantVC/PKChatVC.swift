//
//  PKChatVC.swift
//  FireBase
//
//  Created by indianic on 11/03/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class PKChatVC: JSQMessagesViewController {

    
    var message = [JSQMessage]()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.senderId = "1"
        self.senderDisplayName = "Pratik"
  
        collectionView.reloadData()
        
    }
    
    // MARK: - Send Button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
        print("text Message is \(text)")
        
        
        message.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
        print("Messages is \(message)")
        collectionView.reloadData()

    }
    
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    
    
    // MARK: - Collectionview DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return message.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return message[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubble =    JSQMessagesBubbleImageFactory ()
    
        
        return bubble?.outgoingMessagesBubbleImage(with: .black)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return  nil;
        
        
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
