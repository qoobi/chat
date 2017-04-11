//
//  ProfileViewController.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 08.03.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import Photos
import Dispatch

class SaveButton: UIButton {
    override internal var isEnabled: Bool {
        willSet {
            if newValue == true {
                alpha = 1
            } else {
                alpha = 0.3
            }
        }
    }
}

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    private var tapCounter = 0
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var textColorLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gcdSaveButton: UIButton!
    @IBOutlet weak var operationSaveButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        keyboardDoneButtonView.setItems([doneButton], animated: false)
        aboutTextView.inputAccessoryView = keyboardDoneButtonView
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked)))
        imagePicker.delegate = self
        gcdSaveButton.isEnabled = false
        operationSaveButton.isEnabled = false
        activityIndicator.startAnimating()
        GCDDataManager().load(fromFile: "data.dat") {
            [weak self] (dict: [String:Any]?) in
            if let dict = dict {
                self?.loginTextField.text = dict["login"] as? String
                self?.aboutTextView.text = dict["about"] as! String
                self?.profileImageView.image = UIImage.init(data: dict["image"] as! Data)
                self?.colorLabel.textColor = dict["color"] as! UIColor
            }
            self?.activityIndicator.stopAnimating()
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
                self.gcdSaveButton.isEnabled = true
                self.operationSaveButton.isEnabled = true
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
            editingAction(picker)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            hideKeyboard()
            return false
        }
        return true
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        gcdSaveButton.isEnabled = false
        operationSaveButton.isEnabled = false
        self.activityIndicator.startAnimating()
        let data: [String:Any] = [
            "login": loginTextField.text ?? "",
            "about": aboutTextView.text,
            "image": UIImagePNGRepresentation(profileImageView.image!) ?? Data(),
            "color": colorLabel.textColor
        ]
        var manager: DataManager
        if sender.titleLabel?.text == "GCD" {
            manager = GCDDataManager()
        } else {
            manager = OperationDataManager()
        }
        manager.save(data: data, toFile: "data.dat") {
            [weak self] (saved: Bool) in
            self?.activityIndicator.stopAnimating()
            if saved {
                let alert = UIAlertController.init(title: "Данные сохранены", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController.init(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction.init(title: "Повторить", style: .default, handler: {
                    (_: UIAlertAction) -> Void in
                    self?.saveAction(sender)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    @IBAction func colorButtonAction(_ sender: UIButton) {
        colorLabel.textColor = sender.backgroundColor
        editingAction(sender)
    }
    @IBAction func editingAction(_ sender: Any) {
        gcdSaveButton.isEnabled = true
        operationSaveButton.isEnabled = true
    }
    func textViewDidChange(_ textView: UITextView) {
        editingAction(textView)
    }
}

