//
//  PKChatVC.swift
//  FireBase
//
//  Created by indianic on 11/03/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
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
     
        

        let sheet = UIAlertController(title: "Media Message", message: "Please Select Media", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancel =  UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction) in
            
        }
        
        let photo =  UIAlertAction(title: "Photo Library", style:.default) { (alert : UIAlertAction) in
            
            self.getImageFrom(type: kUTTypeImage)
        }
        let video  =  UIAlertAction(title: "Video Library", style:.default) { (alert : UIAlertAction) in
            self.getImageFrom(type: kUTTypeMovie)
        }
        sheet.addAction(cancel)
        sheet.addAction(photo)
        sheet.addAction(video)
        self.present(sheet, animated: true, completion: nil)
        

        
        
    }
    
    func getImageFrom(type:CFString)
    {
        
      
        
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Collectionview DataSource Display Message on Chat View
    
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

//MARK: - Display Image on Chat VC
extension PKChatVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let photo  = JSQPhotoMediaItem(image:picture)
            
            
            message.append(JSQMessage(senderId: self.senderId, displayName:self.senderDisplayName, media: photo))
            
        }else if let video = info[UIImagePickerControllerMediaURL] as? NSURL
        {
            let videoItem = JSQVideoMediaItem(fileURL:video as URL! ,isReadyToPlay:true)
            message.append(JSQMessage(senderId: self.senderId, displayName:self.senderDisplayName, media: videoItem))

        }
        self.dismiss(animated: true, completion: nil)
        
        collectionView.reloadData()
    }

    
    
}
