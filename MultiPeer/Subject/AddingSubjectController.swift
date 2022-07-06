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
    var userDefaultSetup = UserDefaultSetup()
    
    weak var delegate: AddingInspectorDelegate?
    var inspector: Inspector
    var appDelegate: AppDelegate?
    var context: NSManagedObjectContext?
    
    private let nameTF: UITextField = {
        let tf = UITextField(withPadding: true)

        let attrText = NSMutableAttributedString(string: "Name", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
                                                 
        tf.attributedPlaceholder = attrText
    
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        
        return tf
    }()
    
    
    private let maleBtn = SelectableButton(title: "Male").then {
        $0.layer.cornerRadius = 20
    }
    
    private let femaleBtn = SelectableButton(title: "Female").then {
        $0.layer.cornerRadius = 20
    }
    
    private let genderStackView = SelectableButtonStackView(selectedBGColor: .green, defaultBGColor: .gray, selectedTitleColor: .black, defaultTitleColor: .white, spacing: 10, cornerRadius: 15).then {
        $0.distribution = .fillEqually
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
    
    private let birthDayLabel = UILabel().then {
        $0.text = "Birth Day"
        $0.textColor = .white
    }
    
//    private let birthDayPicker = UIDatePicker().then {
//        $0.tintColor = .white
//        $0.backgroundColor = .gray
//    }
    
    private let birthDayPicker : UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.tintColor = .white
        picker.backgroundColor = .gray
        picker.layer.cornerRadius = 10
        picker.clipsToBounds = true
        return picker
    }()
    
//    private let emailTF = UITextField().then { $0.placeholder = "Enter Email Address"}
//    private let phoneTF = UITextField().then {
//        $0.placeholder = "Enter Phone Number"
//        $0.keyboardType = .numberPad
//    }
    
    private let emailTF: UITextField = {
//        let tf = UITextField()
        let tf = UITextField(withPadding: true)
        let attrText = NSMutableAttributedString(string: "Email Address", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
//        tf.placeholder = "Enter Email Address"
        tf.attributedPlaceholder = attrText
        tf.textColor = .white
        
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        
        return tf
    }()
    
    private let phoneTF : UITextField = {
//        let tf = UITextField()
        let tf = UITextField(withPadding: true)
        let attrText = NSMutableAttributedString(string: "Phone Number", attributes: [
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
    
    private let kneeTF : UITextField = {
//        let tf = UITextField()
        let tf = UITextField(withPadding: true)
        let attrText = NSMutableAttributedString(string: " Knee Length\n", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
        tf.attributedPlaceholder = attrText
        tf.adjustsFontSizeToFitWidth = true
//        tf.keyboardType = .numberPad
        tf.keyboardType = .decimalPad
        tf.textColor = .white
        
        tf.textColor = .white
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        
        return tf
    }()
    
    private let kneeUnitLabel = UILabel().then {
        $0.text = "cm"
        $0.textColor = .black
    }
    
    private let palmTF : UITextField = {
        let tf = UITextField(withPadding: true)
        
        let attrText = NSMutableAttributedString(string: " palm Length\n", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray])
        tf.attributedPlaceholder = attrText
        tf.adjustsFontSizeToFitWidth = true
        tf.keyboardType = .decimalPad
        tf.textColor = .white
        
        tf.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        tf.layer.cornerRadius = 10
        
        return tf
    }()
    
    private let palmUnitLabel = UILabel().then {
        $0.text = "cm"
        $0.textColor = .black
    }
    
    private let completeBtn = UIButton().then {
        $0.setTitle("Complete", for: .normal)
        $0.setTitleColor(.green, for: .normal)
        $0.layer.borderColor = .init(gray: 0.5, alpha: 1)
        $0.layer.borderWidth = 1
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 15
        $0.isUserInteractionEnabled = false
    }
    
    init(inspector: Inspector) {
        self.inspector = inspector
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func toggleCompleteBtnState() {
        // date not considered yet for simplicity
        if name != "" && phoneNumber.count == 11 && genderStackView.selectedBtnIndex != nil && kneeTF.text! != "" && palmTF.text! != "" {
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
              genderStackView.selectedBtnIndex != nil,
              phoneNumber.count >= 11 else {
            return
        }
        
        guard context != nil else {
            fatalError("context is nil")
        }
        
        
        let isMale = genderStackView.selectedBtnIndex! == 0

        let kneeLength = Double(kneeTF.text!)!
        let palmLength = Double(palmTF.text!)!
        
        let newSubject = Subject.save(name: name, phoneNumber: phoneNumber, isMale: isMale, birthday: birthday, kneeLength: kneeLength, palmLength: palmLength, inspector: inspector)
        
        let screen = newSubject.screens.first
        guard let screen = screen else { fatalError() }
        
        screen.upperIndex = Int64(userDefaultSetup.upperIndex)
        
        userDefaultSetup.upperIndex += 1
        
        
        delegate?.updateAfterAdded()
    }
    
    func setupDelegate() {
        emailTF.delegate = self
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
        for btn in genderStackView.buttons {
            btn.addTarget(self, action: #selector(genderBtnTapped(_:)), for: .touchUpInside)
        }
        completeBtn.addTarget(self, action: #selector(completeBtnTapped), for: .touchUpInside)
        
        nameTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        phoneTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        kneeTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        palmTF.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
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

//        } else if sender == kneeTF || sender == palmTF {
//            if kneeTF.text!.count == 4 || palmTF.text!.count == 4 {
//                print("text.count is 4")
//                view.endEditing(true)
//            }
//        }
            
        } else if sender == kneeTF && kneeTF.text!.count == 4 {
            view.endEditing(true)
        } else if sender == palmTF && palmTF.text!.count == 4 {
            view.endEditing(true)
        }
        toggleCompleteBtnState()
    }
    
    @objc func genderBtnTapped(_ sender: SelectableButton) {
        genderStackView.selectBtnAction(selected: sender.id)
        toggleCompleteBtnState()
    }
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        
        view.endEditing(true)
    }
    
    
    
    private func setupLayout() {
        
        [maleBtn, femaleBtn].forEach { self.genderStackView.addArrangedButton($0)}
        
        [
//            nameLabel,
            nameTF,
            genderStackView,
            birthDayLabel, birthDayPicker,
            emailTF,
            phoneTF,
            kneeTF, kneeUnitLabel,
            palmTF, palmUnitLabel,
            completeBtn
        ].forEach { self.view.addSubview($0)}
        
        print("genderStackView's button: \(genderStackView.buttons.count)")
        
        nameTF.delegate = self
        nameTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
        }
        
        genderStackView.snp.makeConstraints { make in

            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.top.equalTo(nameTF.snp.bottom).offset(40)
            make.height.equalTo(45)
        }
        
        birthDayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.top.equalTo(genderStackView.snp.bottom).offset(40)
            make.height.equalTo(20)
        }
        
        birthDayPicker.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(40)
            make.leading.equalTo(birthDayLabel.snp.trailing).offset(20)
            make.centerY.equalTo(birthDayLabel.snp.centerY)
            make.height.equalTo(40)
        }
        
        emailTF.delegate = self
        emailTF.snp.makeConstraints { make in

            
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
            
            make.top.equalTo(birthDayPicker.snp.bottom).offset(60)
//            make.height.equalTo(20)
        }
        phoneTF.delegate = self
        phoneTF.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(emailTF.snp.bottom).offset(20)
//            make.height.equalTo(30)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
        kneeTF.delegate = self
        kneeTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(phoneTF.snp.bottom).offset(20)
            make.width.equalTo(120)
        }
        
        kneeUnitLabel.snp.makeConstraints { make in
            make.leading.equalTo(kneeTF.snp.trailing).offset(5)
            make.height.equalTo(kneeTF.snp.height)
            make.width.equalTo(25)
            make.centerY.equalTo(kneeTF.snp.centerY)
        }
        
        
        

        
        palmUnitLabel.snp.makeConstraints { make in
//            make.leading.equalTo(palmTF.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(palmTF.snp.height)
            make.width.equalTo(25)
            make.centerY.equalTo(kneeTF.snp.centerY)
        }
        
        palmTF.delegate = self
        palmTF.snp.makeConstraints { make in
            make.trailing.equalTo(palmUnitLabel.snp.leading).offset(-5)
            make.height.equalTo(40)
            make.top.equalTo(phoneTF.snp.bottom).offset(20)
            make.width.equalTo(120)
        }
        
        completeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
//            make.top.equalTo(phoneTF.snp.bottom).offset(50)
            make.top.equalTo(palmTF.snp.bottom).offset(50)
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
