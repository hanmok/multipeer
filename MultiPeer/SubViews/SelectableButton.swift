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

        self.setTitle(title, for: .normal)
        self.setTitleColor(.black, for: .normal)
    }
        
    public func changeBtnColor(bgColor: UIColor, titleColor: UIColor) {
        self.backgroundColor = bgColor
        self.setTitleColor(titleColor, for: .normal)
    }
           
    public func setIsSelected(to isSelected: Bool) {
        self.isSelected_ = isSelected
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
