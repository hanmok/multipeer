////
////  PositionSelectingController.swift
////  MultiPeer
////
////  Created by 핏투비 iOS on 2022/04/25.
////
//
//import UIKit
//import SnapKit
//import Then
//import CoreData
//import MobileCoreServices
//import AVFoundation
//
//class PositionController: UIViewController {
//    
//    // MARK: - Properties
//    
//    var connectionManager = ConnectionManager()
//    
//    var screen: Screen?
//    
//    var cameraVC: CameraController?
//    
//    var count = 0
//    var durationTimer: Timer?
//    
//    var subject: Subject? {
//        didSet {
//            setupSubjectInfo()
//        }
//    }
//    
//    var testMode = true
//    
//    func fetchDefaultScreen() {
//        print("fetchDefaultScreen called")
//        if testMode {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate")}
//            
//            let subjectContext = appDelegate.persistentContainer.viewContext
//            
//            let subjectReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
//            subjectReq.returnsObjectsAsFaults = false
//            
//            do {
//                let result = try subjectContext.fetch(subjectReq)
//                guard let fetchedSubjects = result as? [Subject] else { fatalError("failed to cast result to [Subject]")}
//                
//                if !fetchedSubjects.isEmpty {
//                    subject = fetchedSubjects.first!
//                }
//                guard let subject = subject else {
//                    return
//                }
//
//                if !subject.screens.isEmpty {
//                    screen = subject.screens.sorted{$0.date < $1.date}.first
//                    updateTrialCores(subject: subject, screen: screen!)
//                    print("updateTrialCores called")
//                } else {
//                    print("subject has no screen")
//                }
//                print("current Screen : \(screen)")
//            } catch {
//                fatalError("failed to fetch subjects!")
//            }
//        }
//    }
//
//    
//    var scoreBtnViews: [ScoreBtnView] = []
//    
//    var trialCores: [TrialCore] = []
//    
//    var selectedTrialCore: TrialCore?
//    
//    // Test
//    var decreasingTimer = Timer()
//    var systemSoundID: SystemSoundID = 1016
//    var decreasingCount = 3
//    
//    private let subjectNameLabel = UILabel().then { $0.textColor = .cyan
//        $0.textAlignment = .right
//    }
//    
//    private let subjectDetailLabel = UILabel().then { $0.textColor = .yellow
//        $0.textAlignment = .right
//    }
//    
//    private let deepSquat = PositionBlockView(MovementWithImageListEnum.deepsquat)
//    
//    private let hurdleStep = PositionBlockView(MovementWithImageListEnum.hurdleStep)
//    private let inlineLunge = PositionBlockView(MovementWithImageListEnum.inlineLunge)
//    private let ankleClearing = PositionBlockView(MovementWithImageListEnum.ankleClearing)
//    
//    private let shoulderMobility = PositionBlockView(MovementWithImageListEnum.shoulderMobility)
//    private let shoulderClearing = PositionBlockView(MovementWithImageListEnum.shoulderClearing)
//    private let straightLegRaise = PositionBlockView(MovementWithImageListEnum.straightLegRaise)
//    
//    private let stabilityPushup = PositionBlockView(MovementWithImageListEnum.stabilityPushup)
//    private let extensionClearing = PositionBlockView(MovementWithImageListEnum.extensionClearing)
//    
//    private let rotaryStability = PositionBlockView(MovementWithImageListEnum.rotaryStability)
//    private let flexionClearing = PositionBlockView(MovementWithImageListEnum.flexionClearing)
//    
//    
//    
//    private let topView = UIView().then { $0.backgroundColor = .systemPink}
//    
//    private let sessionButton = UIButton().then {
//        $0.setTitle("Connect", for: .normal)
//        $0.setTitleColor(.green, for: .normal)
//    }
//
//    
//    private let connectionStateLabel = UILabel().then {
//        $0.textColor = .black
//        $0.text = "Not Connected"
//    }
//    
//    private let durationLabel = UILabel().then { $0.textColor = .black
//        $0.text = "duration"
//    }
//    
//    private let subjectSettingBtn = UIButton().then {
//        
//        let someImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
//        someImage.tintColor = .white
//        $0.addSubview(someImage)
//        someImage.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
//    }
//    
//    private let testBtn = UIButton().then {
//        $0.setTitle("test", for: .normal)
//        $0.setTitleColor(.white, for: .normal)
//        $0.backgroundColor = .magenta
//    }
//    
//    
//
//    // MARK: - Life Cycle
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupLayout()
//        setupTargets()
//        connectionManager.delegate = self
//        addNotificationObservers()
//        
//        updateScoreLabels()
//        testCode()
//        fetchDefaultScreen()
//    }
//    
//    private func testCode() { // replacement for Playground ..
////        var ints = [1,5,6,3,4,4,0]
////
////        ints = ints.sorted { $0 < $1 }
////        print("ints: \(ints)")
//        for positionName in Dummy.MovementsShowing.allCases {
//            print("case  : \(positionName)")
//        }
//    }
//    
//    private func updateTrialCores(subject: Subject, screen: Screen) {
//        print("updateSubjectWithScreen")
//        self.subject = subject
//        self.screen = screen
//        
//        
//        guard subject != nil && screen != nil else { fatalError("either is nil")}
//        // 0 개 . why ?
//        print("total number of trialCores flag1: \(screen.trialCores.count)")
//        
//        
//        self.trialCores = screen.trialCores.sorted {
//            if $0.tag != $1.tag {
//                return $0.tag < $1.tag
//            } else {
//                return $0.direction.count < $1.direction.count
//            }
//        }
//    }
//    
//    private func updateScoreLabels() {
//        print("updateScoreLabels called")
//        
//        //TODO: Update Score ! for Each of PositionBlockView below
//        
//        for (index, eachTrial) in trialCores.enumerated() {
//            if index == 5 { eachTrial.latestScore = 2 } // For test
//            DispatchQueue.main.async {
//                print("numOfScoreBtnViews: \(self.scoreBtnViews.count)")
//                self.scoreBtnViews[index].scoreLabel.text = eachTrial.finalResult
//                print("updateScoreLabels score: \(eachTrial.finalResult)")
//            }
//        }
//    }
//    
//    private func setupSubjectInfo() {
//        guard let currentSubject = subject else { return }
//        subjectNameLabel.text = currentSubject.name
//        subjectDetailLabel.text = String(currentSubject.isMale ? "남" : "여") + " / " + String(calculateAge(from: currentSubject.birthday))
//    }
//    
//    
//    // MARK: - Targets
//    
//    private func setupTargets() {
//        
//        subjectSettingBtn.addTarget(self, action: #selector(subjectBtnTapped), for: .touchUpInside)
//        
//        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
//        
//        testBtn.addTarget(self, action: #selector(testBtnTapped), for: .touchUpInside)
//    }
//    // till here
//    
//    @objc func testBtnTapped(_ sender: UIButton) {
//        print("testBtnTapped")
//        
//        SoundService.shard.someFunc()
//        
////        AudioServicesPlaySystemSound(1104)
////        AudioServicesPlaySystemSound(systemSoundId)
//        
//        
////        decreasingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//////            print("triggerCoundDownTimerFlag 1 called")
////            guard let `self` = self else { return }
////            print("triggerCoundDownTimerFlag 2 called")
////
////            if self.decreasingCount > 0 {
////                print("triggerCoundDownTimerFlag 3 called")
////                self.decreasingCount -= 1
////                SoundService.shard.someFunc()
////                AudioServicesPlaySystemSound(self.systemSoundID)
////
////
////                print("triggerCoundDownTimerFlag 4 called")
////
////                if self.decreasingCount == 0 { // ????
////                    print("triggerCoundDownTimerFlag 5 called")
////                    AudioServicesPlaySystemSound(self.systemSoundID)
//////                    DispatchQueue.main.async {
//////                        self.recordingTimerBtn.setTitle("Recording!", for: .normal)
//////                    }
////                } else {
////                    // 세번 호출되어야함
////                        // 왜 두번밖에 호출되지 않았지 ?
////                        print("triggerCoundDownTimerFlag 6 called, decreasingCount : \(self.decreasingCount)")
////                        // make sound
////
////                        AudioServicesPlaySystemSound(self.systemSoundID)
//////                        AudioServicesPlaySystemSound(1104)
////
//////                        AudioServicesPlaySystemSound(1052)
//////                        DispatchQueue.main.async {
//////                        self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
//////                        }
////                    }
//////                }
////            } else { // self.decreasingCount <= 0
////                print("triggerCoundDownTimerFlag 7 called")
////                self.decreasingTimer.invalidate()
////                //                DispatchQueue.main.async {
////                //                    self.timerRecordingBtn.setTitle("Recording!", for: .normal)
////                //                }
////                self.decreasingCount = 3
////            }
////        }
//    }
//    
//    
//    @objc func subjectBtnTapped(_ sender: UIButton) {
//        moveToSubjectController()
//    }
//    
//    private func moveToSubjectController() {
//        let subjectSettingVC = SubjectController()
//        subjectSettingVC.basicDelegate = self
//
//        self.navigationController?.pushViewController(subjectSettingVC, animated: true)
//    }
//    
//    
//    @objc func showConnectivityAction(_ sender: UIButton) {
//        print("connect btn tapped!!")
//        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
//            self.connectionManager.host()
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
//            self.connectionManager.join()
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//    
//    @objc func imgTapped(_ sender: ButtonWithInfo) {
//        // TODO: move to cameraView With Info
//        print("img Tapped,")
//        let positionDirectionScoreInfo = sender.positionDirectionScoreInfo
//        
//        let title = positionDirectionScoreInfo.title
//        let direction = positionDirectionScoreInfo.direction
//        let score = positionDirectionScoreInfo.score
//        
//        selectedTrialCore = trialCores.filter { $0.title == title && $0.direction == direction.rawValue}.first
//        // direction !!!
//        
//        guard let selectedTrialCore = selectedTrialCore else {
//            self.moveToSubjectController()
//            return
//        }
//        
//        connectionManager.send(DetailPositionWIthMsgInfo(message: .presentCamera, detailInfo: MovementDirectionScoreInfo(title: title, direction: direction, score: score)))
//        
//        print("connectionManager has sent message")
//        
//        print("title: \(sender.positionDirectionScoreInfo.title)")
//        
//        print("direction: \(sender.positionDirectionScoreInfo.direction)")
//        
//        print("sender.score: \(sender.positionDirectionScoreInfo.score ?? 0)")
//        
//        presentCamera(positionDirectionScoreInfo: positionDirectionScoreInfo, with: selectedTrialCore)
//    }
//    
//    
//    // MARK: - Timer
//    /// update Duration
//    func triggerDurationTimer() {
//        print("timer triggered!!")
//        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else {
//                print("self is nil ")
//                return }
//            
//            print("hi!!!!!")
//            self.count += 1
//            DispatchQueue.main.async {
//                self.durationLabel.text = "\(self.count) s"
//            }
//        }
//    }
//    
//    private func stopDurationTimer() {
//        durationTimer?.invalidate()
//    }
//    
//    @objc func countUp() {
//        print("countUp triggered!!")
//        count += 1
//        
//        DispatchQueue.main.async {
//            self.durationLabel.text = String(self.count) + " s"
//        }
//    }
//    
//    
//    
//    
//    private func presentCamera(
//        positionDirectionScoreInfo: MovementDirectionScoreInfo,
//        with selectedTrial: TrialCore) {
//            
//        guard let screen = screen else {
//            self.moveToSubjectController()
//            return
//        }
//            
//            print("trialCore passed to cameracontroller : \(selectedTrial.title) \(selectedTrial.direction)")
//        // direction 설정이 잘못됨 ;;;
//            DispatchQueue.main.async {
//            self.cameraVC = CameraController(
////                positionDirectionScoreInfo: positionDirectionScoreInfo,
//                connectionManager: self.connectionManager,
//                screen: screen,
//                trialCore: selectedTrial
//            )
//            
//            guard self.cameraVC != nil else { return }
//            self.cameraVC!.delegate = self
//            self.addChild(self.cameraVC!)
//            self.view.addSubview(self.cameraVC!.view)
//            self.cameraVC!.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
//            
//            UIView.animate(withDuration: 0.3) {
//                self.cameraVC!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//            }
//        }
//    }
//    // till here
//    
//    // observer, add observer
//    // MARK: - NOTIFICATIONS
//    private func addNotificationObservers() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(notifiedPresentCamera(_:)),
//            name: .presentCameraKey, object: nil)
//    }
//    
//    /// triggered by Notification
//    @objc func notifiedPresentCamera(_ notification: Notification) {
//        print("presentCamera triggered by observing notification")
//        
//        guard let subject = subject,
//              let screen = screen else {
//            fatalError("fail to get subject and screen. Plz select target first")
//        }
//        
//        guard let title = notification.userInfo?["title"] as? String,
//              let direction = notification.userInfo?["direction"] as? MovementDirection,
//              let score = notification.userInfo?["score"] as? Int? else {
//            print("failed to converting userInfo back.")
//            return }
//        
//        let positionWithDirectionInfo = MovementDirectionScoreInfo(title: title, direction: direction, score: score)
//
//        guard let selectedTrialCore = selectedTrialCore else {
//            return
//        }
//        
//        print("trialCore passed to cameracontroller : \(selectedTrialCore.title) \(selectedTrialCore.direction)")
//        
//        DispatchQueue.main.async {
//            let cameraVC = CameraController(
////                positionDirectionScoreInfo: positionWithDirectionInfo,
//                connectionManager: self.connectionManager,
//                screen: screen,
//                trialCore: selectedTrialCore
//            )
//            
//            self.present(cameraVC, animated: true)
//        }
//    }
//    
//    // MARK: - UI SETUP
//    private func setupLayout() {
//        
//        let positionViews = [deepSquat, hurdleStep, inlineLunge, ankleClearing,
//                        shoulderMobility, shoulderClearing, straightLegRaise,
//                        stabilityPushup, extensionClearing, rotaryStability, flexionClearing]
//        
//        
//        positionViews.forEach { eachPosition in
//            self.view.addSubview(eachPosition)
//            eachPosition.isUserInteractionEnabled = true
//        }
//        
//        view.addSubview(topView)
//        topView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
////            make.top.equalToSuperview().offset(40)
////            make.top.equalToSuperview()
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.height.equalTo(40)
//        }
//        
//        
//        [sessionButton, connectionStateLabel, durationLabel].forEach { v in
//            topView.addSubview(v)
//        }
//        
//        sessionButton.snp.makeConstraints { make in
//            make.top.bottom.right.equalToSuperview()
//            make.width.equalTo(100)
//        }
//        
//        connectionStateLabel.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
//            make.leading.equalToSuperview().offset(10)
//            make.width.equalTo(150)
//        }
//        
//        durationLabel.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
//            make.leading.equalTo(connectionStateLabel.snp.trailing)
//            make.trailing.equalTo(sessionButton.snp.leading)
//        }
//        
//        deepSquat.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.top.equalTo(topView.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        hurdleStep.snp.makeConstraints { make in
//            make.leading.equalTo(deepSquat.snp.trailing)
//            make.top.equalTo(topView.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        inlineLunge.snp.makeConstraints { make in
//            make.leading.equalTo(hurdleStep.snp.trailing)
//            make.top.equalTo(topView.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        ankleClearing.snp.makeConstraints { make in
//            make.leading.equalTo(inlineLunge.snp.trailing)
//            make.top.equalTo(topView.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        
//        
//        shoulderMobility.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.top.equalTo(deepSquat.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(3)
//        }
//        
//        shoulderClearing.snp.makeConstraints { make in
//            make.leading.equalTo(shoulderMobility.snp.trailing)
//            make.top.equalTo(deepSquat.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(3)
//        }
//        
//        straightLegRaise.snp.makeConstraints { make in
//            make.leading.equalTo(shoulderClearing.snp.trailing)
//            make.top.equalTo(deepSquat.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(3)
//        }
//        
//        
//        
//        stabilityPushup.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.top.equalTo(shoulderMobility.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        extensionClearing.snp.makeConstraints { make in
//            make.leading.equalTo(stabilityPushup.snp.trailing)
//            make.top.equalTo(shoulderMobility.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        rotaryStability.snp.makeConstraints { make in
//            make.leading.equalTo(extensionClearing.snp.trailing)
//            make.top.equalTo(shoulderMobility.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        flexionClearing.snp.makeConstraints { make in
//            make.leading.equalTo(rotaryStability.snp.trailing)
//            make.top.equalTo(shoulderMobility.snp.bottom)
//            make.height.equalToSuperview().dividedBy(4)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//        
//        let subjectViews = [subjectSettingBtn, subjectNameLabel, subjectDetailLabel]
//        
//        
//    subjectViews.forEach { self.view.addSubview($0) }
////        view.addSubview(subjectSettingBtn)
//        subjectSettingBtn.snp.makeConstraints { make in
//            make.top.equalTo(rotaryStability.snp.bottom).offset(20)
//            make.trailing.equalToSuperview().offset(-30)
//            make.height.width.equalTo(60)
//        }
//        
////        view.addSubview(subjectNameLabel)
//        subjectNameLabel.snp.makeConstraints { make in
//            make.top.equalTo(subjectSettingBtn.snp.top)
//            make.trailing.equalTo(subjectSettingBtn.snp.leading).offset(-30)
//            make.width.equalTo(200)
//            make.height.equalTo(25)
//        }
//        
//        
////        view.addSubview(subjectDetailLabel)
//        subjectDetailLabel.snp.makeConstraints { make in
//            make.top.equalTo(subjectNameLabel.snp.bottom).offset(5)
//            make.trailing.equalTo(subjectSettingBtn.snp.leading).offset(-30)
//            make.width.equalTo(200)
//            make.height.equalTo(25)
//        }
//        
//        
//        // direction 이 1개 -> scoreView1 만 추가
//        // direction 이 2개 -> scoreView2 도 추가.
////        setupScoreBtnViews(using allViews: [PositionBlockView])
//        
//        view.addSubview(testBtn)
//        testBtn.snp.makeConstraints { make in
//            make.top.equalTo(rotaryStability.snp.bottom).offset(20)
//            make.leading.bottom.equalToSuperview()
//            make.trailing.equalTo(subjectNameLabel.snp.leading)
//        }
//        
//        setupScoreBtnViews(using: positionViews)
//
//    }
//    
//    private func setupScoreBtnViews(using allViews: [PositionBlockView]) {
//        for eachView in allViews {
//            let title = eachView.positionBlock.title
//            
//            guard let positionFromList = MovementList(rawValue: title),
//                  let numOfDirections = Dummy.numOfDirections[positionFromList] else { return }
//            
//            switch numOfDirections {
//            case 1:
//                scoreBtnViews.append(eachView.scoreView1)
//            case 2:
//                scoreBtnViews.append(eachView.scoreView1)
//                scoreBtnViews.append(eachView.scoreView2)
//            default:
//                break
//            }
//        }
//        
//        // Set scoreViews In Order.
//        // Variations not contained, total count is 18
//        
//        scoreBtnViews = scoreBtnViews.sorted {
//            if $0.tag != $1.tag {
//                return $0.tag < $1.tag
//            } else {
//                return $0.direction.count < $1.direction.count
//            }
//        }
//    }
//}
//
//// MARK: - ConnectionManager Delegate
//extension PositionController: ConnectionManagerDelegate {
//    
//    func updateState(state: ConnectionState) {
//        switch state {
//        case .connected:
//            triggerDurationTimer()
//        case .disconnected:
//            stopDurationTimer()
//        }
//        
//        DispatchQueue.main.async {
//            self.connectionStateLabel.text = state.rawValue
//        }
//    }
//    
//    func updateDuration(in seconds: Int) {
//        DispatchQueue.main.async {
//            self.durationLabel.text = "\(seconds) s"
//        }
//    }
//}
//
//// MARK: - CameraController Delegate
//extension PositionController: CameraControllerDelegate {
//    func makeSound() {
//        print("makeSound triggered !!!")
//    }
//    
//    func dismissCamera() {
//        guard let cameraVC = cameraVC else {
//            print("cameraVC is nil!", #file, #function, #line)
//            return }
//        
//        UIView.animate(withDuration: 0.3) {
//            cameraVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
//        } completion: { done in
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
//        }
//        updateScoreLabels()
//    }
//}
//
//
//extension PositionController: SubjectControllerDelegate {
//    func updateCurrentScreen(from subject: Subject, with screen: Screen, closure: () -> Void) {
//        updateTrialCores(subject: subject, screen: screen)
//        // when currentSubject set, it calls setupSubjectInfo()
//        updateScoreLabels()
//        closure()
//    }
//}
