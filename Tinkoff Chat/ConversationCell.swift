//
//  ConversationCell.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 25.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = name }
    }
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = message }
    }
    var date: Date? {
        didSet {
            let dateFormatter = DateFormatter()
            if Calendar.current.isDateInToday(date!) {
                dateFormatter.dateFormat = "HH:mm"
            } else {
                dateFormatter.dateFormat = "dd MMM"
            }
            dateLabel.text = dateFormatter.string(from: date!)
        }
    }
    var online: Bool = true {
        didSet {
            if online {
                self.backgroundColor = .yellow
            } else {
                self.backgroundColor = .white
            }
        }
    }
    var hasUnreadMessages: Bool = true {
        didSet {
            if hasUnreadMessages {
                messageLabel.font = .boldSystemFont(ofSize: 14.0)
            } else {
                messageLabel.font = .systemFont(ofSize: 14.0)
            }
        }
    }
}
