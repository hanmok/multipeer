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

class SelectableButton: UIButton, Identifiable { // has id
    var id = UUID()
    var title: String
    
    public var isSelected_: Bool {
        get {
            return self.isSelected
        }
        set {
            self.isSelected = newValue
        }
    }
    
    
    init(title: String, frame: CGRect = .zero) {
        self.title = title
        super.init(frame: frame)
        setupInitialColor()
//        addTarget(self, action: #selector(btnTaped), for: <#T##UIControl.Event#>)
    }
    
    public func setupInitialColor() {
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//class SelectableButtonGroup: UIView {
class SelectableButtonStackView: UIStackView {
    
    func addArrangedButton(_ btn: SelectableButton) {
        super.addArrangedSubview(btn)
        buttons.append(btn)
    }
    
    public var selectedWrapper: String = ""
    public var buttons: [SelectableButton] = []
    public var selectedBtnIndex: Int?
    
    private var selectedColor: UIColor
    private var defaultColor: UIColor
    
    private var prevPressedBtnId: UUID?
    private var currentPressedBtnId: UUID?
    
    public func buttonSelected(_ id: UUID) {
        prevPressedBtnId = currentPressedBtnId // both can be nil for the first selection
        
        for (index, button) in buttons.enumerated() {
            
            if button.id == id {
                currentPressedBtnId = id
                selectedBtnIndex = index
                button.backgroundColor = selectedColor
                button.isSelected_ = true
                selectedWrapper = button.title
            } else if let validPrev = prevPressedBtnId,
                      validPrev == button.id {
                button.backgroundColor = defaultColor
                button.isSelected_ = false
            }
        }
    }
    
    private func setupInitialColor(){
        for eachBtn in buttons {
            eachBtn.setupInitialColor()
        }
    }
    
    init(selectedColor: UIColor = .gray, defaultColor: UIColor = .black, spacing: CGFloat = 10,  frame: CGRect = .zero) {
        self.selectedColor = selectedColor
        self.defaultColor = defaultColor
        super.init(frame: frame)
        setupInitialColor()
        
        self.distribution = .fillEqually
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
