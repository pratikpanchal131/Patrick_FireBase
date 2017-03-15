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
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class PKChatVC: JSQMessagesViewController {

    
    var messages = [JSQMessage]()
    var messageRef = FIRDatabase.database().reference().child("messages")
    var avatarDic = [String : JSQMessagesAvatarImage]()
    let photoCache = NSCache<AnyObject, AnyObject>()
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let currentUser = FIRAuth.auth()?.currentUser
        {
            self.senderId = currentUser.uid
            
            if currentUser.isAnonymous{
                self.senderDisplayName = "Anonymouse"

            }else
            {
                self.senderDisplayName = currentUser.displayName

            }
            
        }
        
        
 
        self.observeMessages()
    }
    
    
    func observeUsers(id: String){
        FIRDatabase.database().reference().child("Users").child(id).observe(.value, with: { snapshot in
            print(snapshot.value)
            if let dict = snapshot.value as? [String: AnyObject] {
                let avatarUrl = dict["ProfileURL"] as! String
                
                //call the setupAvatar function
                self.avatar(url: avatarUrl, messageId: id)
                
            }
        })
    }
    
    
    func avatar(url: String, messageId: String){
        
        
        if url != "" {
            let fileURL = NSURL(string: url )
            let data = NSData(contentsOf: fileURL! as URL)
            let image = UIImage(data:data! as Data) // 
            
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDic[messageId] = userImg!
        }else{
            
//            JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user"), diameter: 30)
////            JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user"), diameter: 30)
//            avatarDic[messageId] =  JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user"), diameter: 30)

            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user"), diameter: 30)
            avatarDic[messageId] = userImg!
            
            
        }
        collectionView.reloadData()
    }
    
    
    
    // MARK:- Get Messages from Firebase Databe
    func observeMessages()
    {
        
        
        
        messageRef.observe(FIRDataEventType.childAdded) { (snapshot:FIRDataSnapshot) in
            
            let dict = snapshot.value as? [String : AnyObject]
            
            let MediaType = dict?["MediaType"] as! String
            
            let senderID = dict?["senderID"] as! String
            let senderDisplayName = dict?["senderDisplayName"] as! String
            
            self.observeUsers(id: senderID)
            
            switch MediaType {
            case "TEXT":
                
                let text = dict?["text"] as? String
                
                self.messages.append(JSQMessage(senderId: senderID, displayName: senderDisplayName, text: text))
                break;
            case "PHOTO":
                
                
                
                
                let fileURL = dict?["fileURL"] as! String

                var photo  = JSQPhotoMediaItem(image:nil)
                
                if let cacchedPhoto = self.photoCache.object(forKey: fileURL as AnyObject) as? JSQPhotoMediaItem{
                    photo = cacchedPhoto
                    self.collectionView.reloadData()
                }
                else
                {
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue After")
                        
                        let data =  NSData(contentsOf: NSURL(string:fileURL)! as URL)
                        
                        
                        
                        DispatchQueue.main.async {
                            
                            let picture  = UIImage(data:data as! Data)
                            photo?.image  = picture
                            
                            self.collectionView.reloadData()
                            
                            self.photoCache.setObject(photo!, forKey: fileURL as AnyObject)
                            print("This is run on the main queue, after the previous code in outer block")
                        }
                    }
                    
                }
               
                
                
                self.messages.append(JSQMessage(senderId: senderID, displayName:senderDisplayName, media: photo))
            
                if self.senderId == senderID
                {
                    photo?.appliesMediaViewMaskAsOutgoing = true
                }else
                {
                    photo?.appliesMediaViewMaskAsOutgoing = false
                }
                break;
            case "VIDEO":
                
                let fileURL = dict?["fileURL"] as! String
                let video =  NSURL(string:fileURL)
                let videoItem = JSQVideoMediaItem(fileURL: video as! URL, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderID, displayName:senderDisplayName, media: videoItem))
        
                if self.senderId == senderID
                {
                    videoItem?.appliesMediaViewMaskAsOutgoing = true
                }else
                {
                    videoItem?.appliesMediaViewMaskAsOutgoing = false
                }
                break;
            default:
                print("Unknown Data ype")
            }
            
