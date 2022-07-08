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
        $0.backgroundColor = .magenta
    }
    
    private let shortTitleLabel = UILabel().then { $0.backgroundColor = .cyan
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textColor = .red
        $0.numberOfLines = 0
    }
    
    private let painScoreLabel = UILabel().then { $0.backgroundColor = .green
        $0.textAlignment = .center
        $0.textColor = .blue
    }
    
    private let realScoreLabel = UILabel().then { $0.backgroundColor = .blue
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let finalScoreLabel = UILabel().then { $0.backgroundColor = .brown
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    private func configureLayout() {
        guard let viewModel = viewModel else { return }

        shortTitleLabel.text = viewModel.titleWithDirection
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
        
        finalScoreLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
        
        
        realScoreLabel.snp.makeConstraints { make in
            make.trailing.equalTo(finalScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }

        
        painScoreLabel.snp.makeConstraints { make in
            make.trailing.equalTo(realScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        shortTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(positionImageView.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(painScoreLabel.snp.leading).offset(-5)
        }
    }
    
    
}
