//
//  DirectionCoreExt+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//


import UIKit
import CoreData

extension TrialCore: RemovableProtocol {}

extension TrialCore {
    public var trialDetails: Set<TrialDetail> {
        get {
            return self.trialDetails_ as! Set<TrialDetail>
        }
        set {
            self.trialDetails_ = newValue as NSSet
        }
    }
    
    public var title: String {
        get {
            return self.title_ ?? ""
        }
        set {
            self.title_ = newValue
        }
    }
    
    public var parentScreen: Screen {
        get {
            return self.parentScreen_!
        }
        set {
            self.parentScreen_ = newValue
        }
    }
    
    public var direction: String {
        get {
            return self.direction_ ?? "some"
        }
        set {
            self.direction_ = newValue
        }
    }
    
    public var finalResult: String {
        get {
            return convertScoreToString(score: self.latestScore, pain: self.latestWasPainful) ?? shortenDirection(direction: direction)
        }
    }
}

extension TrialCore {
    
    static func saveBundle(belongTo parent: Screen) {
        print("trialCore save has called")
        
        for (idx, each) in PositionList.allCases.enumerated() {
            if each.rawValue.contains("Var") { continue }
            TrialCore.save(title: each.rawValue, parent: parent, tag: Int64(idx))
            print("parent id : \(parent.id)")
        }
    }
    
    
    static func save(title: String, parent: Screen, tag: Int64) { // title 에 따른 direction 에 따라 1~2 개 return
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.trialCore, in: managedContext) else { fatalError() }
        
        
        // for loop needed..
        guard let positionName = PositionList(rawValue: title),
              let numOfDirections = Dummy.numOfDirections[positionName],
              let directionNames = Dummy.directionName[numOfDirections] else { fatalError() }
        
        for direction in directionNames {
            
            guard let trialCore = NSManagedObject(entity: entity, insertInto: managedContext) as? TrialCore else { fatalError() }

            trialCore.setValue(parent, forKey: .TrialCoreStr.parentScreen)
            trialCore.setValue(title, forKey: .TrialCoreStr.title)
            trialCore.setValue(direction, forKey: .TrialCoreStr.direction)
            trialCore.setValue(tag, forKey: .TrialCoreStr.tag)
            print("parent of TrialCore : \(trialCore.parentScreen)")
            print("title of TrialCore : \(trialCore.title)")
            print("direction of TrialCore : \(trialCore.direction)")
            parent.trialCores.update(with: trialCore)
            
            do {
                try managedContext.save()
            } catch {
                print("error : \(error.localizedDescription)")
                fatalError()
            }
        }
    }
}


extension TrialCore {
    
    func convertScoreToString(score: Int64, pain: Int64) -> String? {
        
        var result = ""
        
        // for Ankle Clearing, both score scales applied.
        if score != -1 {
            result += String(score)
        }
        
        if pain != 0 {
            result += pain > 0 ? "+" : "-"
        }

        return result != "" ? result : nil
    }
    
    func shortenDirection(direction: String) -> String {
//        switch direction {
//        case "Neutral": return "N"
//        case "Left": return "L"
//        case "Right": return "R"
//        }
        
        if direction != "" {
            return String(direction.first!)
        } else { return "N" }
    }
    
    
    func append(_ trialDetail: TrialDetail) {
        self.trialDetails.update(with: trialDetail)
    }
    
    /// delete trialDetail
    func delete(trialDetail: TrialDetail) {
        self.trialDetails.remove(trialDetail)
    }
    
    /// provide initial TrialDetail
    func startWithInitialTrial() {
        self.append(TrialDetail.save(belongTo: self))
    }
    
    // function to be called when score updated
    
    
    /// update Score
    func updateLatestScore() {
        var latestTrial: TrialDetail? = nil
        if self.trialDetails.count >= 2 {
            
            let lastElement = self.trialDetails.sorted {
                $0.trialNo < $1.trialNo
            }.last
            
            if lastElement != nil {
                latestTrial = lastElement!
            }
            
        } else if self.trialDetails.count == 1 {
            latestTrial = self.trialDetails.first!
        }
        
        guard let validLast = latestTrial else { return }
        self.latestScore = validLast.score == -1 ? -1 : validLast.score
    }
    
    func updateLatestPain() {
        var latestTrial: TrialDetail? = nil
        if self.trialDetails.count >= 2 {
            
            let lastElement = self.trialDetails.sorted {
                $0.trialNo < $1.trialNo
            }.last
            
            if lastElement != nil {
                latestTrial = lastElement!
            }
            
        } else if self.trialDetails.count == 1 {
            latestTrial = self.trialDetails.first!
        }
        
        guard let validLast = latestTrial else { return }
        self.latestWasPainful = validLast.score == 0 ? 0 : validLast.score
    }
}
