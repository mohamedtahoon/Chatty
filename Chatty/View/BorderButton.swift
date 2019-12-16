//
//  BorderButton.swift
//  Chatty
//
//  Created by MacBookPro on 12/12/19.
//  Copyright © 2019 MacBookPro. All rights reserved.
//

import UIKit

class BorderButton: UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        layer.borderWidth = 2.0
        layer.cornerRadius = 4.5
    }
}
