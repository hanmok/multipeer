//
//  AddingSubjectController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit
import SnapKit
import Then
import CoreData


protocol AddingInspectorDelegate: AnyObject {
    func updateAfterAdded()
}

class AddingInspectorController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AddingInspectorDelegate?
    
    var appDelegate: AppDelegate?
    var context: NSManagedObjectContext?
    
    private let nameTF: UITextField = {
//        let tf = UITextField()
        let tf = UITextField(withPadding: true)

        let attrText = NSMutableAttributedString(string: "Enter Name\n", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
                                                 
        tf.attributedPlaceholder = attrText
    
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        return tf
    }()
    
    var name: String = ""
    var phoneNumber = ""
    var isMale = true
    
    private func setupContext() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let appDelegate = appDelegate else { fatalError("appDelegate is nil")}
        context = appDelegate.persistentContainer.viewContext
    }
    
    private let phoneTF : UITextField = {
//        let tf = UITextField()
        let tf = UITextField(withPadding: true)
        let attrText = NSMutableAttributedString(string: "Enter Phone Number\n", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
        tf.attributedPlaceholder = attrText
        
        tf.keyboardType = .numberPad
        tf.textColor = .white
        
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        
        return tf
    }()
    
    private let completeBtn = UIButton().then {
        $0.setTitle("Complete", for: .normal)
        $0.setTitleColor(.green, for: .normal)
        $0.layer.borderColor = .init(gray: 0.5, alpha: 1)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 15
        $0.isUserInteractionEnabled = false
    }
    
    
    private func toggleCompleteBtnState() {
        // date not considered yet for simplicity
        if name != "" && phoneNumber.count == 11 {
            self.completeBtn.isUserInteractionEnabled = true
            DispatchQueue.main.async {
                self.completeBtn.backgroundColor = .green
                self.completeBtn.setTitleColor(.black, for: .normal)
            }
        } else {
            self.completeBtn.isUserInteractionEnabled = false
            DispatchQueue.main.async {
                self.completeBtn.backgroundColor = .gray
                self.completeBtn.setTitleColor(.green, for: .normal)
            }
        }
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
        
        guard name != "",
//              genderStackView.selectedBtnIndex != nil,
              phoneNumber.count >= 11 else {
            return
        }
        
        guard context != nil else {
            fatalError("context is nil")
        }
        
        Inspector.save(name: name, phoneNumber: phoneNumber)
        
        delegate?.updateAfterAdded()
    }
    
    func setupDelegate() {
        phoneTF.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupContext()
        setupDelegate()
        setupLayout()
        setupTargets()
        // not working fine ..
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    
    private func setupTargets() {
//        for btn in genderStackView.buttons {
//            btn.addTarget(self, action: #selector(genderBtnTapped(_:)), for: .touchUpInside)
//        }
        
        completeBtn.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        
        nameTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        phoneTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        phoneTF.addTarget(self, action: #selector(textEditingEnd), for: .editingDidEnd)
    }
    
    @objc func textEditingEnd(_ sender: UITextField) {
        print("textEditingEnd called, sender: \(sender)")
        
        if sender == nameTF {
            name = nameTF.text!
            print("name: \(name)")
        } else if sender == phoneTF {
            phoneNumber = phoneTF.text!
            
            print("phoneNumber: \(phoneNumber)")
        }
        
        toggleCompleteBtnState()
        view.endEditing(true)
        
    }
    
    
    
    @objc func textChanged(_ sender: UITextField) {
        //        print("sender.text: \(sender.text!)")
        if sender == nameTF {
            name = nameTF.text!
            print("name: \(name)")
        } else if sender == phoneTF {
            phoneNumber = phoneTF.text!
            
            if phoneNumber.count == 11 {
                view.endEditing(true)
            }

        }
        
        toggleCompleteBtnState()
    }
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        
        view.endEditing(true)
    }
    
    
    
    private func setupLayout() {
        
        [
//            nameLabel,
            nameTF,
//         genderStackView,
//         birthDayLabel, birthDayPicker,
//         emailTF,
         phoneTF,
//            kneeTF, palmTF,
         completeBtn
        ].forEach { self.view.addSubview($0)}
        
        nameTF.delegate = self
        nameTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
        }
        
        
        phoneTF.delegate = self
        phoneTF.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(20)
//            make.top.equalTo(emailTF.snp.bottom).offset(20)
            make.top.equalTo(nameTF.snp.bottom).offset(20)
//            make.height.equalTo(30)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
        
        completeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
//            make.top.equalTo(phoneTF.snp.bottom).offset(50)
//            make.top.equalTo(palmTF.snp.bottom).offset(50)
            make.top.equalTo(phoneTF.snp.bottom).offset(50)
            make.height.equalTo(50)
        }
    }
}


extension AddingInspectorController: UITextFieldDelegate {
    // 다른 곳 눌렀을 때 호출
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditingCalled")
        if textField == phoneTF {
            phoneTF.text! = textField.text!
            phoneNumber = phoneTF.text!
            print("phoneNumber: \(phoneNumber)")
        } else if textField == nameTF {
            nameTF.text! = textField.text!
            name = nameTF.text!
            print("name: \(name)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn called")
        // there's no return btn on numberpad
        
        if textField == nameTF {
            nameTF.text! = textField.text!
            name = nameTF.text!
            print("name: \(name)")
            
            dismissKeyboard()
            return true
        }
        
        return false
    }
}
