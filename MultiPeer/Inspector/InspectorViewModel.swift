//
//  ViewModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit


struct InspectorViewModel {
    private let inspector: Inspector
    
    public var inspectorName: String { return inspector.name }
    public var phoneNumber: String { return inspector.phoneNumber }
    
    init(inspector: Inspector) {
        self.inspector = inspector
    }
    
    private func calculateAge(from birthday: Date) -> Int {
        
        let calendar = Calendar.current
        let birthComponent = calendar.dateComponents([.year], from: birthday)
        let currentComponent = calendar.dateComponents([.year], from: Date())
        
        guard let birthYear = birthComponent.year,
              let currentYear = currentComponent.year else { return 0 }
        
        let age = currentYear - birthYear + 1
        
        return age
    }
    
    private func convertOptDateToString(_ date: Date?) -> String {
//        let date = Date()
        if let date = date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            return dateString
        } else {
            return ""
        }
    }
}
