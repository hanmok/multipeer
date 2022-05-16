//
//  TrialDetailController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation


//
//  TrialDetailController.swift
//
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import UIKit
import SnapKit
import Then

// show only latest Trial Infos
// 어떤 Screen 이 주어진 상태에서, 그 때의 최신 값을 가져오기.
class TrialDetailController: UIViewController {
    
    var screen: Screen {
        didSet {
            setupLayout()
        }
    }
    
    let reuseId = "TrialCellId"
    
    private let trialCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
    private func registerCollectionView(customCollectionView: UICollectionView) {
        customCollectionView.register(TrialCell.self, forCellWithReuseIdentifier: reuseId)
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
    }
    
    init(screen: Screen) {
        self.screen = screen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionView(customCollectionView: trialCollectionView)
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(trialCollectionView)
        trialCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension TrialDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        return collectionData.count
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! TrialCell
        
//                cell.viewModel = TrialViewModel(directionCore: <#T##DirectionCore#>)
//        cell.viewModel = TrialViewModel(trialCore: <#T##TrialCore#>)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 100)
    }
}

// header 도 필요함
class TrialCell: UICollectionViewCell {
    var viewModel: TrialViewModel? {
        didSet {
            configureLayout()
        }
    }
    
    init(trialViewModel: TrialViewModel) {
        self.viewModel = trialViewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let positionImageView = UIImageView().then {
        $0.backgroundColor = .magenta
//        $0.textInputContextIdentifier
    }
    
    private let shortTitleLabel = UILabel().then { $0.backgroundColor = .cyan
        $0.textColor = .red
    }
    private let painScoreLabel = UILabel().then { $0.backgroundColor = .red
        $0.textColor = .blue
    }
    private let realScoreLabel = UILabel().then { $0.backgroundColor = .blue
        $0.textColor = .black
        
    }
    private let finalScoreLabel = UILabel().then { $0.backgroundColor = .brown
        $0.textColor = .white
    }
    
    private func configureLayout() {
        guard let viewModel = viewModel else { return }

        positionImageView.image = UIImage(imageLiteralResourceName: viewModel.imageName)
        shortTitleLabel.text = viewModel.titleName
        painScoreLabel.text = viewModel.painScore
        realScoreLabel.text = viewModel.realScore
        finalScoreLabel.text = viewModel.realScore
    }
    
    private func setupLayout() {
        
        [positionImageView, shortTitleLabel, painScoreLabel, realScoreLabel, finalScoreLabel].forEach { addSubview($0)}

        positionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        shortTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(positionImageView.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(160)
        }
        
        painScoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(shortTitleLabel.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        realScoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(painScoreLabel.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        finalScoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(realScoreLabel.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
    }
    
    
}


struct TrialViewModel {
    
//    let positionCore: PositionTit
    let trialCore: TrialCore
    // PositionTitle, Direction needed.
    var imageName: String { return trialCore.parentPositionTitle.correspondingImageString }
    var titleName: String { return trialCore.parentPositionTitle.title }
    var painScore: String { return convertPain(trialCore.latestWasPainful) }
    var realScore: String { return convertScore(trialCore.latestScore) }
    
    private func convertPain(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return "x"
        case 1: return "+"
        default: return "x"
        }
    }
    
    private func convertScore(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return "x"
        case 1: return "+"
        default: return "x"
        }
    }
}

extension PositionTitleCore {
    public var correspondingImageString: String {
        // use enum
        if self.title == "" {
            return String("folder")
        } else {
            return String("circle")
        }
    }
}
