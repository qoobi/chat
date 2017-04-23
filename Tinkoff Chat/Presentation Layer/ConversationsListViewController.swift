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
    var communicationManager: CommunicatorDelegate?
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
        self.communicationManager = CommunicationManager.init(withUserName: self.userName ?? "", serviceType: "tinkoff-chat")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: animated)
        }
        self.communicationManager?.dataDidChange = {
            [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
        return self.communicationManager?.userCount() ?? 0
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
        let sortedUsers = self.communicationManager?.sortedUsers
        let i = indexPath.row
        cell.userID = sortedUsers?[i].0
        cell.online = true
        cell.name = sortedUsers?[i].1
        let lastMessage = self.communicationManager?.messagesWith(user: sortedUsers?[i].0 ?? "")?.last
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
                self.communicationManager?.dataDidChange = {
                    DispatchQueue.main.async {
                        conversation.tableView.reloadData()
                    }
                }
                //self.communicationManager?.conversation = conversation
            }
        }
    }
}

