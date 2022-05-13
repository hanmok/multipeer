//
//  ScreenCell.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//


import UIKit
import SnapKit
import Then

class ScreenCell: UICollectionViewCell {
    var viewModel: ScreenViewModel? {
            didSet {
                configureLayout()
            }
        }
    
    private let sequenceIndexLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .cyan
        $0.backgroundColor = .gray
    }
    private let dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .cyan
        $0.backgroundColor = .gray
    }
    private let scoreLabel = UILabel().then {
        $0.textColor = .red
        $0.textAlignment = .center
        $0.backgroundColor = .darkGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        [sequenceIndexLabel, dateLabel, scoreLabel].forEach { addSubview($0)}
        
        sequenceIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(sequenceIndexLabel.snp.trailing).offset(20)
            make.top.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.bottom.equalToSuperview()
        }
        
        scoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(20)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureLayout() {
        guard let vm = viewModel else { return }
        
        sequenceIndexLabel.text = vm.sequenceIndex
        print("sequenceIndex: \(vm.sequenceIndex)")
        dateLabel.text = vm.date
        scoreLabel.text = vm.score
        print("vm.score: \(vm.score)")

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
