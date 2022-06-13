//
//  SelectableButtonStackView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/18.
//


import UIKit


class DirectionStackView: UIStackView {
    
    private var selectedBGColor: UIColor
    private var defaultBGColor: UIColor
    
    private var selectedTitleColor: UIColor
    private var defaultTitleColor: UIColor
    
    private var prevSelectedBtnId: UUID?
    private var currentSelectedBtnId: UUID?
    
    public var selectedBtnTitle: String = ""
    
    public var buttons: [DirectionBtnView] = []
    
    public var selectedBtnIndex: Int?
    
    
    // MARK: - Life Cycle
    init(
        selectedBGColor: UIColor = .purple500,
        defaultBGColor: UIColor = .lavenderGray300,
        selectedTitleColor: UIColor = .white,
        defaultTitleColor: UIColor = .gray900,
        spacing: CGFloat = 16,
        cornerRadius: CGFloat = 0,
        frame: CGRect = .zero) {
            
            self.selectedBGColor = selectedBGColor
            self.defaultBGColor = defaultBGColor
            
            self.selectedTitleColor = selectedTitleColor
            self.defaultTitleColor = defaultTitleColor

            super.init(frame: frame)

            self.spacing = spacing

            self.layer.cornerRadius = cornerRadius
            setupSubBtnBGColor()
            setupInitialLayout()
        }
    
    /// add SelectableButton to self
    public func addArrangedButton(_ btn: DirectionBtnView) {
        super.addArrangedSubview(btn)
        buttons.append(btn)
        btn.backgroundColor = defaultBGColor
        
    }
    
    public func selectBtnAction(selected id: UUID?) {
        print("selectBtnAction called")
        guard let id = id else {
            for button in buttons {
                if button.id == currentSelectedBtnId {
                    
                    button.changeBtnColor(bgColor: defaultBGColor, titleColor: defaultTitleColor)
                }
            }
            
            currentSelectedBtnId = nil
            return
        }
        
        // both can be nil for the first selection
        prevSelectedBtnId = currentSelectedBtnId
        
        for (index, button) in buttons.enumerated() {
            
            if button.id == id {
                currentSelectedBtnId = id
                selectedBtnIndex = index
                
                button.changeBtnColor(bgColor: selectedBGColor, titleColor: selectedTitleColor)
                
                button.setIsSelected(to: true)
                
                selectedBtnTitle = button.title
                
            } else if let validPrev = prevSelectedBtnId,
                      validPrev == button.id {
                
                button.changeBtnColor(bgColor: defaultBGColor, titleColor: defaultTitleColor)
                
                button.setIsSelected(to: false)
            }
        }
    }
    
    public func setSelectedBtnNone() {
        prevSelectedBtnId = nil
        currentSelectedBtnId = nil
        
        for button in buttons {
            button.changeBtnColor(bgColor: defaultBGColor, titleColor: defaultTitleColor)
        }
    }
    
    private func setupSubBtnBGColor(){
        for eachBtn in buttons {
            eachBtn.backgroundColor = defaultBGColor
        }
    }
    
    private func setupInitialLayout() {
        self.distribution = .fillEqually
        self.spacing = spacing
//        self.distribution = .equalSpacing
//        self.distribution = .equalCentering
        
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
