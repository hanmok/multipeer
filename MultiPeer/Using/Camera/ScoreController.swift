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
//    func saveAction(with info: PositionDirectionScoreInfo, trialNo: Int)
    func saveAction(core: TrialCore, detail: TrialDetail) // 알아서 처리됨 ..;; 여기서 다 처리하면 ? 아닌가? 다른앤ㄱ ㅏ??
    
    func nextAction() // update Trial Core (position could be changed depening on position)
    func retryAction() // update Trial detail
    
//    func updateScore(_ score: Int)
//    func moveUp()
    
    func updatePosition(with positionDirectionScoreInfo: PositionDirectionScoreInfo)
    func hideScoreController()
    func prepareRecording()
    
    func dismissCameraController()
    
    
}


class ScoreController: UIViewController {

    var hasPainField: Bool = false
    
    var positionTitle: String
    var direction: PositionDirection

    var trialCore: TrialCore? // 왜 comment 처리 해놧었지 ??
    var trialDetail: TrialDetail?

    var fClearingCore: TrialCore?
    var fClearingDetail: TrialDetail?
    
    var score: Int64? { // why int instead of Int64 ?? 모든 계산은 64 로 하고, 나중에 Int 로 반환하자.
        willSet {
            // if it has variation following, toggle Clearing Test depening on score value
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
    
    private let scoreBtn1 = ScoreButton()
    private let scoreBtn2 = ScoreButton()
    private let scoreBtn3 = ScoreButton()
    private let scoreBtn4 = ScoreButton()
    
    private let painPlusBtn = ScoreButton("+")
    private let painMinusBtn = ScoreButton("-")
    
    public var scoreBtnGroup = SelectableButtonStackView()
    public var painBtnGroup = SelectableButtonStackView()
    
    
    private let scoreLabel = UILabel().then {
        $0.text = "Score"
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    private let painPositionLabel = UILabel().then {
        $0.text = "Pain Score"
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    private let deleteBtn = UIButton().then {
        $0.setTitle("Delete", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    private let retryBtn = UIButton().then {
        $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    private let nextBtn = UIButton().then {
        $0.setTitle("Next", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParentLayout()
        
        setupLayout()
        setupAddtargets()
    }
    
    private func setupParentLayout() {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
    }
    
    
    private let bottomBtnStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    private let bottomBtnStackView2 = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    public func setupTrialCore(with trialCore: TrialCore) {
        // setup trialcore f
        self.trialCore = trialCore
    }
    
    init(positionDirectionScoreInfo: PositionDirectionScoreInfo) {
//        self.trialCore = trialCore
        self.positionTitle = positionDirectionScoreInfo.title
        self.direction = positionDirectionScoreInfo.direction
        self.scoreType = positionToScoreType[positionDirectionScoreInfo.title] ?? .zeroToThree
        
//        self.hasPainTest = (positionWithPainTestTitle[positionDirectionScoreInfo.title] != nil)
        
        self.painTestName = (positionWithPainTestTitle[positionDirectionScoreInfo.title])
        self.varTestName = (positionWithVariation[positionDirectionScoreInfo.title])
//        print("positionDirectionScoreInfo.title: \(positio)")
        print("painTestName: \(painTestName)")
//        print("varTestName: \(varTestName)")
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
//    public func
    public func setupAgain(with positionDirectionScoreInfo: PositionDirectionScoreInfo) {
        
//        trialCore =
        
        self.positionTitle = positionDirectionScoreInfo.title
        self.direction = positionDirectionScoreInfo.direction
        self.scoreType = positionToScoreType[positionDirectionScoreInfo.title] ?? .zeroToThree
        
        
        self.painTestName = (positionWithPainTestTitle[positionDirectionScoreInfo.title])
        self.varTestName = (positionWithVariation[positionDirectionScoreInfo.title])
        
        print("painTestName: \(painTestName)")
//        print("varTestName: \(varTestName)")
        
        viewDidLoad()
        toggleAppearance(shouldHide: false)
        
        setupInitialValues()
    }
    
    
    
    private func setupInitialValues() {
        score = nil
        pain = nil
    }
    
    
    
    
    private func setupAddtargets() {
        for btn in scoreBtnGroup.buttons {
            btn.addTarget(self, action: #selector(scoreBtnTapped(_:)), for: .touchUpInside)
        }
        for btn in painBtnGroup.buttons {
            btn.addTarget(self, action: #selector(painBtnTapped(_:)), for: .touchUpInside)
        }

        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        retryBtn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
            }
    
    
    @objc func scoreBtnTapped(_ sender: SelectableButton) {
        scoreBtnGroup.setSelectedButton(sender.id)
        
        if let selectedScore = Int(scoreBtnGroup.selectedBtnTitle) {
            score = Int64(selectedScore)
        } else {
            switch scoreBtnGroup.selectedBtnTitle {
            
            case "Hold": score = -1
                
            case "Red": score = 0
            case "Yellow": score = 1
            case "Green": score = 2

            default: score = nil
            }
        }
        print("selectedBtn flag: \(score)")
        
        
//        score = selectedScore
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

    @objc func nextTapped() {
        // TODO: Core, Detail 초기화 해주기 !!
        
//        delegate?.nextAction() // do nothing for now
        
        print("scoreBtn3 Selected: \(scoreBtn3.isSelected)")
        print("scoreBtn3 wrappedScoreString :\(scoreBtn3.wrappedString)")
        
        if scoreBtn3.isSelected && scoreBtn3.wrappedString == "Hold" {
            print("move to variation !")
            guard let varTestName = varTestName else {
                return
            }

            delegate?.updatePosition(with: PositionDirectionScoreInfo(title: varTestName, direction: .neutral, score: nil, pain: nil))
            
            delegate?.hideScoreController()
            delegate?.prepareRecording()
        } else {

            delegate?.dismissCameraController()
        }
    }
    
    @objc func deleteTapped() {
        print("delete tapped!")
        
        setSelectedButtonNone()
        delegate?.deleteAction()
    }
    
    private func setSelectedButtonNone() {
        scoreBtnGroup.setSelectedButton(nil)
        painBtnGroup.setSelectedButton(nil)
    }
    
    @objc func retryTapped() {
        print("retry tapped!")
        // TODO: update detail
        updateTrialDetail()
        
        setSelectedButtonNone()
        delegate?.retryAction()
    }
    
    private func setScore(title: String, to trialDetail: TrialDetail, score: Int64 = .DefaultValue.trialScore, pain: Bool? = nil) {
        print("ffff setScore triggered, pain: \(pain)")
        var converted = Int64.DefaultValue.trialPain
        
        if positionWithPainNoAnkle.contains(title) && pain != nil {
            print("ffff if if setscore called, title: \(title), pain : \(pain)")
            converted = pain! ? .Value.painFul : .Value.notPainful
        } else {
            print("ffff else in setscore called, title: \(title), pain: \(pain) ")
        }
        
        trialDetail.setValue(score, forKey: .TrialDetailStr.score)
        trialDetail.setValue(converted, forKey: .TrialDetailStr.isPainful)
        print("ffff score: \(score), pain: \(converted)")
        trialDetail.saveChanges()
    }

    private func setupfTrialCoreIfNeeded() {

        guard let trialCore = trialCore else { fatalError("trialCore is nil") }

        
//        if positionsHasPain.contains(trialCore.title) {
        if positionWithPainTestTitle[trialCore.title] != nil {
        print("positionHasPain contains trialCore.title, trialCore.title : \(trialCore.title)")
            if trialCore.title != PositionList.ankleClearing.rawValue {
                guard let followingTitle = positionWithPainTestTitle[trialCore.title] else { fatalError("failed to get followingTitle") }
                print("followingTitle: \(followingTitle)")
                
                let screen = trialCore.parentScreen
                for eachCore in screen.trialCores {
                    print("eachCore's title: \(eachCore.title)")
                    
                    if eachCore.title == followingTitle {
                        fClearingCore = eachCore
                        break
                    }
                }
            }
        } else {
            print("positionHasPain does not contains \(trialCore.title)")
            for eachTitle in positionsHasPain {
                print("name of position that has pain: \(eachTitle)")
            }
        }
        print("setupfTrialCoreIfNeeded has ended!")
        
//        guard let fClearingCore = fClearingCore else {
//            fatalError("fClearingCore is invalid") // ankle Clearing ->
//        }

        print("fClearingCore.title name0 :\(fClearingCore?.title)")
    }
    
    // clearing Test 가 있는 것들은 어떻게 진행됨 ?
    // 여기서 정해줘야함 !
    @objc func saveTapped() {
        if saveConditionSatisfied() {
            
            guard let score = score else { fatalError("score is nil")}
            print("save Condition satisfied.")
            
            setupfTrialCoreIfNeeded()
            
            // setup Detail both trial and fclearing
            // Ankle 에서 Nil 나옴..
            setupTrialDetail()
            
            guard let trialCore = trialCore else { fatalError("trialCore is nil") }
            guard let trialDetail = trialDetail else { fatalError("trialDetail is nil") }
            
            
            setScore(title: trialCore.title, to: trialDetail, score: score, pain: pain)
            
            delegate?.saveAction(core: trialCore, detail: trialDetail)
            trialCore.updateLatestScore()
            
            
            
            // for pain test only (ankle mobility not contained)
//            guard let fClearingCore2 = fClearingCore else {
//                fatalError("fClearingCore in invalid")
//            }
//
//            guard let fClearingDetail2 = fClearingDetail else {
//                fatalError("fClearingDetail in invalid")
//            }

            // 어떤게 invalid 일까 ?? 둘다일 수 있다.
            if fClearingCore != nil && fClearingDetail != nil {
                print("fClearingCore and fClearingDetail is valid ")
                print("fClearingCore Name1: \(fClearingCore!.title)")
                setScore(title: fClearingCore!.title , to: fClearingDetail!, score: .DefaultValue.trialScore, pain: pain)
                print("fClearingCore Name2: \(fClearingCore!.title)") // 여기까진 정상..
                delegate?.saveAction(core: fClearingCore!, detail: fClearingDetail!)
                print("fClearingCore Name3: \(fClearingCore!.title)")
                fClearingCore!.updateLatestScore()
            } else {
                print("fClearingCore or fClearingDetail is invalid ")
            }
            
            navigateToSecondView()
            
        } else { print("save Condition not satisfied.") }
    }
    
    
    
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
    // 로직이.. 좀 꼬였네.. ;;;;
    // 이거, 일부가 trialCore Helper 에 있어야함.
    
    func setupTrialDetail() {
        
        guard let trialCore = trialCore else { fatalError("trialCOre is nil") }
        trialDetail = trialCore.returnFreshTrialDetail()
        
        guard let fClearingCore = fClearingCore else { return }
        fClearingDetail = fClearingCore.returnFreshTrialDetail()
        
        
//        fClearingCore =
//        trialDetail = trialcore
        
        print("setupTrialDetail called")
        // Create New DetailIfNeeded
        
//        guard let trialCore = trialCore else { fatalError("trial Core is nil") }
        
//        let sortedDetails = trialCore.trialDetails.sorted { $0.trialNo < $1.trialNo }
//
//        if sortedDetails.count != 0 {
//            guard let lastDetailElement = sortedDetails.last else { return }
//
//            guard let positionTitle = PositionList(rawValue: trialCore.title) else { fatalError("failed to convert into positionTitle") }
//
//            switch positionTitle {
//
//            case .ankleClearing:
//                updateDetail(
//                    condition: lastDetailElement.isPainful == .DefaultValue.trialPain || lastDetailElement.score == .DefaultValue.trialScore,
//                    lastElement: lastDetailElement, to: trialCore)
//
//
//            case .flexionClearing, .shoulderClearing, .extensionClearing :
//                updateDetail(condition: lastDetailElement.isPainful == .DefaultValue.trialPain,
//                             lastElement: lastDetailElement, to: trialCore)
//
//            default:
//                updateDetail(condition: lastDetailElement.score == .DefaultValue.trialScore, lastElement: lastDetailElement, to: trialCore)
//            }
//
//        } else { // Create one
//            updateDetail(condition: false, lastElement: nil, to: trialCore)
//        }
////        guard let trialCore = trialCore else { fatalError("trial core is nil")}
//        guard let trialDetail = trialDetail else {
//          fatalError("trial detail is nil")
//        }
//
//
//        guard let fClearingCore = fClearingCore else {
//            return
//        }
//        // make fClearingDetail
//        let sortedfDetails = fClearingCore.trialDetails.sorted { $0.trialNo < $1.trialNo }
//        if sortedfDetails.count != 0 {
//            guard let lastfDetailElement = sortedfDetails.last else { return }
//            if lastfDetailElement.isPainful == .DefaultValue.trialPain {
//                fClearingDetail = lastfDetailElement
//            } else {
//                fClearingDetail = createDetail(core: fClearingCore)
//            }
//        } else {
//            updateDetail(condition: false, lastElement: nil, to: fClearingCore)
//        }
//
//        print("currentState: core: \(trialCore),\n detail: \(trialDetail)")
    }
    
    // if condition is true, use existing one
//    func updateDetail(condition:Bool, lastElement: TrialDetail?, to trialCore: TrialCore) {
//        trialDetail = condition ? lastElement : createDetail(core: trialCore)
//    }
//
////    @discardableResult
//
//    func createDetail(core: TrialCore) -> TrialDetail{
//
//        let numOfDetails = core.trialDetails.count
//        print("numOfDetails: \(numOfDetails)")
//        return TrialDetail.save(belongTo: core, trialNo: numOfDetails)
//    }
    
    private let uploadStateLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        $0.textColor = .white
        $0.text = "Upload Completed !"
        $0.textAlignment = .center
    }
    

    private let secondView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private func navigateToSecondView() {
        print("navigateToSecondView triggered!")
        UIView.animate(withDuration: 0.25, animations: {
            self.secondView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        })
    }
    // 이상함. 뭔가 잘못됐음. 원래 secondView 위치는 ?
    public func navigateBackToFirstView() {
        print("navigateBackToFirstView triggered!")

        DispatchQueue.main.async {
            self.secondView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        }
    }
    
    private func toggleAppearance(shouldHide: Bool) {
        
        if shouldHide {
            painPositionLabel.isHidden = true
            painBtnGroup.isHidden = true
        } else {
            painPositionLabel.isHidden = false
            painBtnGroup.isHidden = false
        }
    }
    
    
    private func updateTrialDetail() {
        guard let trialCore = trialCore else { fatalError("trial Core is nil") }// could be changed.
        
        let prevTrialDetails = trialCore.trialDetails.sorted { $0.trialNo < $1.trialNo }
        
        if prevTrialDetails.count != 0 {
            guard let lastDetailElement = prevTrialDetails.last else { fatalError("error:") }
            
            if lastDetailElement.score != .DefaultValue.trialScore { // pain 에 대한 조건이 필요.
                trialDetail = createTrialDetail(with: Int64(prevTrialDetails.count))
            }
            
        } else {
            trialDetail = createTrialDetail(with: Int64(prevTrialDetails.count))
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
        
        // 이걸.. 굳이 다시.... ??
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(50)
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
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        
        painPlusBtn.wrappedString = "+"
        painMinusBtn.wrappedString = "-"
        
        if painTestName != nil {
            print("flag!!!! painTestName is Not Nil!!!")
            view.addSubview(painPositionLabel)
            painPositionLabel.snp.makeConstraints { make in
//                make.top.equalTo(scoreStackView.snp.bottom).offset(20)
                make.top.equalTo(scoreBtnGroup.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(50) // same as that of scoreLabel
            }
            painPositionLabel.text = painTestName ?? "Pain Test Name !"
            painPositionLabel.numberOfLines = 2
            
            [painPlusBtn, painMinusBtn].forEach {
                painBtnGroup.addArrangedButton($0)
            }

            view.addSubview(painBtnGroup)
            painBtnGroup.snp.makeConstraints { make in
                make.top.equalTo(painPositionLabel.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(50)
                make.height.equalTo(40)
            }
        }
        
        [deleteBtn, saveBtn].forEach {
            bottomBtnStackView.addArrangedSubview($0)
        }

        view.addSubview(bottomBtnStackView)
        bottomBtnStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(60)
            make.top.equalTo(scoreBtnGroup.snp.bottom).offset(200)
        }
        
        view.addSubview(secondView)
        secondView.addSubview(bottomBtnStackView2)
        secondView.addSubview(uploadStateLabel)

        uploadStateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(150)
            make.height.equalTo(120)
        }
        
        [retryBtn, nextBtn].forEach {
            bottomBtnStackView2.addArrangedSubview($0)
        }
        
        secondView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        bottomBtnStackView2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(60)
            make.top.equalToSuperview().offset(350)
        }
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



class SecondScoreController: UIViewController {
    
}
