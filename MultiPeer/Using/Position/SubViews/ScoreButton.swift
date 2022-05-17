//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/04.
//

import UIKit
import Then

class ScoreButton: SelectableButton {
    
    public var wrappedString: String {
        didSet {
            setupLayout()
        }
        willSet {
            updateTitle(with: newValue)
        }
    }
    
    func updateTitle(with newValue: String) {
        self.title = newValue
    }
    
    init(_ score: String = "") {
        self.wrappedString = score
        super.init(title: score, frame: .zero)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
    }
    
    private func setupLayout() {
        self.setTitle(wrappedString, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
