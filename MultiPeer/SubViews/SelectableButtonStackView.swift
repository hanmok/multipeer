//
//  SelectableButtonStackView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/18.
//


import UIKit


class SelectableButtonStackView: UIStackView {
    
    private var selectedBGColor: UIColor
    private var defaultBGColor: UIColor
    
    private var selectedTitleColor: UIColor
    private var defaultTitleColor: UIColor
    
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
        btn.setupInitialColor(defaultBGColor)
    }
    
    
    public func setSelectedButton(_ id: UUID?) {
        guard let id = id else {
            for button in buttons {
                if button.id == currentSelectedBtnId {
                    button.setBackgroundColor(to: defaultBGColor)
                    button.setTitleColor(to: defaultTitleColor)
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
                
                button.setBackgroundColor(to: selectedBGColor)
                button.setTitleColor(to: selectedTitleColor)
                
                button.setIsSelected(to: true)
                
                selectedBtnTitle = button.title
                
            } else if let validPrev = prevSelectedBtnId,
                      validPrev == button.id {
                
                button.setBackgroundColor(to: defaultBGColor)
                button.setTitleColor(to: defaultTitleColor)
                button.setIsSelected(to: false)
            }
        }
    }
    
    
    
    init(
//        selectedColor: UIColor = .gray,
        selectedBGColor: UIColor = .purple500,
        defaultBGColor: UIColor = .lavenderGray300,
        selectedTitleColor: UIColor = .white,
        defaultTitleColor: UIColor = .gray900,
        spacing: CGFloat = 16, frame: CGRect = .zero) {
            
            self.selectedBGColor = selectedBGColor
            self.defaultBGColor = defaultBGColor
            
            self.selectedTitleColor = selectedTitleColor
            self.defaultTitleColor = defaultTitleColor

            super.init(frame: frame)
            
            setupSubBtnBGColor()
            setupInitialLayout()
        }
    
    private func setupSubBtnBGColor(){
        for eachBtn in buttons {
            eachBtn.setupInitialColor(defaultBGColor)
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
