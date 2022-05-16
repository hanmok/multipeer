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
    func sendback(_ subject: Subject, with screen: Screen) // 없으면 새로 생성해야지 뭐 ..
}


class SubjectDetailController: UIViewController {
    
    
    weak var detailDelegate: SubjectDetailDelegate?
    let subject: Subject
    
    var screens: [Screen] = [] {
        didSet {
            DispatchQueue.main.async {
                self.screenCollectionView.reloadData()
            }
        }
    }
    
    var selectedScreen: Screen? // Screen ? or Screen id ?
    
    let reuseId = "ScreenCellId"
    
    private let screenCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
    private func registerCollectionView(customCollectionView: UICollectionView) {
        customCollectionView.register(ScreenCell.self, forCellWithReuseIdentifier: reuseId)
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
    }
    
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
            let myScreen = Screen.save(belongTo: subject)
             selectedScreen = myScreen
        }
// selectedScreen ?? what is that for now ??
        guard let selectedScreen = selectedScreen else {
            fatalError("selected screen is nil", file: #function)
        }

        detailDelegate?.sendback(subject, with: selectedScreen)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    private func fetchScreens(from subject: Subject) {
        
        print("flag 1 fetched screen count: \(screens.count) \n screen fetched: \(screens) ")
        
        switch subject.screens.count {
        case 0: continueBtn.setTitle("Start Testing", for: .normal)
            print("flag 3 case 0")
        case 1: screens.append(subject.screens.first!)
            print("flag 4 case 1")
        default:
            print("flag 5 ")
            break
        }
        
        // sorting !
        if screens.count >= 2 {
        screens = subject.screens.sorted(by: { screen1, screen2 in
            print("its sorting .. ")
            return screen1.date < screen2.date
        })
        }
        
        
        print("flag 2 fetched screen count: \(screens.count) \n screen fetched: \(screens)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchScreens(from: subject)
        registerCollectionView(customCollectionView: screenCollectionView)
        screenCollectionView.reloadData()
        setupLayout()
        configureLayout()

    }
    
    
    private func setupLayout() {
        
        [imageView, nameLabel, detailInfoLabel, phoneLabel,
         continueBtn,
         screenCollectionView
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
        
        screenCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(continueBtn.snp.top).offset(-20)
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


extension SubjectDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return screens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ScreenCell
        
        cell.viewModel = ScreenViewModel(screen: screens[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedScreen = screens[indexPath.row]
        print("screen has been selected !!")
        let trialDetailController = TrialDetailController(screen: selectedScreen!)
        self.navigationController?.pushViewController(trialDetailController, animated: true)
    }
}




