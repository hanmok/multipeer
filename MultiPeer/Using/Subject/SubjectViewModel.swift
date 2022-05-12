//
//  ViewModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit


struct SubjectViewModel {
    private let subject: Subject
    
    public var subjectName: String { return subject.name }
    public var phoneNumber: String { return subject.phoneNumber }
    public var imageUrl: URL? { return URL(string: subject.imageUrl ?? "") } // 없으면 nil
    public var gender: String { return subject.isMale ? "남" : "여" }
    public var birth: Date { return subject.birthday }
    public var lastUpdatedAt: String { return convertOptDateToString(subject.lastUpdateDate)}
    public var numOfTestConducted: String { return String(subject.numOfTestConducted)}
    public var age: String { return String(calculateAge(from: subject.birthday))}
    
    init(subject: Subject) {
        self.subject = subject
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
