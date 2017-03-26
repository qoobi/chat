//
//  MessageCell.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 26.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    var msg: String? { get set }
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
    @IBOutlet weak var textView: UITextView!

    var msg: String? {
        didSet {
            textView.text = msg
        }
    }
}
