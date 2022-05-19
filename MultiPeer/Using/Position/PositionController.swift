//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then
import CoreData

class PositionController: UIViewController {
    
    // MARK: - Properties
    
    var connectionManager = ConnectionManager()
    
    var screen: Screen?
    
    var cameraVC: CameraController?
    
    var count = 0
    var durationTimer: Timer?
    
    var subject: Subject? {
        didSet {
            setupSubjectInfo()
        }
    }
    
    var scoreBtnViews: [ScoreBtnView] = []
    
    var trialCores: [TrialCore] = []
    
    var selectedTrialCore: TrialCore?
    
   
    private let subjectNameLabel = UILabel().then { $0.textColor = .cyan
        $0.textAlignment = .right
    }
    
    private let subjectDetailLabel = UILabel().then { $0.textColor = .yellow
        $0.textAlignment = .right
    }
    
    private let deepSquat = PositionBlockView(PositionWithImageListEnum.deepsquat)
    
    private let hurdleStep = PositionBlockView(PositionWithImageListEnum.hurdleStep)
    private let inlineLunge = PositionBlockView(PositionWithImageListEnum.inlineLunge)
    private let ankleClearing = PositionBlockView(PositionWithImageListEnum.ankleClearing)
    
    private let shoulderMobility = PositionBlockView(PositionWithImageListEnum.shoulderMobility)
    private let shoulderClearing = PositionBlockView(PositionWithImageListEnum.shoulderClearing)
    private let straightLegRaise = PositionBlockView(PositionWithImageListEnum.straightLegRaise)
    
    private let stabilityPushup = PositionBlockView(PositionWithImageListEnum.stabilityPushup)
    private let extensionClearing = PositionBlockView(PositionWithImageListEnum.extensionClearing)
    
    private let rotaryStability = PositionBlockView(PositionWithImageListEnum.rotaryStability)
    private let flexionClearing = PositionBlockView(PositionWithImageListEnum.flexionClearing)
    
    
    
    private let topView = UIView().then { $0.backgroundColor = .systemPink}
    
    private let sessionButton = UIButton().then {
        $0.setTitle("Connect", for: .normal)
        $0.setTitleColor(.green, for: .normal)
    }
    
    private let connectionStateLabel = UILabel().then {
        $0.textColor = .black
        $0.text = "Not Connected"
    }
    
    private let durationLabel = UILabel().then { $0.textColor = .black
        $0.text = "duration"
    }
    
    private let subjectSettingBtn = UIButton().then {
        
        let someImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        someImage.tintColor = .white
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    

    // MARK: - Life Cycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTargets()
        connectionManager.delegate = self
        addNotificationObservers()
        
        updateScoreLabels()
        testCode()
    }
    
    private func testCode() { // replacement for Playground ..
        var ints = [1,5,6,3,4,4,0]

        ints = ints.sorted { $0 < $1 }
        print("ints: \(ints)")
    }
    
    private func updateSubjectWithScreen(subject: Subject, screen: Screen) {
        print("updateSubjectWithScreen")
        self.subject = subject
        self.screen = screen
        
        self.trialCores = screen.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
    }
    
    private func updateScoreLabels() {
        print("updateScoreLabels called")
        
        //TODO: Update Score ! for Each of PositionBlockView below
        
        for (index, eachTrial) in trialCores.enumerated() {
            if index == 5 { eachTrial.latestScore = 2 } // For test
            DispatchQueue.main.async {
                self.scoreBtnViews[index].scoreLabel.text = eachTrial.finalResult
            }
        }
    }
    
    private func setupSubjectInfo() {
        guard let currentSubject = subject else { return }
        subjectNameLabel.text = currentSubject.name
        subjectDetailLabel.text = String(currentSubject.isMale ? "남" : "여") + " / " + String(calculateAge(from: currentSubject.birthday))
    }
    
    
    // MARK: - Targets
    
