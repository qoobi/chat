//
//  ConversationsListViewController.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 25.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var communicationManager: CommunicationManager?
    var userName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.dat").path
        let dict = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String:Any]
        if let dict = dict {
            self.userName = dict["login"] as? String
        }
        self.communicationManager = CommunicationManager.init(withConversationsListViewController: self, userName: self.userName ?? "", serviceType: "tinkoff-chat")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: animated)
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.communicationManager!.users.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Online", "History"][section]
    }
    
    let messages = [
        ("Олег", "Стартаперы смузи пьют, тыкают в планшетики и не думают о прибыли"),
        ("Герман", "Потому что Agile в ИТ это — ничего, если у тебя нет Agile всей организации"),
        ("Андрей", "Зачем дешевыми деньгами заливать экономику?"),
        ("Эльвира", "Курс рубля останется стабильным: причин для обвала нет"),
        ("Виктор", "Я не готов сидеть и отдыхать"),
        ("Константин Константинопольский", nil),
        ("Анатолий", "У нас очень много денег. Их просто вот совсем много"),
        ("Георгий", "И тогда с развитием дигитализации все будет просто прекрасно"),
        ("Дмитрий", "Денег нет, держитесь здесь 🦆"),
        ("Donald", "I know words, I have the best words. I have the best, but there is no better words than stupid.")
    ]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversation cell", for: indexPath) as! ConversationCell
        // TODO: optimize
        let sortedUsers = self.communicationManager!.users.sorted {
            [weak self] (first, second) -> Bool in
            let firstTime: Date? = self?.communicationManager!.messages[first.key]?.last?.date
            let secondTime: Date? = self?.communicationManager!.messages[second.key]?.last?.date
            if firstTime != nil {
                if secondTime != nil {
                    return firstTime! > secondTime!
                } else {
                    return true
                }
            } else {
                if secondTime != nil {
                    return false
                } else {
                    return first.value > second.value
                }
            }
        }
        let i = indexPath.row
        cell.userID = sortedUsers[i].key
        cell.online = true
        cell.name = sortedUsers[i].value
        let lastMessage = self.communicationManager!.messages[sortedUsers[i].key]?.last
        cell.message = lastMessage?.text
        cell.date = lastMessage?.date
        cell.hasUnreadMessages = false
        cell.layoutIfNeeded()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ConversationCell {
            if let conversation = segue.destination as? ConversationViewController {
                conversation.title = cell.name
                conversation.userID = cell.userID
                conversation.communicationManager = self.communicationManager
                conversation.showNewMessageView = segue.identifier != "peek"
                self.communicationManager?.conversation = conversation
            }
        }
    }
}

