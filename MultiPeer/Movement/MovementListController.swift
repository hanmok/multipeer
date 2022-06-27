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
    
    var subject: Subject?
    
    var selectedTrialCore: TrialCore?
    
    // TODO: change to false after some updates..
    // TODO: false -> 정상 작동 ;;
    
    var testMode = false
//    var testMode = true
    
    var trialCores: [[TrialCore]] = [[]]
    /// 화면에 나타날 trialCores
    var trialCoresToShow: [[TrialCore]] = [[]]
    
    var rank: Rank?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear triggered")
        // TODO: update !

    }
    
    // MARK: - UI Properties
    
    private let inspectorLabel = UILabel().then {
        $0.textColor = .black
    }
    
    private let subjectLabel = UILabel().then {
        $0.textColor = .black
    }
    
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
        collectionView.backgroundColor = .lavenderGray50
        return collectionView
    }()
    
        private let completeBtn: UIButton = {
            let btn = UIButton()
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let attrText = NSMutableAttributedString(string: "Complete Screen\n", attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ])
            
            btn.setAttributedTitle(attrText, for: .normal)
            btn.setTitleColor(.gray400, for: .normal)
            btn.backgroundColor = .lavenderGray100
            btn.layer.cornerRadius = 8
            return btn
        }()
    
    private let finishBtn = UIButton().then {
        $0.setTitle("Finish Later", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .red500
        $0.layer.cornerRadius = 8
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = .lavenderGray50
    }
    
    private let leftConnectionStateView = UIView().then {
        $0.backgroundColor = .lavenderGray300
        $0.layer.cornerRadius = 5
    }
    
    private let rightConnectionStateView = UIView().then {
        $0.backgroundColor = .lavenderGray300
        $0.layer.cornerRadius = 5
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear Triggered ")
    }
//    viewwillappear
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insetsLayoutMarginsFromSafeArea = false
        print("viewDidLoad in MovementListController called")
        
        registerCollectionView()
        connectionManager.delegate = self

        // 여기에서 에러
        fetchDefaultScreen() // 이거... Peer 한테 필요한거야? 아마도 ?
        
        updateTrialCores(screen: screen)
        setupLayout()
        setupAddTargets()
        addNotificationObservers()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // call if no screen assigned

    func fetchDefaultScreen() {
        print("fetchDefaultScreen called")
        // false -> error !
        if testMode {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate")}
            
            let subjectContext = appDelegate.persistentContainer.viewContext
            
            let subjectReq = NSFetchRequest<NSFetchRequestResult>(entityName: .CoreEntitiesStr.Subject)
            subjectReq.returnsObjectsAsFaults = false
            
            do {
                let result = try subjectContext.fetch(subjectReq)
                guard let fetchedSubjects = result as? [Subject] else { fatalError("failed to cast result to [Subject]")}
                
                if !fetchedSubjects.isEmpty {
                    subject = fetchedSubjects.first!
                }
                
                guard let subject = subject else {
                    // no subject

                    fatalError(" empty subject ")
                }
                
                if subject.screens.isEmpty == false {
                    screen = subject.screens.sorted{$0.date < $1.date}.first
                    
                    updateTrialCores(screen: screen)
                    print("updateTrialCores called")
                } else {
                    print("subject has no screen")
                }
                
            } catch {
                fatalError("failed to fetch subjects!")
            }
        }
    }
    
    private func registerCollectionView() {
        movementCollectionView.register(MovementCell.self, forCellWithReuseIdentifier: MovementCell.cellId)
        movementCollectionView.delegate = self
        movementCollectionView.dataSource = self
    }
    
    // MARK: - Btn Action
    
    private func setupAddTargets() {
        sessionBtn.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
        
        finishBtn.addTarget(self, action: #selector(moveToSubjectController), for: .touchUpInside)
        
        subjectSettingBtn.addTarget(self, action: #selector(moveToSubjectController), for: .touchUpInside)
        
        completeBtn.addTarget(self, action: #selector(moveToSubjectController), for: .touchUpInside)
    }
    
    // TODO: Host 인 경우, 어떤 값을 설정해주기.
    @objc func showConnectivityAction(_ sender: UIButton) {
        print("connect btn tapped!!")
        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
            self.connectionManager.isHost = true
            self.connectionManager.numOfPeers = 0
            self.connectionManager.delegate?.updateState(state: .disconnected, connectedAmount: 0)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
            self.connectionManager.isHost = false
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @objc func subjectBtnTapped(_ sender: UIButton) {
        moveToSubjectController()
        
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
        moveToSubjectController()
    }
    
    @objc func finishBtnTapped(_ sender: UIButton) {
        moveToSubjectController()
    }
    
    
    
    
    // MARK: - Notifiaction Observers
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentCameraNoti(_:)),
            name: .presentCameraKey, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setScreen(_:)),
            name: .screenSettingKey, object: nil)
    }
    
    @objc func setScreen(_ notification: Notification) {
        
        guard let receivedScreen = notification.userInfo?["screen"] as? Screen else { fatalError() }
        
        screen = receivedScreen

        self.updatePeopleInfo(with: screen!)
        self.updateTrialCores(screen: screen)
        
        dismiss(animated: true)
    }
    
    private func updatePeopleInfo(with screen: Screen) {
        guard let subject = screen.parentSubject,
              let inspector = subject.inspector else { fatalError() }
        
        inspectorLabel.text = inspector.name
        subjectLabel.text = subject.name
    }
    
    // 여기서 Crash 발생. Why ??
    @objc func presentCameraNoti(_ notification: Notification) {
        
        if !isCameraOn {
            printFlag(type: .defaultSubjectScreen, count: 0)
            
            //        guard let subject = subject else { fatalError("fail to get subject ")}
            
            guard let screen = screen else { fatalError(" fail to get screen")}
            
            
            guard let title = notification.userInfo?["title"] as? String,
                  let direction = notification.userInfo?["direction"] as? MovementDirection
                    //                ,let score = notification.userInfo?["score"] as? Int?
            else {
                print("failed to converting userInfo back.")
                return }
            
            let trialCore = screen.trialCores.filter {
                $0.title == title && $0.direction == direction.rawValue
            }.first!
            
            presentCameraAsChild(rank: .follower, title: title, direction: direction)
        } else {
            // update peer's camera title
        }
    }
    
    // MARK: - Helper Functions
    
    private func updateScoreLabels() {
        // TODO: Update if score has changed using MovementCollectionCell
        print("updateScoreLabels Called ")
        updateTrialCores(screen: screen)
    }
    


    private func updateTrialCores(screen: Screen? = nil) {
        print("screen is nil? \(screen == nil)")
        print("updateTrialCores Called ")
        self.trialCores = [[]] // initialize
        
        if screen != nil { self.screen = screen! } else {
            self.screen = Screen.save() // default Screen
        }
        //        guard let screen = screen else { fatalError("empty screen")}
        //        guard screen.trialCores.count != 0 else { fatalError("empty trialCore")}
        // 여기서 터짐.
        
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
        
        DispatchQueue.main.async {
            self.movementCollectionView.reloadData()
        }
    }
    
    // MARK: - UI, Navigation Functions
    
    @objc func moveToSubjectController() {

        
        let inspectorVC = InspectorController()
        
        let uinavController = UINavigationController(rootViewController: inspectorVC)

        self.present(uinavController, animated: true)
    }
    
    private func presentCamera(with selectedTrial: TrialCore) {
        
        rank = .boss
        guard let rank = rank else { fatalError() }
        
        guard let screen = screen else {
            self.moveToSubjectController()
            return
        }
        
        let direction: MovementDirection = MovementDirection(rawValue: selectedTrial.direction) ?? .neutral
        
        print("trialCore passed to cameracontroller : \(selectedTrial.title) \(selectedTrial.direction)")
        
        presentCameraAsChild(trialCore: selectedTrial, rank: rank, title: selectedTrial.title, direction: direction)
    
        
        connectionManager.send(PeerInfo(msgType: .presentCameraMsg, info: Info(movementTitleDirection: MovementTitleDirectionInfo(title: selectedTrial.title, direction: direction))))
    }
    
    private func presentCameraAsChild(trialCore: TrialCore? = nil, rank: Rank, title: String, direction: MovementDirection) {
        
//        guard let screen = screen else { fatalError() }
        
        DispatchQueue.main.async {
            var hasCameraAlready = false
            
            let children = self.children
            print("list of children : \(children)")
            for child2 in children {
                if child2 is CameraController {
                    hasCameraAlready = true
                    break
                }
            }
            
            if hasCameraAlready == false {
                if rank == .boss {
                    self.cameraVC = CameraController(connectionManager: self.connectionManager, screen: self.screen, trialCore: trialCore!, positionTitle: title, direction: direction, rank: rank)
                
                } else {
                    self.cameraVC = CameraController(connectionManager: self.connectionManager, screen: nil, trialCore: nil, positionTitle: title, direction: direction, rank: rank)
                }
                
                guard self.cameraVC != nil else { return }
                self.cameraVC!.delegate = self
                self.addChild(self.cameraVC!)
                
                self.view.addSubview(self.cameraVC!.view)
                
                self.cameraVC!.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
                
                UIView.animate(withDuration: 0.3) {
                    self.cameraVC!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
                }
            } else {
                self.cameraVC?.hidePreview()
                self.cameraVC?.resetTimer()
                self.cameraVC?.invalidateTimer()
            }
        }
    }
    
    private var isCameraOn: Bool {
        var result: Bool?
        DispatchQueue.main.async {
            let children = self.children
            
            for child2 in children {
                if child2 is CameraController {
                    result = true
                    break
                }
            }
        }
        return result ?? false
    }
    
    
    
    private func setupLayout() {
        
        view.addSubview(sessionBtn)
        sessionBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
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
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(inspectorLabel)
        inspectorLabel.snp.makeConstraints { make in
            make.leading.equalTo(subjectSettingBtn.snp.trailing).offset(5)
            make.height.equalTo(16)
            make.width.equalTo(150)
            make.top.equalTo(subjectSettingBtn.snp.top)
        }
        
        
        view.addSubview(subjectLabel)
        subjectLabel.snp.makeConstraints { make in
            make.leading.equalTo(subjectSettingBtn.snp.trailing).offset(5)
            make.width.equalTo(150)
            make.height.equalTo(14)
            make.bottom.equalTo(subjectSettingBtn.snp.bottom)
        }
        
        
        self.view.addSubview(movementCollectionView)
        movementCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(sessionBtn.snp.bottom).offset(15)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        
        self.view.addSubview(finishBtn)
        finishBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(32)
            make.width.equalTo(screenWidth / 2 - 20 - 8)
            make.height.equalTo(48)
        }
        
        self.view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.leading.equalTo(finishBtn.snp.trailing).offset(16)
            make.bottom.equalToSuperview().inset(32)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(48)
        }
        
        view.backgroundColor = .lavenderGray50
    }
    
    private func updateConnectionState() {
        
        DispatchQueue.main.async {
            switch self.connectionManager.numOfPeers {
                
            case 1:
                DispatchQueue.main.async {
                    self.leftConnectionStateView.backgroundColor = .red
                    self.rightConnectionStateView.backgroundColor = .lavenderGray300
                }
                
            case 2:
                DispatchQueue.main.async {
                    self.rightConnectionStateView.backgroundColor = .red
                    self.leftConnectionStateView.backgroundColor = .red
                }
            default:
                DispatchQueue.main.async {
                    self.leftConnectionStateView.backgroundColor = .lavenderGray300
                    self.rightConnectionStateView.backgroundColor = .lavenderGray300
                }
            }
        }
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

        cell.delegate = self

        cell.viewModel = MovementViewModel(trialCores: trialCoresToShow[indexPath.row])
        
        print("cell : \(cell.viewModel?.title)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = screenWidth / 2 - 28
        
        return CGSize(width: width, height: width)
    }
}


