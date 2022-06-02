//
//  NewMainViewController.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/27.
//


import UIKit
import SnapKit
import Then
import CoreData
import MobileCoreServices
import AVFoundation


class MovementListController: UIViewController {
    
    // MARK: - Properties
    var connectionManager = ConnectionManager()
    
    var screen: Screen?
    
    var cameraVC: CameraController?
    
    var count = 0
    var durationTimer: Timer?
    
    var subject: Subject? {
        didSet {
        }
    }
    
    // TODO: change to false after some updates..
    var testMode = true
    
    var trialCores: [[TrialCore]] = [[]]
    /// 화면에 나타날 trialCores
    var trialCoresToShow: [[TrialCore]] = [[]]
    
    var selectedTrialCore: TrialCore?
    
    // MARK: - UI Properties
    
    private let sessionBtn = UIButton().then {
        let attributedTitle = NSMutableAttributedString(string: "Connect", attributes: [.font: UIFont.systemFont(ofSize: 20)])
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let subjectSettingBtn = UIButton().then {
        let someImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        someImage.tintColor = .gray
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    private let movementCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255 , blue: 249 / 255, alpha: 1)
        return collectionView
    }()
    
    private let completeBtn = UIButton().then {
        $0.setTitle("Complete Screen", for: .normal)
        $0.setTitleColor(UIColor(red: 187 / 255 , green: 187 / 255, blue: 187 / 255, alpha: 1), for: .normal)
        $0.backgroundColor = UIColor(red: 237 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let finishBtn = UIButton().then {
        $0.setTitle("Finish Later", for: .normal)
        $0.setTitleColor(UIColor(red: 187 / 255 , green: 187 / 255, blue: 187 / 255, alpha: 1), for: .normal)
        $0.backgroundColor = UIColor(red: 237 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255, blue: 249 / 255, alpha: 1)
    }
    
    private let leftConnectionStateView = UIView().then {
        $0.backgroundColor = UIColor(red: 203/255, green: 202/255, blue: 211/255, alpha: 1)
        $0.layer.cornerRadius = 5
    }

    private let rightConnectionStateView = UIView().then {
        $0.backgroundColor = UIColor(red: 203/255, green: 202/255, blue: 211/255, alpha: 1)
        $0.layer.cornerRadius = 5
    }

    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad in MovementListController called")
        updateTrialCores()
        registerCollectionView()
        
        connectionManager.delegate = self
        
        fetchDefaultScreen()
        setupLayout()
        setupAddTargets()
        addNotificationObservers()
        
        printCurrentState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Btn Action
   
    private func setupAddTargets() {
        sessionBtn.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
        
        subjectSettingBtn.addTarget(self, action: #selector(subjectBtnTapped), for: .touchUpInside)
    }
    
    @objc func showConnectivityAction(_ sender: UIButton) {
        print("connect btn tapped!!")
        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func subjectBtnTapped(_ sender: UIButton) {
        moveToSubjectController()
    }
    
    // MARK: - Notifiaction Observers
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifiedPresentCamera(_:)),
            name: .presentCameraKey, object: nil)
    }
    
    @objc func notifiedPresentCamera(_ notification: Notification) {
        print("presentCamera triggered by observing notification")
        
        guard let subject = subject,
              let screen = screen else {
            fatalError("fail to get subject and screen. Plz select target first")
        }
        
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? MovementDirection,
              let score = notification.userInfo?["score"] as? Int? else {
            print("failed to converting userInfo back.")
            return }
        
        let movementWithDirectionInfo = MovementDirectionScoreInfo(title: title, direction: direction, score: score)
        
        guard let selectedTrialCore = selectedTrialCore else {
            return
        }
        
        print("trialCore passed to cameracontroller : \(selectedTrialCore.title) \(selectedTrialCore.direction)")
        
        DispatchQueue.main.async {
            let cameraVC = CameraController(
                connectionManager: self.connectionManager,
                screen: screen,
                trialCore: selectedTrialCore
            )
            
            self.present(cameraVC, animated: true)
        }
    }
    
    // call if no screen assigned
    func fetchDefaultScreen() {
        print("fetchDefaultScreen called")
        if testMode {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate")}
            
            let subjectContext = appDelegate.persistentContainer.viewContext
            
            let subjectReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
            subjectReq.returnsObjectsAsFaults = false
            
            do {
                let result = try subjectContext.fetch(subjectReq)
                guard let fetchedSubjects = result as? [Subject] else { fatalError("failed to cast result to [Subject]")}
                
                if !fetchedSubjects.isEmpty {
                    subject = fetchedSubjects.first!
                }
                guard let subject = subject else {
                    return
                }
                print("fetched Subject's name: \(subject.name)")
                if !subject.screens.isEmpty {
                    screen = subject.screens.sorted{$0.date < $1.date}.first
                    print("fetchedScreen date: \(screen?.date)")
                    //                    updateTrialCores(subject: subject, screen: screen!)
                    updateTrialCores(screen: screen)
                    print("updateTrialCores called")
                } else {
                    print("subject has no screen")
                }
                print("current Screen : \(screen)")
            } catch {
                fatalError("failed to fetch subjects!")
            }
        }
    }
    
    private func updateScoreLabels() {
        // TODO: Update if score has changed using MovementCollectionCell
        print("updateScoreLabels Called ")
        if let validScreen = screen {
            updateTrialCores(screen: validScreen)
        } else {
        updateTrialCores()
        }
    }
    
    
    
    
    
    // TODO: Default Screen 보다 , Default Subject 를 갖는게 더 좋지 않을까 ?
    
    private func updateTrialCores(screen: Screen? = nil) {
        print("updateTrialCores Called ")
        self.trialCores = [[]] // initialize
        
        if screen != nil { self.screen = screen! } else {
            self.screen = Screen.save() // default Screen
        }
        
        let sortedCores = self.screen!.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
        
        var prev = sortedCores.first!
        
        self.trialCores.append([])
        
        for eachCore in sortedCores {
            if prev.title == eachCore.title {
                self.trialCores[self.trialCores.count - 1].append(eachCore)
            } else {
                self.trialCores.append([eachCore])
            }
            prev = eachCore
        }
        
        self.trialCores.removeFirst()
        // TODO: Filter ! using MovementImgsDictionary
        trialCoresToShow = [[]]
        for eachCore in trialCores {
            if MovementImgsDictionary[eachCore.first!.title] != nil {
                trialCoresToShow.append(eachCore)
            }
        }
        trialCoresToShow.removeFirst()
        printCurrentState() //이거랑, 실제 받는 값과 어떤.. 차이가 있음. 뭐지 대체 ??

        // Async 때문에 아래 코드가 실행이 이상하게 되는걸까 ?
        
        // 여기 코드때문에 그래.. 왜지 ?? 왜지 ???
        // 이 코드 실행하지 않을 수는 없음 ;;
//        self.viewDidLoad() // 이거 너무 개뻘짓.. + iNfinite loop
        
        DispatchQueue.main.async {
            self.movementCollectionView.reloadData()
        }
    }
    
    private func printCurrentState() {
        print("Current State: \n\n")
        for eachCores in trialCores {
            for eachCore in eachCores {
                print("\(eachCore.title) , \(eachCore.direction), \(eachCore.latestScore)")
            }
        }
        print("End of Printing Current State")
    }
    
    
    
    // MARK: - Helper Functions
    
    private func moveToSubjectController() {
        let subjectSettingVC = SubjectController()
        subjectSettingVC.basicDelegate = self
        
        self.navigationController?.pushViewController(subjectSettingVC, animated: true)
    }
    
    // present camera like Navigation
    private func presentCamera(with selectedTrial: TrialCore) {
        
        guard let screen = screen else {
            self.moveToSubjectController()
            return
        }
        
        print("trialCore passed to cameracontroller : \(selectedTrial.title) \(selectedTrial.direction)")
        // TODO: direction 설정이 잘못됨 ;;;
        DispatchQueue.main.async {
            self.cameraVC = CameraController(
                connectionManager: self.connectionManager,
                screen: screen,
                trialCore: selectedTrial
            )
            
            guard self.cameraVC != nil else { return }
            self.cameraVC!.delegate = self
            self.addChild(self.cameraVC!) // 왜 Nav 말고 child 로 했었을까? ConnectionManager 때문에 ?
            self.view.addSubview(self.cameraVC!.view)
//            self.cameraVC!.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            self.cameraVC!.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
            
            UIView.animate(withDuration: 0.3) {
                self.cameraVC!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            }
        }
    }
    
    
    
    private func setupLayout() {
        
        view.addSubview(sessionBtn)
        sessionBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        view.addSubview(rightConnectionStateView)
        rightConnectionStateView.snp.makeConstraints { make in
            make.trailing.equalTo(sessionBtn.snp.leading).offset(-10)
            make.centerY.equalTo(sessionBtn.snp.centerY)
            make.width.height.equalTo(10)
        }
        
        view.addSubview(leftConnectionStateView)
        leftConnectionStateView.snp.makeConstraints { make in
            make.trailing.equalTo(rightConnectionStateView.snp.leading).offset(-8)
            make.centerY.equalTo(sessionBtn.snp.centerY)
            make.width.height.equalTo(10)
        }
        
        
        view.addSubview(subjectSettingBtn)
        subjectSettingBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.width.equalTo(40)
        }
        
        
        
        self.view.addSubview(movementCollectionView)
        movementCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.snp.bottom).offset(-120)
        }
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        

        self.view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(32)
            make.width.equalTo(screenWidth / 2 - 20 - 8)
            make.height.equalTo(48)
        }

        self.view.addSubview(finishBtn)
        finishBtn.snp.makeConstraints { make in
            make.leading.equalTo(completeBtn.snp.trailing).offset(16)
            make.bottom.equalToSuperview().inset(32)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(48)
        }
    
        
        view.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255, blue: 249 / 255, alpha: 1)
    }
    
    private func registerCollectionView() {
        movementCollectionView.register(MovementCell.self, forCellWithReuseIdentifier: MovementCell.cellId)
        movementCollectionView.delegate = self
        movementCollectionView.dataSource = self
    }
}

