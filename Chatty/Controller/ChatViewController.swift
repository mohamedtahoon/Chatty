//
//  ChatViewController.swift
//  Chatty
//
//  Created by MacBookPro on 12/15/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    var rooms: Room?
    var messages : [Message] = [Message]()
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.dataSource = self
        messageTableView.delegate = self
        
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        messageTableView.allowsSelection = false
        
        messageTextfield.delegate = self
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        
        title = rooms?.roomName
        
    }
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.messages.count-1, section: 0)
        self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        print("Notification: Keyboard will show")

        messageTableView.setBottomInset(to: 0.0)
        if messages.count > 0{
        scrollToBottom()
        
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        messageTableView.setBottomInset(to: 0.0)
    }
    
    
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomMessageCell
        let message = self.messages[indexPath.row]
        cell.setMessageData(message: message)
        
        if message.userId == Auth.auth().currentUser!.uid{
            cell.setBubbleType(type: .myMessages)
            
        }else{
            cell.setBubbleType(type: .othersMessages)
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 125.0
    }
    
    
    
    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 369
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Send & Recieve from Firebase
    
    func sendMessage(chatText: String, completion: @escaping (_ isSuccess: Bool)-> ()){
        let databaseRef = Database.database().reference()
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        getUserWithId(id: userId) { (userName) in
            if let userName = userName {
                if let roomId = self.rooms?.roomId, let userId = Auth.auth().currentUser?.uid {
                    
                    let dataArr : [String: Any] = ["Sender": userName, "MessageBody": chatText, "senderId": userId]
                    let room = databaseRef.child("rooms").child(roomId)
                    room.child("Messages").childByAutoId().setValue(dataArr, withCompletionBlock:  { (error, ref) in
                        if error != nil{
                            print(error!)
                            completion(false)
                        }else{
                            completion(true)
                            print("Data Added Successfully")
                            self.sendButton.isEnabled = true
                            self.scrollToBottom()
                            self.messageTextfield.isEnabled = true
                            self.sendButton.isEnabled = true
                            self.messageTextfield.text = ""
                        }
                    })
                }
            }
        }
    }
    
  
    
    func getUserWithId(id: String, completion: @escaping (_ userName: String?)-> ()){
        let databaseRef = Database.database().reference()
        let user = databaseRef.child("users").child(id)
        
        user.child("userName").observeSingleEvent(of: .value) { (snapshot) in
            if let userName = snapshot.value as? String{
                completion(userName)
            }else{
                completion(nil)
            }
            
        }
    }
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        guard let chatText = self.messageTextfield.text, chatText.isEmpty == false else {
            return
        }
        sendMessage(chatText: chatText) { (isSuccess) in
            if isSuccess{
                print("Message Sent")
            }else{
                print("Message didn't sent")
            }
        }
    }
    
    func retrieveMessages(){
        guard let roomId = self.rooms?.roomId else{
            return
        }
        
        let messageDB = Database.database().reference().child("rooms").child(roomId).child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            print(snapshot)
            
            if let dataArr = snapshot.value as? [String: Any]{
                guard let senderName = dataArr["Sender"]as? String, let text = dataArr["MessageBody"] as? String, let userId = dataArr["senderId"] as? String else {
                    return
                }
                
                let message = Message.init(messageKey: snapshot.key, sender: senderName, messageBody: text, userId: userId)
                
                self.messages.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Error while Logging Out!!")
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (messageTextfield.text! as NSString).replacingCharacters(in: range, with: string)
        if text.isEmpty {
            sendButton.isEnabled = false
            sendButton.alpha = 0.5
        } else {
            sendButton.isEnabled = true
            sendButton.alpha = 1.0
        }
        return true
    }
    
    
    
}

extension UITableView {
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
        
        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
