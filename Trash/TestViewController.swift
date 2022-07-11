//
//  TestViewController.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/06/15.
//

import Foundation
import UIKit
import SnapKit
import Then

class TestViewController: UIViewController {
    
    
    private let completeMsgLabel = UILabel().then {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrText = NSMutableAttributedString(string: "Upload Completed\n", attributes: [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph]
        )
        
        
        $0.attributedText = attrText
        $0.numberOfLines = 0
        
        $0.backgroundColor = .blue
        
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = false
        $0.layer.shadowRadius = 5
        $0.layer.shadowOpacity = 1.0
        
        $0.layer.shadowOffset = CGSize(width: -10, height: -10)
        
        $0.layer.shadowColor = UIColor.green.cgColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(completeMsgLabel)
        completeMsgLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalToSuperview().dividedBy(2)
        }
    }
}