// MARK: - MovementCell Delegate
extension MovementListController: MovementCellDelegate {
    func cell(navToCameraWith trialCore: TrialCore) {
            presentCamera(with: trialCore)
    }
}


extension MovementListController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trialCoresToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell index: \(indexPath.row)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovementCell.cellId, for: indexPath) as! MovementCell
        //        print("")
        cell.delegate = self
//        print("num of trialsToShow: \(trialCoresToShow[indexPath.row].count)")
        cell.viewModel = MovementViewModel(trialCores: trialCoresToShow[indexPath.row])
        // RenderingBug: 여기서 문제가 있어보이지는 않는데 ...
        print("cell : \(cell.viewModel?.title)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = screenWidth / 2 - 28
        
        return CGSize(width: width, height: width)
    }
}

// 점수 처리는 대체 어디서 되는거야 ?


extension MovementListController: SubjectControllerDelegate {
    func updateCurrentScreen(from subject: Subject, with screen: Screen, closure: () -> Void) {
//        updateTrialCores(subject: subject, screen: screen)
        updateTrialCores(screen: screen)
        // when currentSubject set, it calls setupSubjectInfo()
        updateScoreLabels()
        closure()
    }
}


extension MovementListController: CameraControllerDelegate {
    func makeSound() {
        // TODO: make sound ?? 보류.
    }
    
    func dismissCamera() {
        guard let cameraVC = cameraVC else {
            print("cameraVC is nil!", #file, #function, #line)
            return }
        
        UIView.animate(withDuration: 0.3) {
//            cameraVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            cameraVC.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        } completion: { done in
            
            // TODO: remove cameraController after animation
//            if done {
//                if self.children.count > 0 {
//                    let viewControllers: [UIViewController] = self.children
//                    for vc in viewControllers {
//                        vc.willMove(toParent: nil)
//                        vc.view.removeFromSuperview()
//                        vc.removeFromParent()
//                    }
//                }
//            }
        }
        updateScoreLabels()
    }
}


extension MovementListController: ConnectionManagerDelegate {
    
    // TODO: Update Connection Indicator on the right top (next to connect btn)
    func updateState(state: ConnectionState) {
        switch state {
        case .connected: break
//            triggerDurationTimer()
        case .disconnected: break
//            stopDurationTimer()
        }
        
        DispatchQueue.main.async {
//            self.connectionStateLabel.text = state.rawValue
        }
    }
    
    func updateDuration(in seconds: Int) {
        DispatchQueue.main.async {
//            self.durationLabel.text = "\(seconds) s"
        }
    }
}
