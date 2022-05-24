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
    
    var selectedIndex = IndexPath(row: -1, section: 0)
    
    var selectedScreen: Screen? // Screen ? or Screen id ?
    
    let reuseId = "ScreenCellId"
    
    private let screenCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let screenTableView = UITableView()
    
    
    private func registerTableView() {
        screenTableView.register(ScreenTableCell.self, forCellReuseIdentifier: ScreenTableCell.identifier)
        screenTableView.delegate = self
        screenTableView.dataSource = self
        screenTableView.rowHeight = 60
    }
    
    private func registerCollectionView(customCollectionView: UICollectionView) {
        customCollectionView.register(ScreenCollectionCell.self, forCellWithReuseIdentifier: reuseId)
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
        $0.setTitle("Continue", for: .normal)
        $0.setTitleColor(.cyan, for: .normal)
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 5
        $0.addTarget(self, action: #selector(continueBtnTapped), for: .touchUpInside)
    }
    
    private let makeBtn = UIButton().then {
        //        $0.setTitle("Create", for: .normal)
        //        $0.setTitleColor(.cyan, for: .normal)
        //        $0.layer.borderColor = UIColor.blue.cgColor
        //        $0.layer.borderWidth = 1
        
        let someImage = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        $0.addTarget(self, action: #selector(makeBtnTapped), for: .touchUpInside)
    }
    
    private let detailBtn = UIButton().then {
        $0.setTitle("See Detail", for: .normal)
        $0.setTitleColor(.cyan, for: .normal)
        $0.layer.borderColor = UIColor.blue.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.addTarget(self, action: #selector(detailBtnTapped), for: .touchUpInside)
    }
    
    //    private let deleteBtn = UIButton().then {
    //        $0.setTitle("Delete", for: .normal)
    //        $0.setTitleColor(.red, for: .normal)
    //        $0.layer.borderColor = UIColor.red.cgColor
    //        $0.layer.borderWidth = 1
    //        $0.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
    //    }
    
    @objc func makeBtnTapped(_ sender: UIButton) {
        print("makeBtnTapped!")
        Screen.save(belongTo: subject)
        selectedIndex = IndexPath(row: -1, section: 0)
        
        
        fetchAndReloadScreens()
    }
    
    
    @objc func continueBtnTapped(_ sender: UIButton) {
        print("continueBtnTapped!")
        print("numofScreens: \(subject.screens.count)")
        
        if selectedScreen == nil {
            selectedScreen = screens.sorted { $0.date < $1.date}.last
        }
        
        guard let selectedScreen = selectedScreen else {
            fatalError("selected screen is nil", file: #function)
        }
        selectedIndex = IndexPath(row: -1, section: 0)
        
        
        
        
        detailDelegate?.sendback(subject, with: selectedScreen)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func detailBtnTapped(_ sender: UIButton) {
        print("detail Tapped!")
        guard let selectedScreen = selectedScreen else {
            return
        }
        selectedIndex = IndexPath(row: -1, section: 0)
        
        
        let trialDetailController = TrialDetailController(screen: selectedScreen)
        print("passing screen id: \(selectedScreen.id)")
        self.navigationController?.pushViewController(trialDetailController, animated: true)
    }
    
    //    @objc func deleteBtnTapped(_ sender: UIButton) {
    //        print("deleteBtn Tapped!")
    //        guard let selectedScreen = selectedScreen else {
    //            print("none is selected")
    //            return
    //        }
    //
    ////        Screen.delete(selectedScreen)
    //        Screen.deleteSelf(selectedScreen)
    //        selectedIndex = IndexPath(row: -1, section: 0)
    //        print("deleted !")
    //        fetchAndReloadScreens()
    //        print("fetched!")
    //    }
    
    
    
    init(subject: Subject, frame: CGRect = .zero) {
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
        self.title = subject.name
    }
    
    
    
    
    
    private func fetchAndReloadScreens() {
        
        print("before fetch and reload, screen count: \(screens.count) \n screen fetched: \(screens) ")
        
        switch subject.screens.count {
            //        case 0: continueBtn.setTitle("Start Testing", for: .normal)
        case 0: screens = []
            //        case 1: screens.append(subject.screens.first!)
        case 1: screens = [subject.screens.first!]
        default: // > 1
            
            screens = subject.screens.sorted(by: { screen1, screen2 in
                print("its sorting .. ")
                return screen1.date < screen2.date
            })
        }
        
        //        reloadCollectionView()
        reloadTableView()
        
        print("after fetch and reload, fetched screen count: \(screens.count)")
    }
    
    private func reloadCollectionView() {
        DispatchQueue.main.async {
            self.screenCollectionView.reloadData()
        }
    }
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.screenTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndReloadScreens()
        registerCollectionView(customCollectionView: screenCollectionView)
        registerTableView()
        screenCollectionView.reloadData()
        setupLayout()
        configureLayout()
        
    }
    
    private let btnStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 10
    }
    
    private func setupLayout() {
        
        //        let btnStackView = UIStackView(arrangedSubviews: [makeBtn, continueBtn, detailBtn, deleteBtn]).then {
        //        }
        //        btnstackview
        
        //        btnStackView.arrangedSubviews = [makeBtn, continueBtn, detailBtn, deleteBtn]
        //        [makeBtn, ]
        
        [
            //            makeBtn,
            continueBtn, detailBtn
            //         , deleteBtn
        ].forEach {
            btnStackView.addArrangedSubview($0)
        }
        
        [imageView, nameLabel, detailInfoLabel, phoneLabel,
         //         makeBtn, continueBtn, detailBtn, deleteBtn,
         btnStackView,
         //         screenCollectionView
         screenTableView,
         makeBtn
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
        
        
        
        //        continueBtn.snp.makeConstraints { make in
        //            make.centerX.equalToSuperview()
        //            make.bottom.equalTo(view.snp.bottom).offset(-60)
        //            make.width.equalTo(200)
        //            make.height.equalTo(50)
        //        }
        btnStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.snp.bottom).offset(-60)
            make.height.equalTo(50)
        }
        
        screenTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(continueBtn.snp.top).offset(-20)
        }
        
        //        screenCollectionView.snp.makeConstraints { make in
        //            make.leading.equalToSuperview().offset(20)
        //            make.top.equalTo(imageView.snp.bottom).offset(30)
        //            make.trailing.equalToSuperview().offset(-20)
        //            make.bottom.equalTo(continueBtn.snp.top).offset(-20)
        //        }
        
        makeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(btnStackView.snp.top).offset(-30)
            make.width.height.equalTo(60)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ScreenCollectionCell
        //        cell.delegate = self
        
        cell.viewModel = ScreenViewModel(screen: screens[indexPath.row], index: indexPath.row)
        //        cell.tag = indexPath.row
        
        if selectedIndex == indexPath { cell.backgroundColor = .red } else { cell.backgroundColor = .clear }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedScreen = screens[indexPath.row]
        
        selectedIndex = indexPath
        
        collectionView.reloadData()
        
        print("selected screen index: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        //         set selectedIndex none
        selectedIndex = IndexPath(row: -1, section: 0)
        Screen.deleteSelf(screens[indexPath.row])
        
        fetchAndReloadScreens()
        
    }
    
}

extension SubjectDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScreenTableCell.identifier, for: indexPath) as! ScreenTableCell
        
        cell.viewModel = ScreenViewModel(screen: screens[indexPath.row], index: indexPath.row)
        // set selected Color green
        if selectedIndex == indexPath { cell.backgroundColor = .green } else { cell.backgroundColor = .clear }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedScreen = screens[indexPath.row]
        
        selectedIndex = indexPath
        
        // reloadData
        screenTableView.reloadData()
        print("selected screen index: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            
            
            //            tableView.deleteRows(at: [indexPath], with: .fade)
            let screenToDelete = self.screens[indexPath.row]
            //            Screen.deleteSelf(self.screens[indexPath.row])
            Screen.deleteSelf(screenToDelete)
            //            self.screens.remove(at: indexPath.row)
            self.subject.screens.remove(screenToDelete)
            self.fetchAndReloadScreens()
            //            tableView.reloadData()
            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }
    
    
}
