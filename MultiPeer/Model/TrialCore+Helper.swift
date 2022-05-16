//
//  DirectionCoreExt+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//


import UIKit
import CoreData



extension TrialCore {
    public var trialDetails: Set<TrialDetail> {
        get {
            return self.trialsDetails_ as! Set<TrialDetail>
        }
        set {
            self.trialsDetails_ = newValue as NSSet
        }
    }
    
    public var parentPositionTitle: PositionTitleCore {
        get {
            return parentPositionTitle_!
        }
        set {
            self.parentPositionTitle_ = newValue
        }
    }
    
    public var title: String {
        get {
            return self.parentPositionTitle.title
        }
    }
}

extension TrialCore {
    
    @discardableResult
    static func save(belongTo parent: PositionTitleCore) -> [TrialCore] {
        print("trialCore save has called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("fail to cast to appDelegate")
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.trialCore, in: managedContext) else {fatalError()}
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)

        var trialCores: [TrialCore] = []

        guard let positionFromList = PositionList(rawValue: parent.title),
              let numOfDirections = Dummy.numOfDirections[positionFromList],
              let directions = Dummy.directionName[numOfDirections] else { fatalError("") }

        for direction in directions {
    
            guard let trialCore = managedObject as? TrialCore else {
                fatalError("downcasting has failed! ")
            }
            trialCore.setValue(direction, forKey: .TrialCoreStr.direction)
            trialCore.setValue(parent, forKey: .TrialCoreStr.parentPositionTitle)
            
            trialCore.startWithInitialTrial()
            
            do {
                try managedContext.save()
                print("successfully saved ! \(String(describing: trialCore.direction))")
                trialCores.append(trialCore)
            } catch let error as NSError {
                print("Could not save, \(error), \(error.userInfo)")
                fatalError("faield to save !")
            }
        }
      
        return trialCores
    }
}


extension TrialCore {
    
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
