//
//  RoomsViewController.swift
//  Chatty
//
//  Created by MacBookPro on 12/13/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rooms = [Room]()
    @IBOutlet weak var tableViewRooms: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewRooms.delegate = self
        tableViewRooms.dataSource = self
        tableViewRooms.separatorColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
       // tableViewRooms.separatorStyle = .none

        
        
        observeRooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.email == nil {
            goToLoginView()
        }
    }
    
    func observeRooms(){
        let dataReference = Database.database().reference()
        dataReference.child("rooms").observe(.childAdded) { (snapshot) in
            if let dataArr = snapshot.value as? [String: Any]{
                print(dataArr["roomName"]!)
                if let roomName = dataArr["roomName"] as? String {
                    let room = Room.init(roomId: snapshot.key, roomName: roomName)
                    self.rooms.append(room)
                    self.tableViewRooms.reloadData()
                    
                }
            }
        }
    }
    
    @IBAction func searchBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add New Chat Room", message: "", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            let textField = alert.textFields![0]
            
            guard let newRoom = textField.text, newRoom.isEmpty == false else{
                return
            }
            let dataBaseReference = Database.database().reference()
            let room = dataBaseReference.child("rooms").childByAutoId()
            
            let dataArr: [String: Any] = ["roomName": newRoom]
            room.setValue(dataArr) { (error, ref) in
                if error != nil {
                    
                }else{
                    textField.text = ""
                }
            }
        })
        
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // Add 1 textField and cutomize it
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Add New Chat Room"
            textField.clearButtonMode = .whileEditing
            
            
        }
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        //present(alert, animated: true, completion: nil)
        self.present(alert, animated: true, completion: {() -> Void in
            alert.view.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = self.rooms[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        cell.textLabel?.text = room.roomName
        cell.textLabel?.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        cell.textLabel?.font = .systemFont(ofSize: 22)
        cell.accessoryView = UIImageView(image: UIImage(named: "1.png"))

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRoom = self.rooms[indexPath.row]
        let chatRoomView = self.storyboard?.instantiateViewController(identifier: "chatRoom") as! ChatViewController
        chatRoomView.rooms = selectedRoom
        self.navigationController?.pushViewController(chatRoomView, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        goToLoginView()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if rooms.count > 0 {
            hideTableEmptyMessage()
            return 1
        } else {
            self.showTableEmptyMessage(message: "You don't have any Chat Rooms yet,\n Click on (+) to add  \n a Room.")
            return 0
        }
    }
    
  
    
    func showTableEmptyMessage(message:String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 18)
        messageLabel.sizeToFit()
        
        self.tableViewRooms.backgroundView = messageLabel
        self.tableViewRooms.separatorStyle = .none
        
    }
    
    func hideTableEmptyMessage() {
        tableViewRooms.backgroundView = nil
        tableViewRooms.separatorStyle = .singleLine
    }
    
    // MARK: - Table Animation
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let reotate = CATransform3DTranslate(CATransform3DIdentity, 0,40, 0)
        cell.layer.transform = reotate
        cell.alpha = 0
        UIView.animate(withDuration: 0.9){
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
    
    func goToLoginView(){
        let formScreen = self.storyboard?.instantiateViewController(identifier: "login") as! SignInViewController
        self.present(formScreen, animated: true, completion: nil)
    }
    
}

