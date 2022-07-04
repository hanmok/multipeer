//
//  ScreenTableCell.swift
//  MultiPeer
//
//  Created by 이한목 on 2022/05/23.
//

import UIKit
import SnapKit
import Then



class ScreenTableCell: UITableViewCell {
    
    
    var viewModel: ScreenViewModel? {
            didSet {
                configureLayout()
            }
        }
    
    public var isSelected_: Bool {
        get {
            self.isSelected
        }
        set {
            self.isSelected = newValue
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
        $0.adjustsFontSizeToFitWidth = true
        
    }
    
    static let identifier = "screenTableCell"
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        makeSelfClickable()
        
    }
    
    private func setupLayout() {
        [sequenceIndexLabel, dateLabel, scoreLabel].forEach { addSubview($0)}
        
        sequenceIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
            make.width.equalTo(50)
//            make.top.bottom.equalToSuperview().inset(2)
            make.top.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(sequenceIndexLabel.snp.trailing).offset(20)
//            make.top.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
//            make.top.bottom.equalToSuperview().inset(2)
            make.top.bottom.equalToSuperview()
        }
        
        
        scoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview()
//            make.top.bottom.equalToSuperview().inset(2)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func makeSelfClickable() {
        isUserInteractionEnabled = true
    }
    
    private func configureLayout() {
        guard let vm = viewModel else { return }
        
        sequenceIndexLabel.text = vm.sequenceIndex
        print("sequenceIndex: \(vm.sequenceIndex)")
        dateLabel.text = " \(vm.date) "
        scoreLabel.text = " \(vm.score) "
        print("vm.score: \(vm.score)")
    }
}
