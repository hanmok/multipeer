//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/04.
//

import UIKit


class ScoreButton: SelectableButton {
    /// title of Button
    public var wrappedString: String {
    willSet {
        print("willSet triggered!")
            updateTitle(with: newValue)
        }
    }
    
    func updateTitle(with newValue: String) {
        self.title = newValue
        self.setTitle(newValue, for: .normal)
    }
    
    init(_ score: String = "") {
        self.wrappedString = score // is wrappedString triggered?
        super.init(title: score, frame: .zero)
        setupInitialLayout()
    }
    
    private func setupInitialLayout() {
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .black
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
