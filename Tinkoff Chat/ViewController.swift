//
//  ViewController.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 08.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var tapCounter = 0
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var textColorLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        keyboardDoneButtonView.setItems([doneButton], animated: false)
        aboutTextView.inputAccessoryView = keyboardDoneButtonView
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked)))
        imagePicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func imageClicked() {
        let alert = UIAlertController(title: "Изображение профиля", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) {
            UIAlertAction in
            self.takePhoto()
        })
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) {
            UIAlertAction in
            self.chooseFromLibrary()
        })
        if self.profileImageView.image != UIImage(named: "defaultProfileImage") {
            alert.addAction(UIAlertAction(title: "Удалить изображение", style: .destructive) {
                UIAlertAction in
                self.profileImageView.image = UIImage(named: "defaultProfileImage")
            })
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func takePhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "У вас нет камеры", message: nil, preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "Окей", style: .cancel, handler: nil))
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func chooseFromLibrary()
    {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            hideKeyboard()
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print(#function)
        for subview in view.subviews {
            print(subview.description)
        }

    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        print("Сохранение данных профиля")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func colorButtonAction(_ sender: UIButton) {
        colorLabel.textColor = sender.backgroundColor
    }
}

