//
//  ScoringController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/02.
//

import UIKit
import SnapKit
import Then



protocol ScoreControllerDelegate: AnyObject {
    
    func deleteAction()
    func saveAction(with info: PositionDirectionScoreInfo)
    
    func nextAction()
    func retryAction()
    
//    func updateScore(_ score: Int)
    func moveUp()
    
    func updatePosition(with positionDirectionScoreInfo: PositionDirectionScoreInfo)
    func hideScoreController()
    func prepareRecording()
    
    func dismissCameraController()
}


class ScoreController: UIViewController {

    var hasPainField: Bool = false
    
    var positionTitle: String
    var direction: PositionDirection
//    var trialCore: TrialCore?
    
    var score: Int? {
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
    let scoreType: ScoreType
    
    
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
    }
    
    private let nextBtn = UIButton().then {
        $0.setTitle("Next", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
//    private let scoreStackView = UIStackView().then {
//        $0.distribution = .fillEqually
//        $0.spacing = 10
//    }
    
//    let painStackView = UIStackView().then {
//        $0.distribution = .fillEqually
//        $0.spacing = 10
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
        setupLayout()
        setupAddtargets()
//        btnGroup =
    }
    
    private let bottomBtnStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    private let bottomBtnStackView2 = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    init(positionDirectionScoreInfo: PositionDirectionScoreInfo) {
//        self.trialCore = trialCore
        self.positionTitle = positionDirectionScoreInfo.title
        self.direction = positionDirectionScoreInfo.direction
        self.scoreType = positionToScoreType[positionDirectionScoreInfo.title] ?? .zeroToThree
        
//        self.hasPainTest = (positionWithPainTestTitle[positionDirectionScoreInfo.title] != nil)
        
        self.painTestName = (positionWithPainTestTitle[positionDirectionScoreInfo.title])
        self.varTestName = (positionWithVariation[positionDirectionScoreInfo.title])
        
//        self.hasVariation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        scoreBtnGroup.buttonSelected(sender.id)
//        switch
        
//        guard let selectedScore = Int(scoreBtnGroup.selectedWrapper) else { return }
        if let selectedScore = Int(scoreBtnGroup.selectedWrapper) {
            score = selectedScore
        } else {
            switch scoreBtnGroup.selectedWrapper {
            case "Red": score = 0
            case "Yellow": score = 1
            case "Green": score = 2
            case "Hold":
                score = -1
                
            default: score = nil
            }
        }
        print("selectedBtn flag: \(score)")
        
        
//        score = selectedScore
    }
    
    @objc func painBtnTapped(_ sender: SelectableButton) {
        painBtnGroup.buttonSelected(sender.id)
        switch painBtnGroup.selectedWrapper {
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
        print("next Tapped!")
        delegate?.nextAction()
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
        delegate?.deleteAction()
    }
    
    @objc func retryTapped() {
        print("retry tapped!")
        delegate?.retryAction()
    }
    
    @objc func saveTapped() {
        delegate?.saveAction(with: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: score, pain: pain))
        
        navigateToSecondView()
    }
    
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
    
    private func toggleAppearance(shouldHide: Bool) {
        
        if shouldHide {
            painPositionLabel.isHidden = true
            painBtnGroup.isHidden = true
        } else {
            painPositionLabel.isHidden = false
            painBtnGroup.isHidden = false
        }
    }
    
    private func setupLayout() {
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
//            make.top.equalTo(scoreStackView.snp.bottom).offset(200)
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
}



class SecondScoreController: UIViewController {
    
}
