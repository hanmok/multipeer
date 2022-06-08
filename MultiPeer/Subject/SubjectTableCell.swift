//
//  SubjectTableCell.swift
//  MultiPeer
//
//  Created by 이한목 on 2022/05/23.
//

import UIKit
import SnapKit
import Then



// MARK: - SubjectTableCell
class SubjectTableCell: UITableViewCell {
    
    var viewModel: SubjectViewModel? {
        didSet {
            configureLayout()
        }
    }
    
    private let nameWithCountLabel = UILabel()
    private let profileView = UIImageView().then {
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
        $0.backgroundColor = .white
    }
    private let detailInfoLabel = UILabel()
    private let lastUpdateLabel = UILabel()
    
    static let identifier = "subjectTableCell"
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        makeSelfClickable()
        
    }
    
    private func configureLayout() {
        guard let vm = viewModel else { return }
//        imageView.image = UIImage()
        
        nameWithCountLabel.text = vm.subjectName + "  " + vm.numOfTestConducted + " " + "times"
        detailInfoLabel.text = vm.gender + " / " + vm.age + " / " + vm.phoneNumber
        lastUpdateLabel.text = (vm.lastUpdatedAt != "") ? ("Last Update" + " " + vm.lastUpdatedAt) : ""
    }
    
    private func setupLayout() {
        [profileView, nameWithCountLabel, detailInfoLabel, lastUpdateLabel].forEach {self.addSubview($0)}
        profileView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(70)
        }
        
        nameWithCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(10)
            make.top.trailing.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        detailInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(10)
            make.top.equalTo(nameWithCountLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        lastUpdateLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(10)
            make.top.equalTo(detailInfoLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(15)
        }
    }
    
    private func makeSelfClickable() {
        isUserInteractionEnabled = true
    }
    
}
