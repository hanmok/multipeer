//
//  ScoringController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/02.
//

import UIKit
import SnapKit
import Then
import CoreData


protocol ScoreControllerDelegate: AnyObject {
    
    func deleteAction() // don't need to update trials
    
    //    func postAction(core: TrialCore, detail: TrialDetail)
    func postAction(ftpInfo: FTPInfo)
    func postAction(ftpInfoString: FtpInfoString)
    
    func updatePressedBtnTitle(with btnTitle: String)
    
    func navigateToSecondView(withNextTitle: Bool)
    
    //    func orderRequest(core: TrialCore, detail: TrialDetail)
    func orderRequest(ftpInfo: FTPInfo)
    func orderRequest(ftpInfoString: FtpInfoString)
    
}



class ScoreController: UIViewController {
    
    // MARK: - Properties
    var hasPainField: Bool = false
    var screen: Screen // 있는데.. ㅠㅠ
    var positionTitle: String
    var direction: MovementDirection
    
    var trialCore: TrialCore?
    var trialDetail: TrialDetail?
    
    /// follwing Clearing Test
    var fClearingCore: TrialCore?
    var fClearingDetail: TrialDetail?
    
    var parentController: CameraController?
    
    var score: Int64? { // why int instead of Int64 ?? 모든 계산은 64 로 하고, 나중에 Int 로 반환하자.
        willSet {
            // if it has variation following,
            // toggle visibility of Clearing Test depening on score value ( Hold -> Hide )
            // -1 represent 'Hold'
            
            if varTestName != nil {
                // convert to -1 -> hide!
                if newValue == -1 && score != -1 {
                    //            if score == newValue
                    toggleAppearance(shouldHide: true)
                    // from -1 > some other --> show!
                } else if score == -1 && newValue != -1 {
                    toggleAppearance(shouldHide: false)
                }
            }
        }
    }
    
    var pain: Bool?
    var scoreType: ScoreType
    
    var painTestName: String? {
        didSet {
            print("painTestName has been setup, currentTitle: \(positionTitle), direction: \(direction.rawValue)")
        }
    }
    var varTestName: String?
    
    weak var delegate: ScoreControllerDelegate?
    
    private var selectedBtnTitle = ""
    
    
    // MARK: - UI Properties
    
    private let scoreBtn1 = ScoreButton().then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    private let scoreBtn2 = ScoreButton().then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    private let scoreBtn3 = ScoreButton().then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    private let scoreBtn4 = ScoreButton().then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    //    public var scoreBtnStackView = SelectableButtonStackView().then {
    //        $0.spacing = 16
    //    }
    public var scoreBtnStackView = SelectableButtonStackView()
    
    private let painPlusBtn = ScoreButton("+").then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    private let painMinusBtn = ScoreButton("-").then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    public var painBtnStackView = SelectableButtonStackView()
    
