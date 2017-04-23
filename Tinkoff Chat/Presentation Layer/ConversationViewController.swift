//
//  ConversationViewController.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 26.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newMessageView: UIView!
    @IBOutlet weak var newMessageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var userID: String?
    weak var communicationManager: CommunicatorDelegate?
    
    var showNewMessageView: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        // TODO: fix bug with left-to-right drag
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        self.sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !showNewMessageView {
            newMessageViewHeightConstraint.constant = 0
            newMessageView.isHidden = true
        } else {
            newMessageViewHeightConstraint.constant = 44
            newMessageView.isHidden = false
        }
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        self.sendButton.isEnabled = self.textField.text != ""
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        self.communicationManager?.sendMessage(self.textField.text!, fromUser: "", toUser: self.userID!, completionHandler: {
            [weak self] (success, error) in
            if success {
                self?.textField.text = ""
                self?.sendButton.isEnabled = false
            }
        })
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillChangeFrame(notification: Notification) {
        if let info = notification.userInfo {
            if let frame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0
                var curve: UIViewAnimationOptions?
                if let raw = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                    curve = UIViewAnimationOptions(rawValue: raw)
                } else {
                    curve = .curveEaseInOut
                }
                self.bottomConstraint?.constant = UIScreen.main.bounds.size.height - frame.origin.y
                UIView.animate(withDuration: duration, delay: 0, options: curve!, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (b) in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.communicationManager?.messageCountWith(user: self.userID ?? "") ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier: String = "incoming message cell"
        var text: String = ""
        if let message = self.communicationManager?.messagesWith(user: self.userID ?? "")?[indexPath.row] {
            if message.direction == .outgoing {
                reuseIdentifier = "outgoing message cell"
            }
            text = message.text ?? ""
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.msg = text
        return cell
    }
}
