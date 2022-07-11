//
//  TrialCell.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation
import UIKit
import SnapKit
import Then


// header 도 필요함
class TrialCell: UICollectionViewCell {
    var viewModel: TrialViewModel? {
        didSet {
            configureLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let positionImageView = UIImageView().then {
        $0.backgroundColor =  .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
//        $0.backgroundColor = .cyan
        $0.backgroundColor = .white
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
//        $0.textColor = .red
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private let realScoreLabel = UILabel().then {
//        $0.backgroundColor = .blue
        $0.textAlignment = .center
        $0.textColor = .black
        $0.backgroundColor = .white
    }
    
    private let painScoreLabel = UILabel().then {
//        $0.backgroundColor = .green
        $0.textAlignment = .center
//        $0.textColor = .blue
        $0.textColor = .black
        $0.backgroundColor = .white
    }
    
    private let finalScoreLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .black
        $0.backgroundColor = .white
    }
    
    private func configureLayout() {
        guard let viewModel = viewModel else { return }

        positionImageView.image = UIImage(imageLiteralResourceName: viewModel.imageName)
        
        titleLabel.text = viewModel.titleName
        
        painScoreLabel.text = viewModel.painText

        realScoreLabel.text = viewModel.scoreTobePrinted

        finalScoreLabel.text = viewModel.finalScore
        
    }
    
    private func setupLayout() {
        
        [positionImageView, titleLabel, painScoreLabel, realScoreLabel, finalScoreLabel
        ].forEach { addSubview($0)}
        
        positionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        finalScoreLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(70)
        }
        
//        painScoreLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(finalScoreLabel.snp.leading).offset(-5)
//            make.top.bottom.equalToSuperview()
//            make.width.equalTo(70)
//        }
        
        realScoreLabel.snp.makeConstraints { make in
            make.trailing.equalTo(finalScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(70)
        }
        
//        realScoreLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(painScoreLabel.snp.leading).offset(-5)
//            make.top.bottom.equalToSuperview()
//            make.width.equalTo(70)
//        }
        painScoreLabel.snp.makeConstraints { make in
            make.trailing.equalTo(realScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(positionImageView.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(realScoreLabel.snp.leading).offset(-5)
        }
    }
}
