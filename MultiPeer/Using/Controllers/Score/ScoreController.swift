//
//  ScoringController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/02.
//

import UIKit
import SnapKit
import Then




public enum ScoreType {
    case zeroThreeHold
    case zeroToThree
    case zeroToTwo
    case painOrNot
    case RYG
}

public enum PositionWithPain {
    case ankleClearing
    case shoulderClearing
    case extensionClearing
    case flexionClearing
}


protocol ScoreControllerDelegate: AnyObject {
    func nextTapped()
    func retryTapped()
    func updateScore(_ score: String)
}


private let cellIdentifier = "ScoreIdentifier"
// TODO: apply MVVM Pattern for selected button color ( for convenience.. )
class ScoreController: UIViewController {

    let hasPainField: Bool = false
//    var pr
    let positionToScoreType: [String: ScoreType] = [
        PositionList.deepSquat.rawValue: .zeroThreeHold,
        PositionList.deepSquatVar.rawValue: .zeroToTwo,
        
        PositionList.hurdleStep.rawValue: .zeroToThree,
        PositionList.inlineLunge.rawValue: .zeroToThree,

        PositionList.ankleClearing.rawValue: .RYG,
//        PositionList.ankleClearing.rawValue: .RGB,
        
        PositionList.shoulderMobility.rawValue: .zeroToThree,
//        PositionList.shoulderClearing.rawValue: .painOrNot,
        
        PositionList.activeStraightLegRaise.rawValue: .zeroToThree,
        
        PositionList.trunkStabilityPushUp.rawValue: .zeroThreeHold,
        PositionList.trunkStabilityPushUpVar.rawValue: .zeroToTwo,
//        PositionList.extensionClearing.rawValue: .painOrNot,
        
        PositionList.rotaryStability.rawValue: .zeroToThree,
//        PositionList.flexionClearing.rawValue: .painOrNot
    ]
    
    let positionsHasPain = [
        PositionList.ankleClearing.rawValue,
        PositionList.shoulderClearing.rawValue,
        PositionList.flexionClearing.rawValue,
        PositionList.extensionClearing.rawValue
    ]
    
    let positionsWithVar : [(before: String, after: String )] = [(PositionList.deepSquat.rawValue: positionlist)]
    
//    let coupled
    
    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    let scoreType: ScoreType
    
    weak var delegate: ScoreControllerDelegate?
    
    private let scoreLabel = UILabel().then {
        $0.text = "Score"
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    private let deleteBtn = UIButton().then {
        $0.setTitle("Delete", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let retryBtn = UIButton().then {
        $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let nextBtn = UIButton().then {
        $0.setTitle("Next", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
//        view.backgroundColor =
//        view.addSubview(scoreLabel)
//        scoreLabel.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.height.equalTo(100)
//        }
        
//        setupCollectionView()
        setupLayout()
        // Do any additional setup after loading the view.
    }
    
    
    init(positionWithDirectionInfo: PositionWithDirectionInfo) {
        self.positionTitle = positionWithDirectionInfo.title
        self.direction = positionWithDirectionInfo.direction
        self.score = positionWithDirectionInfo.score
        self.scoreType = positionToScoreType[positionWithDirectionInfo.title] ?? .zeroToThree
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(50)
        }
        
        [view1, view2, view3].forEach {
            view.addSubview($0)
        }
        
        // Three Elements
        if scoreType == .zeroThreeHold || scoreType == .zeroToTwo || scoreType == .RYG{
            view1.snp.makeConstraints { make in
                make.leading.top.equalToSuperview()
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            view2.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalTo(view1.snp.trailing)
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            view3.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalTo(view2.snp.trailing)
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            if scoreType == .zeroThreeHold {
                view1.wrappedScoreString = "0"
                view2.wrappedScoreString = "3"
                view3.wrappedScoreString = "Hold"
            } else if scoreType == .zeroToTwo {
                view1.wrappedScoreString = "0"
                view2.wrappedScoreString = "1"
                view3.wrappedScoreString = "2"
            } else if scoreType == .RYG {
                view1.wrappedScoreString = "Red"
                view2.wrappedScoreString = "Yellow"
                view3.wrappedScoreString = "Green"
            }
            
            
            // Four Elements
        } else if scoreType == .zeroToThree {
            view.addSubview(view4)
            
            view1.snp.makeConstraints { make in
                make.top.equalTo(scoreLabel.snp.bottom).offset(20)
                make.leading.equalToSuperview()
                make.width.equalToSuperview().dividedBy(4)
                make.height.equalTo(40)
            }
            view1.setTitle("0", for: .normal)
            
            view2.snp.makeConstraints { make in
                make.top.equalTo(scoreLabel.snp.bottom).offset(20)
                make.leading.equalTo(view1.snp.trailing)
                make.width.equalToSuperview().dividedBy(4)
                make.height.equalTo(40)
            }
            
            view3.snp.makeConstraints { make in
                make.top.equalTo(scoreLabel.snp.bottom).offset(20)
                make.leading.equalTo(view1.snp.trailing)
                make.width.equalToSuperview().dividedBy(4)
                make.height.equalTo(40)
            }
            
            view4.snp.makeConstraints { make in
                make.top.equalTo(scoreLabel.snp.bottom).offset(20)
                make.leading.equalTo(view1.snp.trailing)
                make.width.equalToSuperview().dividedBy(4)
                make.height.equalTo(40)
            }

            view1.wrappedScoreString = "0"
            view2.wrappedScoreString = "1"
            view3.wrappedScoreString = "2"
            view4.wrappedScoreString = "3"
        }
    }
    
    
    private let view1 = ScoreButton()
    private let view2 = ScoreButton()
    private let view3 = ScoreButton()
    private let view4 = ScoreButton()
}