    private let scoreLabel = UILabel().then {
        $0.text = "Score"
        $0.textColor = .lavenderGray700
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    private let painPositionLabel = UILabel().then {
        $0.text = "Pain"
        $0.textColor = .lavenderGray700
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    private let deleteBtn = UIButton().then {
        $0.setTitle("Delete", for: .normal)
        $0.setTitleColor(.red500, for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.red500.cgColor
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        //        $0.backgroundColor = .red500
        $0.backgroundColor = UIColor(redInt: 196, greenInt: 196, blueInt: 196)
        $0.layer.cornerRadius = 8
        // additional code
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Life Cyle
    
    init(positionTitle: String, direction: String, screen: Screen) {
        self.positionTitle = positionTitle
        
        guard let direction = MovementDirection(rawValue: direction) else {fatalError()}
        
        self.direction = direction
        self.scoreType = movementNameToScoreType[positionTitle] ?? .zeroToThree
        
        self.painTestName = Dummy.getPainTestName(from: positionTitle, direction: direction)
        
        self.varTestName = (movementWithVariation[positionTitle])
        self.screen = screen
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupAddtargets()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
    }
    
    // MARK: - Helper Functions
    
    public func setupTrialCore(with trialCore: TrialCore) {
        
        self.trialCore = trialCore
        
        if painTestName != nil {
            
            if setupFTrialCoreIfNeeded() {
                self.painBtnStackView.buttons.forEach { $0.backgroundColor = .lavenderGray300
                    $0.setTitleColor(.gray900, for: .normal)
                    $0.isUserInteractionEnabled = true
                }
            } else {
                self.painBtnStackView.buttons.forEach {
                    $0.backgroundColor = .lavenderGray100
                    $0.setTitleColor(.gray400, for: .normal)
                    $0.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    
    
    /// called from CameraController
    public func setupAgain(positionTitle: String, direction: MovementDirection) {
        print("received positionTitle from scoreController: \(positionTitle)")
        print("setupagain triggered")
        
        self.positionTitle = positionTitle
        self.direction = direction
        print("scoreVC, setupAgain, positionTitle: \(positionTitle)")
        self.scoreType = movementNameToScoreType[positionTitle]!
        
        
        self.painTestName = (movementWithPainTestTitle[positionTitle])
        
        if positionTitle == MovementList.rotaryStability.rawValue && direction.rawValue == MovementDirectionList.left.rawValue {
            print("title, direction: \(positionTitle), \(direction), rsbug, count: 12")
            self.painTestName = nil
        }
        
        self.varTestName = movementWithVariation[positionTitle]
        
        viewDidLoad()
        toggleAppearance(shouldHide: false)
        
        setupInitialValues()
    }
    
    /// set both score and pain nil
    private func setupInitialValues() {
        score = nil
        pain = nil
    }
    
    // MARK: - Btn Actions
    private func setupAddtargets() {
        for btn in scoreBtnStackView.buttons {
            btn.addTarget(self, action: #selector(scoreBtnTapped(_:)), for: .touchUpInside)
        }
        for btn in painBtnStackView.buttons {
            btn.addTarget(self, action: #selector(painBtnTapped(_:)), for: .touchUpInside)
        }
        
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    
    @objc func scoreBtnTapped(_ sender: SelectableButton) {
        scoreBtnStackView.selectBtnAction(selected: sender.id)
        selectedBtnTitle = scoreBtnStackView.selectedBtnTitle
        delegate?.updatePressedBtnTitle(with: selectedBtnTitle)
        print("selected BtnTitle from scoreController: \(selectedBtnTitle)")
        
        if let selectedScore = Int(scoreBtnStackView.selectedBtnTitle) {
            score = Int64(selectedScore)
        } else {
            switch scoreBtnStackView.selectedBtnTitle {
                
            case .ScoreStr.hold: score = .Value.hold
                
            case .ScoreStr.red: score = .Value.red
            case .ScoreStr.yellow: score = .Value.yellow
            case .ScoreStr.green: score = .Value.green
                
            default: score = nil
                
            }
        }
        
        
        if painTestName == nil {
            
            //            painBtnStackView.backgroundColor = .lavenderGray100
            saveBtn.backgroundColor = .red500
            saveBtn.isUserInteractionEnabled = true
        } else {
            //            painBtnStackView.selectedBtnIndex
            if painBtnStackView.selectedBtnIndex != nil {
                saveBtn.backgroundColor = .red500
                saveBtn.isUserInteractionEnabled = true
            } else {
                if score == .Value.hold {
                    saveBtn.backgroundColor = .red500
                    saveBtn.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    @objc func painBtnTapped(_ sender: SelectableButton) {
        painBtnStackView.selectBtnAction(selected: sender.id)
        switch painBtnStackView.selectedBtnTitle {
        case "+":
            pain = true
        case "-":
            pain = false
        default:
            print("pain is nil")
            pain = nil
        }
        
        if scoreBtnStackView.selectedBtnIndex != nil {
            saveBtn.backgroundColor = .red500
            saveBtn.isUserInteractionEnabled = true
        }
    }
    
    
    @objc func deleteTapped() {
        print("delete tapped!")
        saveBtn.backgroundColor = UIColor(redInt: 196, greenInt: 196, blueInt: 196)
        setSelectedScoreButtonNone()
        delegate?.deleteAction()
        
    }
    
    //    private func makeFTPInfo(trialCore:TrialCore, trialDetail: TrialDetail, additionalInfo: String = "") -> FTPInfo {
    //
    //        guard let subject = screen.parentSubject else { fatalError() }
    //
    //        let genderInt = subject.isMale ? 1 : 2
    //        let calendar = Calendar.current
    //        let components = calendar.dateComponents([.year], from: subject.birthday)
    //        guard let birthYear = components.year else { fatalError() }
    //
    //
    //        let ftpInfo = FTPInfo(date: Date(), inspectorName: "someone", subjectName: subject.name, screenIndex: Int(screen.screenIndex), title: trialCore.title, direction: trialCore.direction, trialNo: Int(trialDetail.trialNo), phoneNumber: subject.phoneNumber, gender: genderInt, birth: birthYear, kneeLength: subject.kneeLength, palmLength: subject.palmLength)
    //
    //        // cameraAngle 은 우선 기본 값 1,
    //        // CameraController 가서 값 새로 설정 후 넣어주기.
    //
    //        return ftpInfo
    //    }
    
    private func makeFTPInfoString(trialCore:TrialCore, trialDetail: TrialDetail, additionalInfo: String = "") -> FtpInfoString {
        
        guard let subject = screen.parentSubject else { fatalError() } // parentSubject 가 없나?
        
        let date = Date()
        //        let inspectorName = "someName"
        let formattedDateStr = date.getFormattedDate()
        let inspectorName = screen.parentSubject!.inspector!.name
        
        let subjectName = subject.name
        
        let screenIndex = screen.screenIndex
        
        let titleShort = Dummy.shortForFileName[trialCore.title]!
        
        let directionShort: String
        switch trialCore.direction {
        case "Left": directionShort = "l"
        case "Right": directionShort = "r"
        default: directionShort = ""
        }
        
        let trialNo = trialDetail.trialNo
        let phoneNumber = subject.phoneNumber
        let genderInt = subject.isMale ? 1 : 2
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: subject.birthday)
        
        guard let birthYear = components.year else { fatalError() }
        
        let kneeLength = subject.kneeLength
        let palmLength = subject.palmLength
        
        let fileName = "\(formattedDateStr)_\(inspectorName)_\(subjectName)_\(screenIndex)_\(titleShort)\(directionShort)\(trialNo)_\(phoneNumber)_\(genderInt)_\(birthYear)_\(kneeLength)_\(palmLength)"
        
        let ftpInfoString = FtpInfoString(fileName: fileName)
        return ftpInfoString
    }
    //    YYYY.MM.DD_HH.MM.SS_검사자명_피험자명_1_ds1_01012341234_성별_탄생년도_무릎길이_손바닥길이_앵글
    @objc func saveTapped() {
        // if tapped Button is "Hold" then send it back to CameraController
        printFlag(type: .rsBug, count: 0)
        
        if saveConditionSatisfied() {
            
            printFlag(type: .rsBug, count: 1)
            guard let score = score else { fatalError("score is nil") }
            
            setupFTrialCoreIfNeeded()
            
            setupTrialDetail()
            
            guard let trialCore = trialCore else { fatalError("trialCore is nil") }
            guard let trialDetail = trialDetail else { fatalError("trialDetail is nil") }
            
            
            setScore(title: trialCore.title, to: trialDetail, score: score, pain: pain)
            
            
            print("------------ scoreController saveAction ------------")
            print("title: \(trialCore.title), direction: \(trialCore.direction), trialNo: \(trialDetail.trialNo)")
            
            let ftpInfoStr = makeFTPInfoString(trialCore: trialCore, trialDetail: trialDetail)
            
            
            delegate?.postAction(ftpInfoString: ftpInfoStr)
            delegate?.orderRequest(ftpInfoString: ftpInfoStr)
            
            trialCore.updateLatestScore()
            
            // 어떤게 invalid 일까 ?? 둘다일 수 있다.
            if fClearingCore != nil && fClearingDetail != nil {
                
                setScore(title: fClearingCore!.title , to: fClearingDetail!, score: .DefaultValue.trialScore, pain: pain)
                
                // TODO: 경우에 맞게 Clearing Test Direction 설정
                // 버튼 선택에 따라 Clearing 값이 업데이트 되지 않음.
                
                // scoreController Delegate
                //                let postReqInfo2 = makeFTPInfo(trialCore: fClearingCore!, trialDetail: fClearingDetail!)
                
                //                delegate?.postAction(postReqInfo: postReqInfo2)
                
                fClearingCore!.updateLatestScore()
            } else { print("fClearingCore or fClearingDetail is invalid ")
            }
            
        } else { print("save Condition not satisfied.") }
        
        if score == .Value.hold {
            delegate?.navigateToSecondView(withNextTitle: true)
        } else {
            delegate?.navigateToSecondView(withNextTitle: false)
        }
        
        //        connectionmanager
        //        ConnectionManager.send()
        
        //        delegate?.navigateToSecondView()
    }
    
    
    
    private func setSelectedScoreButtonNone() {
        scoreBtnStackView.selectBtnAction(selected: nil)
        painBtnStackView.selectBtnAction(selected: nil)
    }
    
    
    private func setScore(title: String, to trialDetail: TrialDetail, score: Int64 = .DefaultValue.trialScore, pain: Bool? = nil) {
        print("ffff setScore triggered, pain: \(pain)")
        var converted = Int64.DefaultValue.trialPain
        
        if movementWithPain.contains(title) && pain != nil {
            converted = pain! ? .Value.painFul : .Value.notPainful
        }
        
        // TODO: AnkleClearing 의 경우에 대해 PAIN 값 정해주기 .
        
        trialDetail.setValue(score, forKey: .TrialDetailStr.score)
        trialDetail.setValue(converted, forKey: .TrialDetailStr.isPainful)
        trialDetail.setValue(Date(), forKey: .TrialDetailStr.date)
        
        trialDetail.parentTrialCore.setValue(Date(), forKey: .TrialCoreStr.date)
        
        print("ffff title: \(title), score: \(score), pain: \(converted)")
        trialDetail.saveChanges()
    }
    
    
    @discardableResult
    private func setupFTrialCoreIfNeeded() -> Bool {
        
        guard let trialCore = trialCore else { fatalError("trialCore is nil") }
        
        guard let screen = trialCore.parentScreen else { fatalError() }
        
        let currentDirection = trialCore.direction
        
        if movementWithPainTestTitle[trialCore.title] != nil {
            let followingTestTitle = movementWithPainTestTitle[trialCore.title]!
            guard let currentMovementName = MovementList(rawValue: trialCore.title) else { fatalError() }
            
            
            if currentMovementName == .shoulderMobility {
                fClearingCore = screen.trialCores.filter { $0.title == followingTestTitle && $0.direction == currentDirection}.first!
                return true
            } else if currentMovementName == .trunkStabilityPushUp || currentMovementName == .trunkStabilityPushUpVar {
                fClearingCore = screen.trialCores.filter { $0.title == followingTestTitle }.first!
                return true
            } else if currentMovementName == .rotaryStability {
                if currentDirection == "Right" {
                    fClearingCore = screen.trialCores.filter { $0.title == followingTestTitle }.first!
                    return true
                }
            } else if currentMovementName == .ankleClearing {
                return true
            }
        }
        
        return false
        
        
        
        print("fClearingCore.title name0 :\(fClearingCore?.title)")
    }
    
    // clearing Test 가 있는 것들은 어떻게 진행됨 ?
    // 여기서 정해줘야함 !
    
    public func changeSaveBtnColor() {
        saveBtn.backgroundColor = UIColor(redInt: 196, greenInt: 196, blueInt: 196)
        saveBtn.isUserInteractionEnabled = false
    }
    
    // what is required conditions ?
    func saveConditionSatisfied() -> Bool {
        printFlag(type: .rsBug, count: 2)
        guard let score = score else {
            return false }
        printFlag(type: .rsBug, count: 3)
        printFlag(type: .rsBug, count: 8, message: "painTestName: \(painTestName)")
        if painTestName != nil { // if painTest exist,
            if score == .Value.hold {
                printFlag(type: .rsBug, count: 4)
                return true
            } else {
                printFlag(type: .rsBug, count: 5)
                return pain != nil
            }
        } else {
            printFlag(type: .rsBug, count: 7)
            return true // if score is selected -> true. or -> false
        }
    }
    // 왜 두번 생성하고 ㅈㄹ..
    func setupTrialDetail() {
        
        guard let trialCore = trialCore else { fatalError("trialCore is nil") }
        
        trialDetail = trialCore.returnFreshTrialDetail()
        
        guard let fClearingCore = fClearingCore else { return }
        fClearingDetail = fClearingCore.returnFreshTrialDetail()
        
        
        print("setupTrialDetail called")
    }
    
    
    private func toggleAppearance(shouldHide: Bool) {
        
        if shouldHide {
            
            self.painBtnStackView.buttons.forEach { $0.backgroundColor = .lavenderGray100
                $0.setTitleColor(.gray400, for: .normal)
                $0.isUserInteractionEnabled = false
            }
        } else {
            self.painBtnStackView.buttons.forEach {
                $0.isUserInteractionEnabled = true
                $0.backgroundColor = .lavenderGray300
                $0.setTitleColor(.gray900, for: .normal)
            }
        }
    }
    
    
    @discardableResult
    private func createTrialDetail(with trialNo: Int64) -> TrialDetail {
        guard let trialCore = trialCore else { fatalError("trialCore is nil") } // could be changed
        let createdCoreDetail = TrialDetail.save(belongTo: trialCore)
        createdCoreDetail.setValue(trialNo, forKey: .TrialDetailStr.trialNo)
        return createdCoreDetail
    }
    
    
    private func setupLayout() {
        if view.subviews.count != 0 {
            view.subviews.forEach {
                $0.removeFromSuperview()
            }
        }
        
        
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(10)
            make.height.equalTo(25)
            make.top.equalToSuperview().offset(24)
        }
        
        
        [scoreBtn1, scoreBtn2, scoreBtn3].forEach {
            scoreBtnStackView.addArrangedButton($0)
        }
        
        print("scoreType: \(scoreType)")
        // Three Elements
        if scoreType == .zeroThreeHold || scoreType == .zeroToTwo || scoreType == .RYG{
            
            if scoreType == .zeroThreeHold {
                scoreBtn1.wrappedString = "0"
                scoreBtn2.wrappedString = "3"
                scoreBtn3.wrappedString = "Hold"
            } else if scoreType == .zeroToTwo {
                scoreBtn1.wrappedString = "0"
                scoreBtn2.wrappedString = "1"
                scoreBtn3.wrappedString = "2"
            } else if scoreType == .RYG {
                scoreBtn1.wrappedString = "Red"
                scoreBtn2.wrappedString = "Yellow"
                scoreBtn3.wrappedString = "Green"
            }
            
            // Four Elements
        } else if scoreType == .zeroToThree {
            scoreBtnStackView.addArrangedButton(scoreBtn4)
            
            scoreBtn1.wrappedString = "0"
            scoreBtn2.wrappedString = "1"
            scoreBtn3.wrappedString = "2"
            scoreBtn4.wrappedString = "3"
        }
        
        
        view.addSubview(scoreBtnStackView)
        scoreBtnStackView.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(35)
            make.height.equalTo(48)
        }
        
        painPlusBtn.wrappedString = "+"
        painMinusBtn.wrappedString = "-"
        
        
        if painTestName != nil {
            view.addSubview(painPositionLabel)
            painPositionLabel.snp.makeConstraints { make in
                make.top.equalTo(scoreBtnStackView.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(25) // same as that of scoreLabel
            }
            
            
            [painPlusBtn, painMinusBtn].forEach {
                painBtnStackView.addArrangedButton($0)
            }
            
            view.addSubview(painBtnStackView)
            painBtnStackView.snp.makeConstraints { make in
                make.top.equalTo(painPositionLabel.snp.bottom).offset(8)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().dividedBy(2.5)
                make.height.equalTo(48)
            }
        }
        
        view.addSubview(deleteBtn)
        view.addSubview(saveBtn)
        
        deleteBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            
            if painTestName != nil {
                make.top.equalTo(painBtnStackView.snp.bottom).offset(32)
            } else {
                make.top.equalTo(scoreBtnStackView.snp.bottom).offset(30)
            }
            
            make.height.equalTo(48)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        saveBtn.snp.makeConstraints { make in
            make.leading.equalTo(deleteBtn.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            
            if painTestName != nil {
                make.top.equalTo(painBtnStackView.snp.bottom).offset(32)
            } else {
                make.top.equalTo(scoreBtnStackView.snp.bottom).offset(32)
            }
            make.height.equalTo(48)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


