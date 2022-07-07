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
import Photos

class MovementListController: UIViewController {
    
    // MARK: - Properties
    
    var userDefaultSetup = UserDefaultSetup()
    var systemSoundID: SystemSoundID = 1016
    var connectionManager = ConnectionManager()
    
    private var isCameraVisible = false
    private var isCameraPresented = false
    var screen: Screen?
    
    var cameraVC: CameraController?
    
    var count = 0
    var durationTimer: Timer?
    
    var subject: Subject?
    
    var selectedTrialCore: TrialCore?
    
    var completeConditionViewModels: [MovementViewModel] = []
    
    // TODO: change to false after some updates..
    // TODO: false -> 정상 작동 ;;
    
    var testMode = false
    
    /// trialCoresToShow 만드는 재료
    var trialCores: [[TrialCore]] = [[]]
    
    /// [ [DeepSquat], [Hurdle Step Left, Hurdle Step Right], ... ]
    /// MovementViewModel 에 사용
    var trialCoresToShow: [[TrialCore]] = [[]]
    
    var rank: Rank?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear triggered")
        // TODO: update !
        
    }
    
    private func initializeViewModels() {
        completeConditionViewModels = []
    }
    
    private func checkConditionForViewModels() {
        print("checkConditionForViewModels called!!")
        var isCompleted = true
        
        for eachViewModel in completeConditionViewModels {
            print("eachViewModel's title: \(eachViewModel.title)")
            eachViewModel.scoreLabel.forEach {
                if $0 == "N" || $0 == "L" || $0 == "R" {
                    print("scoreLabel: \($0)")
                    isCompleted = false
                }
            }
            
            if isCompleted == false { break }
        }
        
        if isCompleted {
            
            applyStyle(to: completeBtn, selectable: true)
            
            guard let screen = screen else { fatalError() }
            screen.isFinished = true
            
            applyStyle(to: finishBtn, selectable: false)
        }
    }
    
    private func applyStyle(to btn: UIButton, selectable: Bool) {
        DispatchQueue.main.async {
            if selectable {
                btn.setTitleColor(.white, for: .normal)
                btn.backgroundColor = .red500
                btn.isUserInteractionEnabled = true
            } else {
                btn.setTitleColor(.gray400, for: .normal)
                btn.backgroundColor = .lavenderGray100
                btn.isUserInteractionEnabled = false
            }
        }
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
        AppUtility.lockOrientation(.portrait)
        
        view.insetsLayoutMarginsFromSafeArea = false
        print("viewDidLoad in MovementListController called") // not called..
        
        registerCollectionView()
        connectionManager.delegate = self
        
        // 여기에서 에러
//        fetchDefaultScreen() // 이거... Peer 한테 필요한거야? 아마도 ?
        
        updateTrialCores(screen: screen)
        setupLayout()
        setupAddTargets()
        addNotificationObservers()
//        testCode()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func testCode() {
        
    }
    
    // success
    private func createAlbumIfNotExist(albumName: String) {
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var albumNames = Set<String>()
        albumsPhoto.enumerateObjects({(collection, index, object) in
            let photoInAlbums = PHAsset.fetchAssets(in: collection, options: nil)
//            print("print photoAlbum info")
//            print(photoInAlbums.count)
            print(collection.localizedTitle!)
            albumNames.insert(collection.localizedTitle!)
        })
        // if given albumName not exist, create .
        if albumNames.contains(albumName) == false {
          // Create
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }) { success, error in
                if success {
                    print("successFully create file of name: \(albumName)")
                } else {
                    print("error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    // call if no screen assigned
    
//    func fetchDefaultScreen() {
//        print("fetchDefaultScreen called")
//        // false -> error !
//        if testMode {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate")}
//
//            let subjectContext = appDelegate.persistentContainer.viewContext
//
//            let subjectReq = NSFetchRequest<NSFetchRequestResult>(entityName: .CoreEntitiesStr.Subject)
//            subjectReq.returnsObjectsAsFaults = false
//
//            do {
//                let result = try subjectContext.fetch(subjectReq)
//                guard let fetchedSubjects = result as? [Subject] else { fatalError("failed to cast result to [Subject]")}
//
//                if !fetchedSubjects.isEmpty {
//                    subject = fetchedSubjects.first!
//                }
//
//                guard let subject = subject else {
//                    // no subject
//
//                    fatalError(" empty subject ")
//                }
//
//                if subject.screens.isEmpty == false {
//                    screen = subject.screens.sorted{$0.date < $1.date}.first
//
//                    updateTrialCores(screen: screen)
//                    print("updateTrialCores called")
//                } else {
//                    print("subject has no screen")
//                }
//
//            } catch {
//                fatalError("failed to fetch subjects!")
//            }
//        }
//    }
    
    private func registerCollectionView() {
        movementCollectionView.register(MovementCell.self, forCellWithReuseIdentifier: MovementCell.cellId)
        movementCollectionView.delegate = self
        movementCollectionView.dataSource = self
    }
    
    // MARK: - Btn Action
    
    private func setupAddTargets() {
        sessionBtn.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
        
        finishBtn.addTarget(self, action: #selector(moveToInspectorController), for: .touchUpInside)
        
        subjectSettingBtn.addTarget(self, action: #selector(moveToInspectorController), for: .touchUpInside)
        
        completeBtn.addTarget(self, action: #selector(moveToInspectorController), for: .touchUpInside)
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
          moveToInspectorController()
        
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
          moveToInspectorController()
    }
    
    @objc func finishBtnTapped(_ sender: UIButton) {
          moveToInspectorController()
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(createAlbum(_:)),
            name: .sendAlbumNameInfoKey, object: nil)
    }
    
    @objc func createAlbum(_ notification: Notification) {
//        guard let receivedAlbumNameInfo = notification.userInfo?[""]
        let upperIndex = (notification.userInfo?["upperIndex"])! as! Int
        let subjectName = (notification.userInfo?["subjectName"])! as! String
        print("new album name : \(upperIndex), from movementListController")
        createAlbumIfNotExist(albumName: "\(upperIndex)")
    }
    
    
    @objc func setScreen(_ notification: Notification) {
        print("setScreen called")
        guard let receivedScreen = notification.userInfo?["screen"] as? Screen else { fatalError() }
        
        screen = receivedScreen
        guard let screen = screen else {
            fatalError()        }
        
        guard let parentSubject = screen.parentSubject else { fatalError() }
//        let subjectName = SubjectName(name: parentSubject.name)
        //        self.updatePeopleInfo(with: screen!)?
        
        self.updatePeopleInfo(with: screen)
        self.updateTrialCores(screen: screen)
        
        let subjectName = parentSubject.name
//        let screenIndex = screen.screenIndex + 1
        let upperIndex = screen.upperIndex + 1
        
//        let albumNameInfo = AlbumNameInfo(subjectName: parentSubject.name, screenIndex: Int(screen.screenIndex))
        
        let albumNameInfo = AlbumNameInfo(subjectName: subjectName, upperIndex: Int(upperIndex))
        

        connectionManager.send(PeerInfo(msgType: .sendAlbumNameInfo, info: Info(albumNameInfo: albumNameInfo)))
//        print("screen's upperIndex: \()")
        connectionManager.upperIndex = Int(upperIndex)
        let msg = "new album name : \(upperIndex), from movementListController"
        
        printFlag(type: .upperIndex, count: 0, message: msg)
        
        createAlbumIfNotExist(albumName: "\(upperIndex)")
        
        print("current ScreenIndex from setScreen: \(upperIndex)")
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
        
        if isCameraOn == false {
            printFlag(type: .defaultSubjectScreen, count: 0)
            
            //        guard let subject = subject else { fatalError("fail to get subject ")}
            
            //            guard let screen = screen else { fatalError(" fail to get screen")}
            
//            createAlbumIfNotExist(albumName: <#T##String#>)
            
            guard let title = notification.userInfo?["title"] as? String,
                  let direction = notification.userInfo?["direction"] as? MovementDirection
                    //                ,let score = notification.userInfo?["score"] as? Int?
            else {
                print("failed to converting userInfo back.")
                return }
            
            //            let trialCore = screen.trialCores.filter {
            //                $0.title == title && $0.direction == direction.rawValue
            //            }.first!
            
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
        
        // screen 유효하면 self.screen 에 넣고 없으면 만들어서 넣기.
        if screen != nil {
            self.screen = screen!
        } else {
            let newScreen = Screen.save()
//            self.screen = Screen.save() // default Screen
            newScreen.screenIndex = Int64(userDefaultSetup.upperIndex)
            
            userDefaultSetup.upperIndex += 1
            self.screen = newScreen
            
        }
        
        guard let screen = self.screen else { fatalError() }
        
        //        let sortedCores = self.screen!.trialCores.sorted {
        // 먼저 운동 순서대로, 같은 운동의 경우 좌우 순서로 넣기.
        let sortedCores = screen.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
        
        print("---------- sorted Cores: ----------")
        
        // sortedCores: [Deep Squat, Deep Squat Var, Hurdle Step Left, Hurdle Step Right, ... ]
        
        // trialCores 에 잘 분류해서 넣기 위해 선언한 이전 sortedCore 값
        var prev = sortedCores.first!
        
        // TODO: 이건 또 뭐야 ??
        self.trialCores.append([])
        
        for eachCore in sortedCores {
            if prev.title == eachCore.title {
                self.trialCores[self.trialCores.count - 1].append(eachCore)
            } else {
                self.trialCores.append([eachCore])
            }
            prev = eachCore
        }
        print("--------- sortedCores: ---------")
        for eachCore in sortedCores {
            print("title: \(eachCore.title), direction: \(eachCore.direction)")
        }
        self.trialCores.removeFirst()
        
        // initialize
        trialCoresToShow = [[]]
        
        print("----------------- trialCores: -----------------")
        for eachCoreArray in trialCores {
            for eachCore in eachCoreArray {
                print("title: \(eachCore.title), direction: \(eachCore.direction)")
            }
        }
        
        for (index, eachCore) in trialCores.enumerated() {
            // hanmok, 여기 잘못됨. 애초에, 받는 애가.. 잘못됐음.. ??
            // 음.. deep squat 의 경우, Deep Squat 과 Variation 을 비교해서,
            // Variation 의 trialNo 가 Deep Squat 과 '같을 시' Variation 의 점수 반영해야함.
            
            // basic moves
            if MovementImgsDictionary[eachCore.first!.title] != nil {
                
                trialCoresToShow.append(eachCore)
                if let variationCoreName = movementWithVariation[eachCore.first!.title] {
                    
                    let matchedVariationCore = trialCores[index + 1]
                    if !(eachCore.first!.updatedDate >= matchedVariationCore.first!.updatedDate) {
                        trialCoresToShow[trialCoresToShow.count - 1].append(matchedVariationCore.first!)
                    }
                }
            }
        }
        
        
        trialCoresToShow.removeFirst()
        
        print("----------------- trialCoresToShow: -----------------")
        for (index, eachCoreArray) in trialCoresToShow.enumerated() {
            print("index: \(index)")
            for eachCore in eachCoreArray {
                print("title: \(eachCore.title), direction: \(eachCore.direction)")
            }
            
        }
        
        initializeViewModels()
        
        DispatchQueue.main.async {
            self.movementCollectionView.reloadData()
        }
    }
    
    // MARK: - UI, Navigation Functions
    
    @objc func moveToInspectorController() {
        
        let inspectorVC = InspectorController()
//        SoundService.shared.someFunc()
//        AudioServicesPlaySystemSound(systemSoundId)
        let uiNavController = UINavigationController(rootViewController: inspectorVC)
        
        self.present(uiNavController, animated: true)
    }
    
    private func presentCamera(with selectedTrial: TrialCore) {
        
        rank = .boss
        guard let rank = rank else { fatalError() }
        
        // boss 는 반드시 default가 아닌 Screen 이 있어야 Camera 로 이동
        
        guard screen?.parentSubject != nil else {
            self.moveToInspectorController()
            return
        }
        
        
        let direction: MovementDirection = MovementDirection(rawValue: selectedTrial.direction) ?? .neutral
        
        print("trialCore passed to cameracontroller : \(selectedTrial.title) \(selectedTrial.direction)")
        
        presentCameraAsChild(trialCore: selectedTrial, rank: rank, title: selectedTrial.title, direction: direction)
        
        
        connectionManager.send(PeerInfo(msgType: .presentCameraMsg, info: Info(movementTitleDirection: MovementTitleDirectionInfo(title: selectedTrial.title, direction: direction))))
        
        
    }
    
    private func presentCameraAsChild(trialCore: TrialCore? = nil, rank: Rank, title: String, direction: MovementDirection) {
        
        DispatchQueue.main.async {
            if self.isCameraPresented == false {
                
                if rank == .boss {
                    print("screen from MovementListController: \(self.screen)")
                    guard let screen = self.screen,
                          let subject = screen.parentSubject else {
                        return
                    }

                    self.cameraVC = CameraController(connectionManager: self.connectionManager, screen: self.screen, trialCore: trialCore!, positionTitle: title, direction: direction, rank: rank)
                    self.cameraVC?.delegate = self
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
                
                self.isCameraPresented = true
            
            } else {
                
                self.showUpCamera()
                if rank == .boss {
                    self.cameraVC?.updateTrialCore(with: trialCore!)
                    self.cameraVC?.prepareScoreController(trialCore: trialCore!, screen: self.screen!)
                }
                
                self.cameraVC?.stopDurationTimer()
                self.cameraVC?.updateLabel(title: title, direction: direction)
                self.cameraVC?.hidePreview()
                self.cameraVC?.resetTimer()
                self.cameraVC?.invalidateTimer()
            }
        }
    }
    
    private func showUpCamera() {
        print("showUpCamera!")
        
        guard let cameraVC = cameraVC else {
            fatalError()
        }
        
        UIView.animate(withDuration: 0.3) {
            cameraVC.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
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
        let viewModel = MovementViewModel(trialCores: trialCoresToShow[indexPath.row])
        
        
        //        cell.viewModel = MovementViewModel(trialCores: trialCoresToShow[indexPath.row])
        cell.viewModel = viewModel
        
        //        completeConditionViewModels.append(trialCoresToShow[indexPath.row])
        completeConditionViewModels.append(viewModel)
        
        if indexPath.row == trialCoresToShow.count - 1 {
            checkConditionForViewModels()
        }
        
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
//        SoundService.shared.someFunc()
    }
    
    func dismissCamera(closure: () -> Void) {
        isCameraVisible = false
        guard let cameraVC = cameraVC else {
            print("cameraVC is nil!", #file, #function, #line)
            return }
        
        UIView.animate(withDuration: 0.3) {
            cameraVC.view.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
            
        } completion: { done in
            
            // TODO: remove cameraController after animation
            
            if done {
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



extension URL {
    @discardableResult
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
