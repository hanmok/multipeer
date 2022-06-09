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


protocol AddingSubjectDelegate: AnyObject {
    func updateAfterAdded()
}

class AddingSubjectController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AddingSubjectDelegate?
    
    var appDelegate: AppDelegate?
    var context: NSManagedObjectContext?
    
    private let nameLabel = UILabel().then { $0.text = "Name : "}
    private let nameTF = UITextField().then { $0.placeholder = "Enter Name"}
    
    private let maleBtn = SelectableButton(title: "Male")
    private let femaleBtn = SelectableButton(title: "Female")
    private let genderStackView = SelectableButtonStackView(selectedColor: .green, defaultBGColor: .gray, spacing: 40).then {
        $0.distribution = .fillEqually
        $0.spacing = 10
        $0.axis = .horizontal
    }
    
    var name: String = ""
    var phoneNumber = ""
    var isMale = true
    var birthday = Date()
    
    private func setupContext() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let appDelegate = appDelegate else { fatalError("appDelegate is nil")}
        context = appDelegate.persistentContainer.viewContext
    }
    
    private let birthDayLabel = UILabel().then { $0.text = "Birth Day"}
    private let birthDayPicker = UIDatePicker()
    
    private let emailTF = UITextField().then { $0.placeholder = "Enter Email Address"}
    private let phoneTF = UITextField().then {
        $0.placeholder = "Enter Phone Number"
        $0.keyboardType = .numberPad
    }
    
    private let completeBtn = UIButton().then {
        $0.setTitle("Complete", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.layer.borderColor = .init(gray: 0.5, alpha: 1)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .gray
    }
    
    
    private func toggleCompleteBtnState() {
        // date not considered yet for simplicity
        if name != "" && phoneNumber.count == 11 && genderStackView.selectedBtnIndex != nil {
            DispatchQueue.main.async {
                self.completeBtn.backgroundColor = .green
            }
        } else {
            DispatchQueue.main.async {
                self.completeBtn.backgroundColor = .gray
            }
        }
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
        //        if name != "" && // valid condition
        
        //        print("selectedIndex State: \(genderStackView.selectedBtnIndex)")
        
        guard name != "",
              genderStackView.selectedBtnIndex != nil,
              phoneNumber.count >= 11 else {
            return
        }
        
        guard context != nil else {
            fatalError("context is nil")
        }
        
        Subject.save(name: name, phoneNumber: phoneNumber, isMale: genderStackView.selectedBtnIndex! == 0, birthday: birthday)
        
        delegate?.updateAfterAdded()
    }
    
    func setupDelegate() {
        emailTF.delegate = self
        phoneTF.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContext()
        setupDelegate()
        setupLayout()
        setupTargets()
    }
    
    private func setupTargets() {
        for btn in genderStackView.buttons {
            btn.addTarget(self, action: #selector(genderBtnTapped(_:)), for: .touchUpInside)
        }
        completeBtn.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        
        nameTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        phoneTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        phoneTF.addTarget(self, action: #selector(textEditingEnd), for: .editingDidEnd)
        
        birthDayPicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
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
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        birthday = sender.date
        print("birthday: \(birthday)")
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
            
            print("phoneNumber: \(phoneNumber)")
        }
        toggleCompleteBtnState()
    }
    
    @objc func genderBtnTapped(_ sender: SelectableButton) {
        genderStackView.setSelectedButton(sender.id)
        toggleCompleteBtnState()
    }
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        
        view.endEditing(true)
    }
    
    
    
    private func setupLayout() {
        
        [maleBtn, femaleBtn].forEach { self.genderStackView.addArrangedButton($0)}
        
        [nameLabel, nameTF,
         genderStackView,
         birthDayLabel, birthDayPicker,
         emailTF,
         phoneTF,
         completeBtn
        ].forEach { self.view.addSubview($0)}
        
        print("genderStackView's button: \(genderStackView.buttons.count)")
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        nameTF.delegate = self
        nameTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.height.equalTo(30)
        }
        
        genderStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(nameLabel.snp.bottom).offset(60)
            make.height.equalTo(40)
        }
        
        birthDayLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(genderStackView.snp.bottom).offset(60)
            make.height.equalTo(20)
        }
        
        birthDayPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(birthDayLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        emailTF.delegate = self
        emailTF.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(60)
            make.height.equalTo(20)
        }
        phoneTF.delegate = self
        phoneTF.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(emailTF.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        
        completeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalTo(phoneTF.snp.bottom).offset(50)
            make.height.equalTo(50)
        }
    }
}


extension AddingSubjectController: UITextFieldDelegate {
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