    private func setupTargets() {
        
        subjectSettingBtn.addTarget(self, action: #selector(subjectBtnTapped), for: .touchUpInside)
        
        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
    }
    
    
    @objc func subjectBtnTapped(_ sender: UIButton) {
moveToSubjectController()

    }
    private func moveToSubjectController() {
        let subjectSettingVC = SubjectController()
        subjectSettingVC.basicDelegate = self

        self.navigationController?.pushViewController(subjectSettingVC, animated: true)
    }
    
    
    @objc func showConnectivityAction(_ sender: UIButton) {
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
    
    @objc func imgTapped(_ sender: ButtonWithInfo) {
        // TODO: move to cameraView With Info
        print("img Tapped,")
        let positionDirectionScoreInfo = sender.positionDirectionScoreInfo
        
        let title = positionDirectionScoreInfo.title
        let direction = positionDirectionScoreInfo.direction
        let score = positionDirectionScoreInfo.score
        
        selectedTrialCore = trialCores.filter { $0.title == title }.first
        
        guard let selectedTrialCore = selectedTrialCore else {
            self.moveToSubjectController()
            return
        }
        
        connectionManager.send(DetailPositionWIthMsgInfo(message: .presentCamera, detailInfo: PositionDirectionScoreInfo(title: title, direction: direction, score: score)))
        
        print("connectionManager has sent message")
        
        print("title: \(sender.positionDirectionScoreInfo.title)")
        
        print("direction: \(sender.positionDirectionScoreInfo.direction)")
        
        print("sender.score: \(sender.positionDirectionScoreInfo.score ?? 0)")
        
        presentCamera(positionDirectionScoreInfo: positionDirectionScoreInfo, with: selectedTrialCore)
    }
    
    
    // MARK: - Timer
    /// update Duration
    func triggerDurationTimer() {
        print("timer triggered!!")
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil ")
                return }
            
            print("hi!!!!!")
            self.count += 1
            DispatchQueue.main.async {
                self.durationLabel.text = "\(self.count) s"
            }
        }
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
    }
    
