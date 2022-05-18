//
//  ScreenCell.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//


import UIKit
import SnapKit
import Then


//protocol ScreenCellDelegate: AnyObject {
//    func cellPressed()
//}

class ScreenCell: RemovableCell {
    
//    weak var delegate: ScreenCellDelegate?
    
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
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        if selected {
//            contentView. backgroundColor = UIColor. green.
//        } else {
//            contentView. backgroundColor = UIColor. blue.
//        }
//    }
        
        
    
    public func paintSelf() {
//        backgroundColor = .magenta
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
        makeSelfClickable()

    }
    
    private func makeSelfClickable() {
       isUserInteractionEnabled = true
    }
    
    private func setupLayout() {
        [sequenceIndexLabel, dateLabel, scoreLabel].forEach { addSubview($0)}
        
        sequenceIndexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(sequenceIndexLabel.snp.trailing).offset(20)
//            make.top.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        
        scoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(2)
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