//            if let text = dict?["text"] as? String
//            {
//                self.message.append(JSQMessage(senderId: senderID, displayName: senderDisplayName, text: text))
//
//            }else
//            {
//                let fileURL = dict?["fileURL"] as! String
//                let data =  NSData(contentsOf: NSURL(string:fileURL)! as URL)
//                let picture  = UIImage(data:data as! Data)
//                let photo  = JSQPhotoMediaItem(image:picture)
//                
//                
//                self.message.append(JSQMessage(senderId: senderID, displayName:senderDisplayName, media: photo))
//            }
            
            
            
        
            
            self.collectionView.reloadData()
            
        }
    }
    
    // MARK: - Send Button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text":text , "senderID":senderId , "senderDisplayName":senderDisplayName, "MediaType":"TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
        
//        print("text Message is \(text)")
//        
//        
//        message.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
//        print("Messages is \(message)")
//        collectionView.reloadData()

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
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message =  self.messages[indexPath.item]
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
//        let bubble =    JSQMessagesBubbleImageFactory ()
        if message.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
        }else
        {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
        
        
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        

        print("Avatar Image data \(message)  \(avatarDic[message.senderId])")
        return avatarDic[message.senderId]
        
        
//        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user"), diameter: 30)
//        return  JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "user")!, diameter: 30);
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("IndexPAth\(indexPath)")
        
        let message =  self.messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem
            {
            
                let player = AVPlayer(url:mediaItem.fileURL)
                let playerViewController =  AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    // MARK: - Action Event
    
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        
    
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
            
        }
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //From Main Storyboard instantiate a navigation controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "PKLoginVC") as! PKLoginVC
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Set navigation controller as root view controller
        appDelegate.window?.rootViewController = loginVC
    }
   
    
    func sendMedia(picture:UIImage? , video:NSURL?)
    {
        print("picture\(picture)")
        print(FIRStorage.storage().reference())
        
        if let picture = picture{
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print("filePath\(filePath)")
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metaData, completion: { (metaData,
                error) in
                if error != nil
                {
                    print("")
                    return
                }else
                {
                    let fileUrl = metaData?.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileURL":fileUrl , "senderID":self.senderId ,"senderDisplayName":self.senderDisplayName,"MediaType":"PHOTO"]
                    newMessage.setValue(messageData)
                }
                
                
            })

        }
        else if let video = video{
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print("filePath\(filePath)")

            let data =  NSData(contentsOf:video as URL)
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "video/mp4"
            
            FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metaData, completion: { (metaData,
                error) in
                if error != nil
                {
                    print("")
                    return
                }else
                {
                    let fileUrl = metaData?.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileURL":fileUrl , "senderID":self.senderId ,"senderDisplayName":self.senderDisplayName,"MediaType":"VIDEO"]
                    newMessage.setValue(messageData)
                }
                
                
            })
            
        }
        
    }

}

//MARK: - Display Image on Chat VC
extension PKChatVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
//            let photo  = JSQPhotoMediaItem(image:picture)
//            self.message.append(JSQMessage(senderId: self.senderId, displayName:self.senderDisplayName, media: photo))
            sendMedia(picture: picture, video: nil)
            
        }else if let video = info[UIImagePickerControllerMediaURL] as? NSURL
        {
//            let videoItem = JSQVideoMediaItem(fileURL:video as URL! ,isReadyToPlay:true)
//            self.message.append(JSQMessage(senderId: self.senderId, displayName:self.senderDisplayName, media: videoItem))
            sendMedia(picture: nil, video: video)

        }
        self.dismiss(animated: true, completion: nil)
        
        collectionView.reloadData()
    }

    
    
}
