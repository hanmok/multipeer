//
//  ScoringController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/02.
//

import UIKit
import SnapKit
import Then

protocol ScoringControllerDelegate: AnyObject {
    func nextTapped()
    func retryTapped()
}

private let cellIdentifier = "ScoreIdentifier"
// TODO: apply MVVM Pattern for selected button color ( for convenience.. )
class ScoringController: UIViewController {

    let positionToScoreType: [String: ScoreType] = [
        PositionList.deepSquat.rawValue: .zeroThreeHold,
        PositionList.hurdleStep.rawValue: .zeroToThree,
        PositionList.inlineLunge.rawValue: .zeroToThree,
        PositionList.ankleClearing.rawValue: .zeroToThree,
        PositionList.shoulderMobility.rawValue: .zeroToThree,
        PositionList.shoulderClearing.rawValue: .zeroToThree,
        PositionList.activeStraightLegRaise.rawValue: .zeroToThree,
        PositionList.trunkStabilityPushUp.rawValue: .zeroToThree,
        PositionList.extensionClearing.rawValue: .zeroToThree,
        PositionList.rotaryStability.rawValue: .zeroToThree,
        PositionList.flexionClearing.rawValue: .zeroToThree
    ]
    
    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    var scoreType: ScoreType
    
    weak var delegate: ScoringControllerDelegate?
    
    
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
    
    
//    private func setupCollectionView() {
//        scoreCollectionView.delegate = self
//        scoreCollectionView.dataSource = self
//        scoreCollectionView.register(ScoreCell.self, forCellWithReuseIdentifier: cellIdentifier)
//    }
//
//    private let scoreCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return cv
//    }()
    
    
    
    private let zeroThreeHoldView = UIView()
    private let zeroToThreeView = UIView()
    private let zeroToTwoView = UIView()
}

//extension ScoringController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch scoreType {
//        case .zeroThreeHold:
//            return 3
//        case .zeroToThree:
//            return 4
//        case .zeroToTwo:
//            return 3
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//}

class ScoreView: UIView {
    var scoreType: ScoreType {
        didSet {
            loadView()
        }
    }
    
    private func loadView() {
        
    }
    
    init(scoreType: ScoreType = .zeroToThree, frame: CGRect = .zero) {
        self.scoreType = scoreType
        super.init(frame: frame)
        setupLayout()
    }
    private func setupLayout() {
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.leadi
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(50)
        }
        
        
        
        [view1, view2, view3, view4].forEach {
            addSubview($0)
        }
        
        view1.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            
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
}

