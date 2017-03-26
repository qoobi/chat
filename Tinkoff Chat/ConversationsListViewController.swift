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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
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
        cell.online = indexPath.section == 0
        cell.name = messages[indexPath.row].0
        cell.message = messages[indexPath.row].1
        cell.date = Date() - Double(indexPath.row) * 3e4
        cell.hasUnreadMessages = indexPath.row % 2 == 0
        cell.layoutIfNeeded()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ConversationCell {
            if let conversation = segue.destination as? ConversationViewController {
                conversation.title = cell.name
                conversation.showNewMessageView = segue.identifier != "peek"
            }
        }
    }
}

