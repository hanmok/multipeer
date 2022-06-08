//
//  TrialHeader.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/17.
//

import Foundation

import UIKit
import SnapKit
import Then

class TrialHeader: UICollectionReusableView {
    
    
    private let positionImageLabel = UILabel().then {
        $0.text = "Guide"
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    private let shortTitleLabel = UILabel().then { $0.backgroundColor = .cyan
        $0.text = "Position Title"
//        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textAlignment = .center
        $0.backgroundColor = .black
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let painScoreLabel = UILabel().then {
        $0.text = "Pain"
        $0.backgroundColor = .black
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
    private let realScoreLabel = UILabel().then {
        $0.text = "L / R"
        $0.textAlignment = .center
        $0.backgroundColor = .black
        $0.textColor = .white
    }
    
    private let finalScoreLabel = UILabel().then {
        $0.text = "Final"
//        $0.backgroundColor = .brown
        $0.textAlignment = .center
        $0.backgroundColor = .black
        $0.textColor = .white
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [positionImageLabel, shortTitleLabel, painScoreLabel, realScoreLabel, finalScoreLabel].forEach {addSubview($0)
        }
        
        positionImageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        finalScoreLabel.snp.makeConstraints { make in
//            make.leading.equalTo(realScoreLabel.snp.trailing).offset(5)
            make.width.equalTo(40)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(60)
//            make.width.equalTo(40)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        
        realScoreLabel.snp.makeConstraints { make in
//            make.leading.equalTo(painScoreLabel.snp.trailing).offset(5)
            make.trailing.equalTo(finalScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }

        
        painScoreLabel.snp.makeConstraints { make in
//            make.leading.equalTo(shortTitleLabel.snp.trailing).offset(5)
            make.trailing.equalTo(realScoreLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        shortTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(positionImageLabel.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(160)
            make.trailing.equalTo(painScoreLabel.snp.leading).offset(-5)
        }
        

    }
}