    @objc func countUp() {
        print("countUp triggered!!")
        count += 1
        
        DispatchQueue.main.async {
            self.durationLabel.text = String(self.count) + " s"
        }
    }
    
    
    
    
    private func presentCamera(
        positionDirectionScoreInfo: PositionDirectionScoreInfo,
        with selectedTrial: TrialCore) {
            
        guard let screen = screen else {
            self.moveToSubjectController()
            return
        }
        
        DispatchQueue.main.async {
            self.cameraVC = CameraController(
                positionDirectionScoreInfo: positionDirectionScoreInfo,
                connectionManager: self.connectionManager,
//                subject:subject,
                screen: screen,
                trialCore: selectedTrial
            )
            
            guard self.cameraVC != nil else { return }
            self.cameraVC!.delegate = self
            self.addChild(self.cameraVC!)
            self.view.addSubview(self.cameraVC!.view)
            self.cameraVC!.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            
            UIView.animate(withDuration: 0.3) {
                self.cameraVC!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            }
        }
    }
    
    
    // observer, add observer
    // MARK: - NOTIFICATIONS
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentCamera(_:)),
            name: .presentCameraKey, object: nil)
    }
    
    /// triggered by Notification
    @objc func presentCamera(_ notification: Notification) {
        print("presentCamera triggered by observing notification")
        
        guard let subject = subject,
              let screen = screen else {
            fatalError("fail to get subject and screen. Plz select target first")
        }
        
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else {
            print("failed to converting userInfo back.")
            return }
        
        let positionWithDirectionInfo = PositionDirectionScoreInfo(title: title, direction: direction, score: score)

        guard let selectedTrialCore = selectedTrialCore else {
            return
        }

        DispatchQueue.main.async {
            let cameraVC = CameraController(
                positionDirectionScoreInfo: positionWithDirectionInfo,
                connectionManager: self.connectionManager,
                screen: screen,
                trialCore: selectedTrialCore
            )
            
            self.present(cameraVC, animated: true)
        }
    }
    
    // MARK: - UI SETUP
    private func setupLayout() {
        
        let allViews = [deepSquat, hurdleStep, inlineLunge, ankleClearing,
                        shoulderMobility, shoulderClearing, straightLegRaise,
                        stabilityPushup, extensionClearing, rotaryStability, flexionClearing]
        
        
        allViews.forEach { eachPosition in
            self.view.addSubview(eachPosition)
            eachPosition.isUserInteractionEnabled = true // do we need it ?
        }
        
        
        allViews.forEach { each in
            each.isUserInteractionEnabled = true
        }
        
        
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.height.equalTo(40)
        }
        
        
        [sessionButton, connectionStateLabel, durationLabel].forEach { v in
            topView.addSubview(v)
        }
        
        sessionButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(100)
        }
        
        connectionStateLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(150)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(connectionStateLabel.snp.trailing)
            make.trailing.equalTo(sessionButton.snp.leading)
        }
        
        deepSquat.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        hurdleStep.snp.makeConstraints { make in
            make.leading.equalTo(deepSquat.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        inlineLunge.snp.makeConstraints { make in
            make.leading.equalTo(hurdleStep.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        ankleClearing.snp.makeConstraints { make in
            make.leading.equalTo(inlineLunge.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        
        
        shoulderMobility.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        shoulderClearing.snp.makeConstraints { make in
            make.leading.equalTo(shoulderMobility.snp.trailing)
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        straightLegRaise.snp.makeConstraints { make in
            make.leading.equalTo(shoulderClearing.snp.trailing)
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        
        
        stabilityPushup.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        extensionClearing.snp.makeConstraints { make in
            make.leading.equalTo(stabilityPushup.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        rotaryStability.snp.makeConstraints { make in
            make.leading.equalTo(extensionClearing.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        flexionClearing.snp.makeConstraints { make in
            make.leading.equalTo(rotaryStability.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        
        
        view.addSubview(subjectSettingBtn)
        subjectSettingBtn.snp.makeConstraints { make in
            make.top.equalTo(rotaryStability.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-30)
            make.height.width.equalTo(60)
        }
        
        view.addSubview(subjectNameLabel)
        subjectNameLabel.snp.makeConstraints { make in
            make.top.equalTo(subjectSettingBtn.snp.top)
            make.trailing.equalTo(subjectSettingBtn.snp.leading).offset(-30)
            make.width.equalTo(200)
            make.height.equalTo(25)
        }
        
        
        view.addSubview(subjectDetailLabel)
        subjectDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(subjectNameLabel.snp.bottom).offset(5)
            make.trailing.equalTo(subjectSettingBtn.snp.leading).offset(-30)
            make.width.equalTo(200)
            make.height.equalTo(25)
        }
        
        // direction 이 1개 -> scoreView1 만 추가
        // direction 이 2개 -> scoreView2 도 추가.
//        setupScoreBtnViews(using allViews: [PositionBlockView])
        
        setupScoreBtnViews(using: allViews)

    }
    
    private func setupScoreBtnViews(using allViews: [PositionBlockView]) {
        for eachView in allViews {
            let title = eachView.positionBlock.title
            
            guard let positionFromList = PositionList(rawValue: title),
                  let numOfDirections = Dummy.numOfDirections[positionFromList] else { return }
            
            switch numOfDirections {
            case 1:
                scoreBtnViews.append(eachView.scoreView1)
            case 2:
                scoreBtnViews.append(eachView.scoreView1)
                scoreBtnViews.append(eachView.scoreView2)
            default:
                break
            }
        }
        
        // Set scoreViews In Order.
        // Variations not contained, total count is 18
        
        scoreBtnViews = scoreBtnViews.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
    }
}

// MARK: - ConnectionManager Delegate
extension PositionController: ConnectionManagerDelegate {
    
    func updateState(state: ConnectionState) {
        switch state {
        case .connected:
            triggerDurationTimer()
        case .disconnected:
            stopDurationTimer()
        }
        
        DispatchQueue.main.async {
            self.connectionStateLabel.text = state.rawValue
        }
    }
    
    func updateDuration(in seconds: Int) {
        DispatchQueue.main.async {
            self.durationLabel.text = "\(seconds) s"
        }
    }
}

// MARK: - CameraController Delegate
extension PositionController: CameraControllerDelegate {
    func dismissCamera() {
        guard let cameraVC = cameraVC else {
            print("cameraVC is nil!", #file, #function, #line)
            return }
        
        UIView.animate(withDuration: 0.3) {
            cameraVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        } completion: { done in
            if done {
                if self.children.count > 0 {
                    let viewControllers: [UIViewController] = self.children
                    for vc in viewControllers {
                        vc.willMove(toParent: nil)
                        vc.view.removeFromSuperview()
                        vc.removeFromParent()
                    }
                }
            }
        }
    }
}


extension PositionController: SubjectControllerDelegate {
    func updateCurrentScreen(from subject: Subject, with screen: Screen, closure: () -> Void) {
        updateSubjectWithScreen(subject: subject, screen: screen)
        // when currentSubject set, it calls setupSubjectInfo()
        updateScoreLabels()
        closure()
    }
}
