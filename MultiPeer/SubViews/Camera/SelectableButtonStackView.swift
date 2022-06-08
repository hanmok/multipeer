//
//  SelectableButtonStackView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/18.
//


import UIKit


class SelectableButtonStackView: UIStackView {
    
    private var selectedColor: UIColor
    private var defaultColor: UIColor
    
    private var prevSelectedBtnId: UUID?
    private var currentSelectedBtnId: UUID?
    
    
    public var selectedBtnTitle: String = ""
    public var buttons: [SelectableButton] = []
    
    public var selectedBtnIndex: Int? {
        willSet {
            print("selectedBtnIndex: \(newValue)")
        }
    }
    
    /// add SelectableButton to self
    public func addArrangedButton(_ btn: SelectableButton) {
        super.addArrangedSubview(btn)
        buttons.append(btn)
        btn.setupInitialColor(defaultColor)
    }
    
    
    public func setSelectedButton(_ id: UUID?) {
        guard let id = id else {
            for button in buttons {
                if button.id == currentSelectedBtnId {
                    button.setBackgroundColor(to: defaultColor)
                }
            }
            
            currentSelectedBtnId = nil
            return
        }
        
        prevSelectedBtnId = currentSelectedBtnId // both can be nil for the first selection
        
        for (index, button) in buttons.enumerated() {
            
            
            if button.id == id {
                currentSelectedBtnId = id
                selectedBtnIndex = index
                
                button.setBackgroundColor(to: selectedColor)
                button.setIsSelected(to: true)
                
                selectedBtnTitle = button.title
                
            } else if let validPrev = prevSelectedBtnId,
                      validPrev == button.id {
                
                button.setBackgroundColor(to: defaultColor)
                button.setIsSelected(to: false)
            }
        }
    }
    
    
    
    init(
        selectedColor: UIColor = .gray,
//        defaultColor: UIColor = .black,
        defaultColor: UIColor = .lavenderGray300,
        spacing: CGFloat = 10, frame: CGRect = .zero) {
            
            self.selectedColor = selectedColor
            self.defaultColor = defaultColor
            
            super.init(frame: frame)
            
            setupSubBtnColor()
            setupInitialLayout()
        }
    
    private func setupSubBtnColor(){
        for eachBtn in buttons {
            eachBtn.setupInitialColor(defaultColor)
        }
    }
    
    private func setupInitialLayout() {
        self.distribution = .fillEqually
        self.spacing = spacing
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
