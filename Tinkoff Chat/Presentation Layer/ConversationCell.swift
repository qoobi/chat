//
//  ConversationCell.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 25.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration {
    var name: String? { get set }
    var message: String? { get set }
    var date: Date? { get set }
    var online: Bool { get set }
    var hasUnreadMessages: Bool { get set }
}

class ConversationCell: UITableViewCell, ConversationCellConfiguration {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private func setMessageFont() {
        if message != nil {
            if hasUnreadMessages {
                messageLabel.font = .boldSystemFont(ofSize: 14.0)
            } else {
                messageLabel.font = .systemFont(ofSize: 14.0)
            }
        } else {
            messageLabel.font = .italicSystemFont(ofSize: 14.0)
        }
    }
    
    var userID: String?
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    var message: String? {
        didSet {
            if message != nil {
                messageLabel.text = message
            } else {
                messageLabel.text = "No messages yet"
            }
            setMessageFont()
        }
    }
    var date: Date? {
        didSet {
            if date != nil {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(date!) {
                    dateFormatter.dateFormat = "HH:mm"
                } else {
                    dateFormatter.dateFormat = "dd MMM"
                }
                dateLabel.text = dateFormatter.string(from: date!)
                dateLabel.sizeToFit()
                dateLabel.layoutIfNeeded()
            } else {
                dateLabel.text = ""
            }
        }
    }
    var online: Bool = true {
        didSet {
            if online {
                self.backgroundColor = UIColor(hue: 51/360, saturation: 0.26, brightness: 0.99, alpha: 1)
            } else {
                self.backgroundColor = .white
            }
        }
    }
    var hasUnreadMessages: Bool = true {
        didSet {
            setMessageFont()
        }
    }
}
