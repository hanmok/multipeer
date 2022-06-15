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
        //    private let completeMsgLabel = UITextView().then {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrText = NSMutableAttributedString(string: "Upload Completed\n", attributes: [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
//            .foregroundColor: UIColor.gray900,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph]
        )
        
        attrText.append(NSAttributedString(string: "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 10)
        ]))
        
        attrText.append(NSAttributedString(string: "Congrats!\n Video has been successfully uploaded.", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray600,
            .paragraphStyle: paragraph]))
        
        
        $0.attributedText = attrText
        $0.numberOfLines = 0
        
        $0.backgroundColor = .blue
        
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = false
        $0.layer.shadowRadius = 5
        $0.layer.shadowOpacity = 1.0
//        $0.layer.shadowOffset = CGSize(width: 10, height: 10)
        $0.layer.shadowOffset = CGSize(width: -10, height: -10)
        // width direction: 
        $0.layer.shadowColor = UIColor.green.cgColor
//        $0.layer.shadow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(completeMsgLabel)
        completeMsgLabel.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.height.width.equalToSuperview().dividedBy(2)
        }
    }
    
    
}
