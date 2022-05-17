//
//  SelectableButtons.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit


class SelectableButton: UIButton, Identifiable { // has id
    var id = UUID()
    var title: String
    
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
    
    public func setupInitialColor(_ color: UIColor) {
        self.backgroundColor = color
    }
    
    private func setupInitialTitle() {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
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
        btn.setupInitialColor(defaultColor)
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
            eachBtn.setupInitialColor(defaultColor)
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
