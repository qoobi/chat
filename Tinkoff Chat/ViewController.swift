//
//  ViewController.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 08.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    private var tapCounter = 0
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var textColorLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapAction))
        view.addGestureRecognizer(tapGesture)
    }

    func onTapAction() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            view.endEditing(true)
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard sender is UIButton else { return }
        print("This scene should be saved")
    }

}

