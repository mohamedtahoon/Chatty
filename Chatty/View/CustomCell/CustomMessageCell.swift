//
//  CustomMessageCell.swift
//  Chatty
//
//  Created by MacBookPro on 12/15/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var chatTextBubble: UIView!
    @IBOutlet weak var senderUsername: UILabel!
    @IBOutlet weak var messageBody: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatTextBubble.layer.cornerRadius = 7
        // Initialization code goes here
        
    }
    
    func setMessageData(message: Message){
        senderUsername.text = message.sender
        messageBody.text = message.messageBody
    }
    enum BubbleType{
        case myMessages
        case othersMessages
    }
    func setBubbleType(type: BubbleType){
        if(type == .myMessages){
            chatStackView.alignment = .trailing
            chatTextBubble.backgroundColor = #colorLiteral(red: 0.6450474262, green: 0.7285560966, blue: 1, alpha: 1)
        }else if(type == .othersMessages){
            chatStackView.alignment = .leading
            chatTextBubble.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }


}