// MARK: - CameraController Delegate
extension MovementListController: CameraControllerDelegate {
    
    func makeSound() {
        // FIXME: make sound 보류.
    }
    
    func dismissCamera(closure: () -> Void) {
        guard let cameraVC = cameraVC else {
            print("cameraVC is nil!", #file, #function, #line)
            return }
        
        UIView.animate(withDuration: 0.3) {
            cameraVC.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        } completion: { done in
            
            // TODO: remove cameraController after animation
            if done {
                if self.children.count > 0 {
                    let viewControllers: [UIViewController] = self.children
                    for vc in viewControllers {
                        vc.willMove(toParent: nil)
                        vc.view.removeFromSuperview()
                        vc.removeFromParent()
                    }
                }
                
                self.updateScoreLabels()
                
                self.updateConnectionState()

            }
        }
    }
}


// MARK: - ConnectionManager Delegate
extension MovementListController: ConnectionManagerDelegate {
    
    // TODO: Update Connection Indicator on the right top (next to connect btn)
    func updateState(state: ConnectionState, connectedAmount: Int) {
        print("updateState called, connectedAmount: \(connectedAmount)")
        switch state {
        case .connected:
            self.connectionManager.numOfPeers = connectedAmount
            
            updateConnectionState()
            
        case .disconnected:
            self.connectionManager.numOfPeers = 0
            DispatchQueue.main.async {
                self.leftConnectionStateView.backgroundColor = .lavenderGray300
                self.rightConnectionStateView.backgroundColor = .lavenderGray300
            }
        }
    }
}


extension UIViewController {
    func printFlag(type: FlagType, count: Int, message: String = "" ) {
        let str = type.rawValue + ", " + "flag \(count)" + " " + message
        print(str)
    }
}
