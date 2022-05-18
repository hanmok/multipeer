//
//  SelectableButtons.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit


class SelectableButton: UIButton, Identifiable { // has id
    public var id = UUID()
    public var title: String
    
    public var isSelected_: Bool {
        get {
            return self.isSelected
        }
        set {
            self.isSelected = newValue
            print("selected: \(title)")
        }
    }
    
    init(title: String, frame: CGRect = .zero) {
        self.title = title
        super.init(frame: frame)
        self.setupInitialTitle()
    }
    
    public func setBackgroundColor(to color: UIColor) {
        self.backgroundColor = color
    }
    // called from SelectableButtonStackView
    public func setupInitialColor(_ color: UIColor) {
        self.backgroundColor = color
    }
    
    private func setupInitialTitle() {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
    }
    
    public func setIsSelected(to isSelected: Bool) {
        self.isSelected_ = isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

