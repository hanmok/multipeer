//
//  SubjectInfoController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//


import UIKit
import CoreData
import SnapKit
import Then

protocol SubjectDetailDelegate: AnyObject {
    func sendback(_ subject: Subject, with screenId: UUID) // 없으면 새로 생성해야지 뭐 ..
}


class SubjectDetailController: UIViewController {
    
    
    weak var detailDelegate: SubjectDetailDelegate?
    let subject: Subject
    var screens: [Screen] = []
    
    private let nameLabel = UILabel().then { $0.backgroundColor = .brown }
    
    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
        $0.backgroundColor = .white
    }
    
    private let detailInfoLabel = UILabel().then { $0.textColor = .yellow }
    
    private let phoneLabel = UILabel().then { $0.textColor = .magenta}
    
    private let continueBtn = UIButton().then {
        $0.setTitle("Continue Testing", for: .normal)
        $0.setTitleColor(.cyan, for: .normal)
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
        $0.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    init(subject: Subject, frame: CGRect = .zero) {
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
        self.title = subject.name
    }
    
    
    @objc func continueTapped(_ sender: UIButton) {
        print("numofScreens: \(subject.screens.count)")
        if screens.isEmpty {
            Screen().save(belongTo: subject)
        }
        detailDelegate?.sendback(subject, with: subject.screens.first!.id)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    private func fetchScreens(from subject: Subject) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        

        switch subject.screens.count {
        case 0: continueBtn.setTitle("Start Testing", for: .normal)
            return
        case 1: screens.append(subject.screens.first!)
            return
        default: break
        }
        
        screens = subject.screens.sorted(by: { screen1, screen2 in
//            guard let date1 = screen1.date,
//                  let date2 = screen2.date else {
//                      fatalError("fatal error occurred during fetching screens")
//                  }
            return screen1.date < screen2.date
        })
        
        print("fetched screen count: \(screens.count) \n screen fetched: \(screens)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        configureLayout()
        fetchScreens(from: subject)
    }
    

    private func setupLayout() {
        
        [imageView, nameLabel, detailInfoLabel, phoneLabel,
         continueBtn
        ].forEach { self.view.addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.width.height.equalTo(70)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(imageView.snp.top)
            make.height.equalTo(20)
        }
        
        detailInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.equalTo(detailInfoLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        continueBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-60)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    
    private func configureLayout() {
        nameLabel.text = subject.name
        detailInfoLabel.text = String(subject.isMale ? "남" : "여") + " / " + String(calculateAge(from: subject.birthday))
        phoneLabel.text = subject.phoneNumber
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// dismiss 시키면서 delegate 이용해야 할 것 같은데 ... ??
