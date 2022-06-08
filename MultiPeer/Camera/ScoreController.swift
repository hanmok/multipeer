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

    func saveAction(core: TrialCore, detail: TrialDetail)
    
    func updateMovement(with movementDirectionScoreInfo: MovementDirectionScoreInfo)
    
    func updatePressedBtnTitle(with btnTitle: String)
    
    func navigateToSecondView()
    
    func orderRequest(core: TrialCore, detail: TrialDetail)
}



class ScoreController: UIViewController {

    // MARK: - Properties
    var hasPainField: Bool = false
    
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
    
    var painTestName: String?
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
    
    public var scoreBtnGroup = SelectableButtonStackView().then {
        $0.spacing = 16
    }
    
    private let painPlusBtn = ScoreButton("+").then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    private let painMinusBtn = ScoreButton("-").then {
        $0.backgroundColor = UIColor.lavenderGray300
        $0.setTitleColor(.gray900, for: .normal)
    }
    
    public var painBtnGroup = SelectableButtonStackView(defaultColor: .lavenderGray300).then {
        $0.spacing = 16
    }
    
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
        $0.addBorders(to: [.top, .bottom], in: .lavenderGray100, width: 1)
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white, for: .normal)


        $0.backgroundColor = .red500
        $0.addBorders(to: [.top, .bottom], in: .lavenderGray100, width: 1)
    }
    
     // MARK: - Life Cyle
    
    init(positionTitle: String, direction: String) {
        self.positionTitle = positionTitle
        guard let direction = MovementDirection(rawValue: direction) else {fatalError()}
        self.direction = direction
        self.scoreType = movementToScoreType[positionTitle] ?? .zeroToThree
        
        self.painTestName = (movementWithPainTestTitle[positionTitle])
        self.varTestName = (movementWithVariation[positionTitle])
//        self.parentController = parentVC
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupAddtargets()
    }
    
        // MARK: - Helper Functions
    
    public func setupTrialCore(with trialCore: TrialCore) {
        
        self.trialCore = trialCore
        if setupFTrialCoreIfNeeded() {
            UIView.animate(withDuration: 0.3) {
                self.painBtnGroup.isHidden = false
                self.painPositionLabel.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.painBtnGroup.isHidden = true
                self.painPositionLabel.isHidden = true
            }
        }
    }
    
    
    
    /// called from CameraController
    public func setupAgain(with movementDirectionScoreInfo: MovementDirectionScoreInfo) {
                
        self.positionTitle = movementDirectionScoreInfo.title
        self.direction = movementDirectionScoreInfo.direction
        self.scoreType = movementToScoreType[movementDirectionScoreInfo.title] ?? .zeroToThree
        
        
        self.painTestName = (movementWithPainTestTitle[movementDirectionScoreInfo.title])
        self.varTestName = (movementWithVariation[movementDirectionScoreInfo.title])
        
        print("painTestName: \(painTestName)")
//        print("varTestName: \(varTestName)")
        
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
        for btn in scoreBtnGroup.buttons {
            btn.addTarget(self, action: #selector(scoreBtnTapped(_:)), for: .touchUpInside)
        }
        for btn in painBtnGroup.buttons {
            btn.addTarget(self, action: #selector(painBtnTapped(_:)), for: .touchUpInside)
        }
        
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    

    @objc func scoreBtnTapped(_ sender: SelectableButton) {
        scoreBtnGroup.setSelectedButton(sender.id)
        selectedBtnTitle = scoreBtnGroup.selectedBtnTitle
        delegate?.updatePressedBtnTitle(with: selectedBtnTitle)
        print("selected BtnTitle from scoreController: \(selectedBtnTitle)")
        
        if let selectedScore = Int(scoreBtnGroup.selectedBtnTitle) {
            score = Int64(selectedScore)
        } else {
            switch scoreBtnGroup.selectedBtnTitle {
            
            case .ScoreStr.hold: score = .Value.hold

            case .ScoreStr.red: score = .Value.red
            case .ScoreStr.yellow: score = .Value.yellow
            case .ScoreStr.green: score = .Value.green

            default: score = nil
                
            }
        }
    }
    
    @objc func painBtnTapped(_ sender: SelectableButton) {
        painBtnGroup.setSelectedButton(sender.id)
        switch painBtnGroup.selectedBtnTitle {
        case "+":
            pain = true
        case "-":
            pain = false
        default:
            print("pain is nil")
            pain = nil
        }
    }

    
    @objc func deleteTapped() {
        print("delete tapped!")
        
        setSelectedScoreButtonNone()
        delegate?.deleteAction()
    }
    
    @objc func saveTapped() {
        // if tapped Button is "Hold" then send it back to CameraController
        
        if saveConditionSatisfied() {
            
            guard let score = score else { fatalError("score is nil") }
            print("save Condition satisfied.")
            
            setupFTrialCoreIfNeeded()
            
            // setup Detail both trial and fclearing
            // Ankle 에서 Nil 나옴..
            setupTrialDetail()
            
            guard let trialCore = trialCore else { fatalError("trialCore is nil") }
            guard let trialDetail = trialDetail else { fatalError("trialDetail is nil") }
            
            
            setScore(title: trialCore.title, to: trialDetail, score: score, pain: pain)
            
            delegate?.saveAction(core: trialCore, detail: trialDetail)
            delegate?.orderRequest(core: trialCore, detail: trialDetail)
            trialCore.updateLatestScore()

            // 어떤게 invalid 일까 ?? 둘다일 수 있다.
            if fClearingCore != nil && fClearingDetail != nil {
                
                setScore(title: fClearingCore!.title , to: fClearingDetail!, score: .DefaultValue.trialScore, pain: pain)
                
                // TODO: 경우에 맞게 Clearing Test Direction 설정
                // 버튼 선택에 따라 Clearing 값이 업데이트 되지 않음.
                
                // scoreController Delegate
                print("fClearingDetail Pain: \(fClearingDetail?.isPainful)")
                delegate?.saveAction(core: fClearingCore!, detail: fClearingDetail!)
                delegate?.orderRequest(core: fClearingCore!, detail: fClearingDetail!)
                

                fClearingCore!.updateLatestScore()
            } else {
                print("fClearingCore or fClearingDetail is invalid ")
            }
            
        } else { print("save Condition not satisfied.") }
        
        delegate?.navigateToSecondView()
    }
    
    
    
    private func setSelectedScoreButtonNone() {
        scoreBtnGroup.setSelectedButton(nil)
        painBtnGroup.setSelectedButton(nil)
    }
    
    
    private func setScore(title: String, to trialDetail: TrialDetail, score: Int64 = .DefaultValue.trialScore, pain: Bool? = nil) {
        print("ffff setScore triggered, pain: \(pain)")
        var converted = Int64.DefaultValue.trialPain
        

        if movementWithPain.contains(title) && pain != nil {
            print("ffff if if setscore called, title: \(title), pain : \(pain)")
            converted = pain! ? .Value.painFul : .Value.notPainful
        } else {
            print("ffff else in setscore called, title: \(title), pain: \(pain) ")
        }
        //TODO: AnkleClearing 의 경우에 대해 PAIN 값 정해주기 .
        
        trialDetail.setValue(score, forKey: .TrialDetailStr.score)
        trialDetail.setValue(converted, forKey: .TrialDetailStr.isPainful)
        print("ffff score: \(score), pain: \(converted)")
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
    
    
    
    
    // what is required conditions ?
    func saveConditionSatisfied() -> Bool {
        guard let score = score else {
            return false }
        
        if painTestName != nil { // if painTest exist,
            if score == .Value.hold {
                return true
            } else {
                return pain != nil
            }
        } else {
            return true // if score is selected -> true. or -> false
        }
    }
    
    func setupTrialDetail() {
        
        guard let trialCore = trialCore else { fatalError("trialCore is nil") }
        trialDetail = trialCore.returnFreshTrialDetail()
        
        guard let fClearingCore = fClearingCore else { return }
        fClearingDetail = fClearingCore.returnFreshTrialDetail()
        
        
        print("setupTrialDetail called")
    }
    
    
    private func toggleAppearance(shouldHide: Bool) {
        
        if shouldHide {
            UIView.animate(withDuration: 0.3) {
                self.painPositionLabel.isHidden = true
                self.painBtnGroup.isHidden = true
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.painPositionLabel.isHidden = false
                self.painBtnGroup.isHidden = false
            }
        }
    }
    
    
//    private func updateTrialDetail() {
//        guard let trialCore = trialCore else { fatalError("trial Core is nil") }// could be changed.
//
//        let prevTrialDetails = trialCore.trialDetails.sorted { $0.trialNo < $1.trialNo }
//
//        if prevTrialDetails.count != 0 {
//            guard let lastDetailElement = prevTrialDetails.last else { fatalError("error:") }
//
//            if lastDetailElement.score != .DefaultValue.trialScore { // pain 에 대한 조건이 필요.
//                trialDetail = createTrialDetail(with: Int64(prevTrialDetails.count))
//            }
//
//        } else {
//            trialDetail = createTrialDetail(with: Int64(prevTrialDetails.count))
//        }
//    }
    
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
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(10)
        }
        

        [scoreBtn1, scoreBtn2, scoreBtn3].forEach {
            scoreBtnGroup.addArrangedButton($0)
        }
        
        
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
//            scoreStackView.addArrangedSubview(scoreBtn4)
            scoreBtnGroup.addArrangedButton(scoreBtn4)

            scoreBtn1.wrappedString = "0"
            scoreBtn2.wrappedString = "1"
            scoreBtn3.wrappedString = "2"
            scoreBtn4.wrappedString = "3"
            
//            scoreBtnGroup.buttons = [scoreBtn1, scoreBtn2, scoreBtn3, scoreBtn4]
        }
        
//        scoreStackView.snp.makeConstraints { make in
//            make.top.equalTo(scoreLabel.snp.bottom).offset(10)
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.height.equalTo(40)
//        }
        
        view.addSubview(scoreBtnGroup)
        scoreBtnGroup.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(35)
            make.height.equalTo(40)
        }
        
        painPlusBtn.wrappedString = "+"
        painMinusBtn.wrappedString = "-"
        
//        if painTestName != nil {
            view.addSubview(painPositionLabel)
            painPositionLabel.snp.makeConstraints { make in
//                make.top.equalTo(scoreStackView.snp.bottom).offset(20)
                make.top.equalTo(scoreBtnGroup.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(40) // same as that of scoreLabel
            }
        // TODO: setup painPositionLabel
//            painPositionLabel.text = painTestName ?? "Pain Test Name !"
//            painPositionLabel.numberOfLines = 2
            

            [painPlusBtn, painMinusBtn].forEach {
                painBtnGroup.addArrangedButton($0)
            }

            view.addSubview(painBtnGroup)
            painBtnGroup.snp.makeConstraints { make in
                make.top.equalTo(painPositionLabel.snp.bottom).offset(10)
//                make.leading.trailing.equalToSuperview().inset(50)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().dividedBy(2.5)
                make.height.equalTo(40)
            }
//        }
        
        if painTestName == nil {
            painBtnGroup.isHidden = true
            painPositionLabel.isHidden = true
        }
        
//        [deleteBtn, saveBtn].forEach {
//            bottomBtnStackView.addArrangedSubview($0)
//        }

//        view.addSubview(bottomBtnStackView)
//        bottomBtnStackView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(50)
//            make.height.equalTo(50)
//            make.top.equalTo(painBtnGroup.snp.bottom).offset(25)
//        }
        view.addSubview(deleteBtn)
        view.addSubview(saveBtn)
        
        deleteBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(painBtnGroup.snp.bottom).offset(25)
            make.height.equalTo(50)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        saveBtn.snp.makeConstraints { make in
            make.leading.equalTo(deleteBtn.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.equalTo(painBtnGroup.snp.bottom).offset(25)
            make.height.equalTo(50)
        }
        
//        if setupFTrialCoreIfNeeded() {
//            painBtnGroup.isHidden = true
//        } else { painBtnGroup.isHidden = false }
    }
    
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
