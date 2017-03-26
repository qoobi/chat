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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
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
                UIView.animate(withDuration: duration, delay: 0, options: curve!, animations: { self.view.layoutIfNeeded() }, completion: nil)
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
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier: String
        if indexPath.row < 3 {
            reuseIdentifier = "incoming message cell"
        } else {
            reuseIdentifier = "outgoing message cell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.msg = String.init(repeating: "a", count: [30, 1, 300][indexPath.row % 3])
        return cell
    }
}
