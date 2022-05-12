//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then

class PositionController: UIViewController {
    
    // MARK: - Properties
    
    var connectionManager = ConnectionManager()

    var count = 0
    var timer: Timer?
    
    var currentSubject: Subject? {
        didSet {
            setupSubjectInfo()
        }
    }
    
    var currentScreenId: UUID?
    
    private func updateSubjectWithScreen(subject: Subject, screenId: UUID) {
        currentSubject = subject
        currentScreenId = screenId
//        renderCurrentState()
    }
    
    private func updateScoreLabels() {

        //TODO: Update Score ! for Each of PositionBlockView below
//        ex) deepSquat.scoreView1.scoreLabel =
    }
    
    private func setupSubjectInfo() {
        guard let currentSubject = currentSubject else { return }
        subjectNameLabel.text = currentSubject.name
        subjectDetailLabel.text = String(currentSubject.isMale ? "남" : "여") + " / " + String(calculateAge(from: currentSubject.birthday))
    }
    
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
//        $0.textColor = .blue
        $0.textColor = .black
        $0.text = "Not Connected"
    }
    
    private let durationLabel = UILabel().then { $0.textColor = .black
        $0.text = "duration"
    }
    
    private let subjectSettingBtn = UIButton().then {
//        let someImage = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
//        let someImage = UIImageView(image: UIImage(systemName: "person.fill"))
        let someImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        someImage.tintColor = .white
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        $0.addTarget(self, action: #selector(subjectBtnTapped), for: .touchUpInside)
    }
    
    @objc func subjectBtnTapped(_ sender: UIButton) {
        print("btn tapped!")
//        let subjectSettingVC = cameraVC
        let subjectSettingVC = SubjectController()
        subjectSettingVC.basicDelegate = self
//        UINavigationController.pushViewController(subjectSettingVC!)
        self.navigationController?.pushViewController(subjectSettingVC, animated: true)
        
    }
    
    var cameraVC: CameraController?
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTargets()
        connectionManager.delegate = self
        addNotificationObservers()
//        testCode()
        
        print("PositionCOntorller has appeared!")
        print("-------------------------------\n\n\n")
        print("-------------------------------")
    }
    
    @objc func testBtnTapped(_ sender: UIButton) {
        testCode()
    }
    
    func testCode() {
        let date = Date().addingTimeInterval(5)
        print("hi!")
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
        // 잘 작동 하는구만!!!
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func runCode() {
        print("hello!")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear PositionController")
//        triggerTimer()
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear PositionController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisAppear PositionConroller")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     // MARK: - Targets
    
    private func setupTargets() {
        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
//        timerTestBtn.addTarget(self, action: #selector(testBtnTapped(_:)), for: .touchUpInside)
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
    
    
    func triggerTimer() {
        print("timer triggered!!")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
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
    
    
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func countUp() {
        print("countUp triggered!!")
        count += 1
        
        DispatchQueue.main.async {
            self.durationLabel.text = String(self.count) + " s"
        }
    }
    
    @objc func btnTapped( _ sender: UIButton) {
        switch sender.tag {
        case 0: print("from left")
        case 1: print("from right")
        case 2: print("from center")
        default: print("other")
        }
    }
    
    
    
    @objc func imgTapped(_ sender: ButtonWithInfo) {
        // TODO: move to cameraView With Info
        print("img Tapped,")
        let positionDirectionScoreInfo = sender.positionDirectionScoreInfo
        
        let title = positionDirectionScoreInfo.title
        let direction = positionDirectionScoreInfo.direction
        let score = positionDirectionScoreInfo.score
        
        connectionManager.send(DetailPositionWIthMsgInfo(message: .presentCamera, detailInfo: PositionDirectionScoreInfo(title: title, direction: direction, score: score)))
        print("connectionManager has sent message")
//        print("title: \(sender.title)")
        print("title: \(sender.positionDirectionScoreInfo.title)")
//        print("direction: \(sender.direction)")
        print("direction: \(sender.positionDirectionScoreInfo.direction)")
//        print("sender.score: \(sender.score ?? 0)")
        print("sender.score: \(sender.positionDirectionScoreInfo.score ?? 0)")
        
        
//        DispatchQueue.main.async {
//            let cameraVC = CameraController(positionWithDirectionInfo: positionWithDirectionInfo, connectionManager: self.connectionManager)
////            self.present(cameraVC, animated: true)
//            UINavigationController.pushViewController(cameraVC)
//            self.navigationController?.pushViewController(cameraVC, animated: true)
//        }
        
        presentCamera(positionDirectionScoreInfo: positionDirectionScoreInfo)
    }
    
    // 너무.. 갑자기 출현시키는데.. ?? Animation 을 좀 줘봐..
    private func presentCamera(positionDirectionScoreInfo: PositionDirectionScoreInfo) {
        DispatchQueue.main.async {
            self.cameraVC = CameraController(positionDirectionScoreInfo: positionDirectionScoreInfo, connectionManager: self.connectionManager)
            guard self.cameraVC != nil else { return }
            self.cameraVC!.delegate = self
//            self.navigationController?.pushViewController(cameraVC, animated: true)
            self.addChild(self.cameraVC!)
            self.view.addSubview(self.cameraVC!.view)
            self.cameraVC!.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            
            UIView.animate(withDuration: 0.3) {
                self.cameraVC!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            }
        }
    }
    
    @objc func scoreTapped(_ sender: ButtonWithInfo) {
        // TODO: if none recorded, move to cameraView With Info
        // TODO: if Not, popup score Action to modify
        
        print("score Tapped,")
//        print("title: \(sender.title)")
        print("title: \(sender.positionDirectionScoreInfo.title)")
//        print("direction: \(sender.direction)")
        print("direction: \(sender.positionDirectionScoreInfo.direction)")
    
//        print("sender.score: \(sender.score ?? 0)")
        print("sender.score: \(sender.positionDirectionScoreInfo.score ?? 0)")
    }
    // observer, add observer
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(presentCamera(_:)),
                                               name: .presentCameraKey, object: nil)
    }
    
    @objc func presentCamera(_ notification: Notification) {
        print("presentCamera triggered by observing notification")
        
        
        
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else {
            print("failed to converting userInfo back.")
            return }
        
        let positionWithDirectionInfo = PositionDirectionScoreInfo(title: title, direction: direction, score: score)


        DispatchQueue.main.async {
            let cameraVC = CameraController(positionDirectionScoreInfo: positionWithDirectionInfo, connectionManager: self.connectionManager)
            
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
//            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
//            make.left.top.right.equalToSuperview().offset(40)
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
    }
    
    private func configureUserWithScreen(subject: Subject, screenId: UUID) {
        
    }
}


extension PositionController: ConnectionManagerDelegate {
    
//    func presentVideo() {
        
//    }
    
    func updateState(state: ConnectionState) {
        switch state {
        case .connected:
        triggerTimer()
        case .disconnected:
            stopTimer()
//        case .connecting: break
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
    func updateCurrentScreen(from subject: Subject, with screenId: UUID, closure: () -> Void) {
        updateSubjectWithScreen(subject: subject, screenId: screenId)
        // when currentSubject set, it calls setupSubjectInfo()
        updateScoreLabels()
        closure()
    }
}

extension PositionController {
    
    private func calculateAge(from birthday: Date) -> Int {
        
        let calendar = Calendar.current
        let birthComponent = calendar.dateComponents([.year], from: birthday)
        let currentComponent = calendar.dateComponents([.year], from: Date())
        
        guard let birthYear = birthComponent.year,
              let currentYear = currentComponent.year else { return 0 }
        
        let age = currentYear - birthYear + 1
        
        return age
    }
}

public func calculateAge(from birthday: Date) -> Int {
    
    let calendar = Calendar.current
    let birthComponent = calendar.dateComponents([.year], from: birthday)
    let currentComponent = calendar.dateComponents([.year], from: Date())
    
    guard let birthYear = birthComponent.year,
          let currentYear = currentComponent.year else { return 0 }
    
    let age = currentYear - birthYear + 1
    
    return age
}
