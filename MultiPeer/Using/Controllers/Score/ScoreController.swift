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
    func nextTapped()
    func retryTapped()
}

private let cellIdentifier = "ScoreIdentifier"
// TODO: apply MVVM Pattern for selected button color ( for convenience.. )
class ScoreController: UIViewController {

    let positionToScoreType: [String: ScoreType] = [
        PositionList.deepSquat.rawValue: .zeroThreeHold,
        PositionList.deepSquatVar.rawValue: .zeroToTwo,
        
        PositionList.hurdleStep.rawValue: .zeroToThree,
        PositionList.inlineLunge.rawValue: .zeroToThree,

        PositionList.ankleClearing.rawValue: .painOrNot,
//        PositionList.ankleClearing.rawValue: .RGB,
        
        PositionList.shoulderMobility.rawValue: .zeroToThree,
        PositionList.shoulderClearing.rawValue: .painOrNot,
        
        PositionList.activeStraightLegRaise.rawValue: .zeroToThree,
        
        PositionList.trunkStabilityPushUp.rawValue: .zeroThreeHold,
        PositionList.trunkStabilityPushUpVar.rawValue: .zeroToTwo,
        PositionList.extensionClearing.rawValue: .painOrNot,
        
        PositionList.rotaryStability.rawValue: .zeroToThree,
        PositionList.flexionClearing.rawValue: .painOrNot
    ]
    
    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    var scoreType: ScoreType
    
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
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
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
        
    }
    
    
    private let zeroThreeHoldView = UIView()
    private let zeroToThreeView = UIView()
    private let zeroToTwoView = UIView()
}


class ScoreView: UIView {
    var scoreType: ScoreType {
        didSet {
//            loadView()
            setupLayout()
        }
    }
    
    private func loadView() {
        
    }
    
    init(scoreType: ScoreType = .zeroToThree, frame: CGRect = .zero) {
        self.scoreType = scoreType
        super.init(frame: frame)
//        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(50)
        }
        
        
        [view1, view2, view3].forEach {
            addSubview($0)
        }
        
        
        // Three Elements
        if scoreType == .zeroThreeHold || scoreType == .zeroToTwo{
            view1.snp.makeConstraints { make in
//                make.leading.equalToSuperview()
                make.leading.top.equalToSuperview()
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            view2.snp.makeConstraints { make in
//                make.leading.top.equalToSuperview()
                make.top.equalToSuperview()
                make.leading.equalTo(view1.snp.trailing)
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            view3.snp.makeConstraints { make in
//                make.leading.top.equalToSuperview()
                make.top.equalToSuperview()
                make.leading.equalTo(view2.snp.trailing)
                make.height.equalTo(40)
                make.width.equalToSuperview().dividedBy(3)
            }
            
            
            // Four Elements
        } else if scoreType == .zeroToThree {
            addSubview(view4)
        }
        
        view1.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(20)
//            make.leading.trailing.equalToSuperview()
//            make.leading.
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let scoreLabel = UILabel().then { $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        $0.textColor = .black
    }
    private let view1 = UIButton().then {
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
    }
    private let view2 = UIButton().then {
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
    }
    private let view3 = UIButton().then {
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
    }
    private let view4 = UIButton().then {
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
    }
}




public enum ScoreType {
    case zeroThreeHold
    case zeroToThree
    case zeroToTwo
    case painOrNot
    case RGB
}
