////
////  TrialCoreCopy.swift
////  MultiPeer
////
////  Created by 핏투비 iOS on 2022/05/19.
////
//
//import Foundation
//
//
////
////  DirectionCoreExt+.swift
////  MultiPeer
////
////  Created by 핏투비 iOS on 2022/05/13.
////
//
//
//import UIKit
//import CoreData
//
//extension TrialCore: RemovableProtocol {}
//
//extension TrialCore {
//    public var trialDetails: Set<TrialDetail> {
//        get {
//            return self.trialDetails_ as? Set<TrialDetail> ?? [] // 왜 여기서... ??
//        }
//        set {
//            self.trialDetails_ = newValue as NSSet
//        }
//    }
//    
//    public var title: String {
//        get {
//            return self.title_ ?? ""
//        }
//        set {
//            self.title_ = newValue
//        }
//    }
//    
//    public var parentScreen: Screen {
//        get {
//            return self.parentScreen_!
//        }
//        set {
//            self.parentScreen_ = newValue
//        }
//    }
//    
//    public var direction: String {
//        get {
//            return self.direction_ ?? "some"
//        }
//        set {
//            self.direction_ = newValue
//        }
//    }
//    
//    public var finalResult: String {
//        get {
//            return self.finalResult_ ?? ""
//        }
//        set {
//            self.finalResult_ = newValue
//        }
//    }
//}
//
//extension TrialCore {
//    
//    static func saveBundle(belongTo parent: Screen) {
//        // 여기 어딘가에서 에러 발생
//        for (idx, each) in PositionList.allCases.enumerated() {
//
//            if each.rawValue.contains("Var") { continue }
//            // 여기에서 발생.
//            TrialCore.save(title: each.rawValue, parent: parent, tag: Int64(idx))
//        }
//    }
//    
//    // Error 발생지.. 여기 아님. 정상출력됨.
//    static func save(title: String, parent: Screen, tag: Int64) { // title 에 따른 direction 에 따라 1~2 개 return
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("error !! flag 2")
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        guard let entity = NSEntityDescription.entity(forEntityName: .CoreEntitiesStr.trialCore, in: managedContext) else { fatalError("error !! flag 3") }
//        
//        // for loop needed..
//        guard let positionName = PositionList(rawValue: title),
//              let numOfDirections = Dummy.numOfDirections[positionName],
//              let directionNames = Dummy.directionName[numOfDirections] else { fatalError("error !! flag 4") }
//        
//        for direction in directionNames {
//            guard let trialCore = NSManagedObject(entity: entity, insertInto: managedContext) as? TrialCore else { fatalError("error !! flag 5") }
//
//            trialCore.setValue(parent, forKey: .TrialCoreStr.parentScreen)
//            trialCore.setValue(title, forKey: .TrialCoreStr.title)
//            trialCore.setValue(direction, forKey: .TrialCoreStr.direction)
//            trialCore.setValue(tag, forKey: .TrialCoreStr.tag)
//            print("parent of TrialCore : \(trialCore.parentScreen)")
//            print("title of TrialCore : \(trialCore.title)")
//            print("direction of TrialCore : \(trialCore.direction)")
//            parent.trialCores.update(with: trialCore)
//            do {
//                try managedContext.save()
//            } catch {
//                print("error : \(error.localizedDescription)")
//                fatalError("error !! flag 6")
//            }
//        }
//    }
//    
//     func returnFreshTrialDetail() -> TrialDetail {
//         
//         let sortedDetails = self.trialDetails.sorted { $0.trialNo < $1.trialNo }
//         
//         if sortedDetails.count != 0 {
//             guard let lastDetailElement = sortedDetails.last else { fatalError() }
//             guard let positionTitle = PositionList(rawValue: self.title) else { fatalError() }
//             
//             switch positionTitle {
//             
//             case .ankleClearing:
//                 return returnAvailableDetail(
//                     condition: lastDetailElement.isPainful == .DefaultValue.trialPain || lastDetailElement.score == .DefaultValue.trialScore,
//                     lastElement: lastDetailElement, to: self)
//             
//             case .flexionClearing, .shoulderClearing, .extensionClearing :
//                 return returnAvailableDetail(condition: lastDetailElement.isPainful == .DefaultValue.trialPain,
//                              lastElement: lastDetailElement, to: self)
//             
//             default:
//                 return returnAvailableDetail(condition: lastDetailElement.score == .DefaultValue.trialScore, lastElement: lastDetailElement, to: self)
//             }
//         } else {
//             return createDetail(core: self)
//         }
//    }
//    
//    func returnAvailableDetail(condition:Bool, lastElement: TrialDetail, to trialCore: TrialCore) -> TrialDetail {
//        return condition ? lastElement : createDetail(core: trialCore)
//    }
//    
//    func createDetail(core: TrialCore) -> TrialDetail{
//        let numOfDetails = core.trialDetails.count
//        return TrialDetail.save(belongTo: core, trialNo: numOfDetails)
//    }
//    
//    func updateLatestScore() {
//        // inverse order
//        var toConsider: ToConsiderEnum = .score
//        
//        let details = self.trialDetails.sorted { $0.trialNo > $1.trialNo }
//        
//        for eachDetail in details {
//            guard let name = PositionList(rawValue: self.title) else { fatalError("")}
//            switch name {
//            case .ankleClearing:
//                if eachDetail.isPainful == .DefaultValue.trialPain || eachDetail.score == .DefaultValue.trialScore {
//                    continue
//                } else { toConsider = .both }
//                
//            case .flexionClearing, .shoulderClearing, .extensionClearing :
//                if eachDetail.isPainful == .DefaultValue.trialPain {
//                    continue
//                } else { toConsider = .pain }
//                
//            default:
//                if eachDetail.score == .DefaultValue.trialScore {
//                    continue
//                } else { toConsider = .score }
//            }
//            
//            switch toConsider {
//            case .score:
//                self.latestScore = eachDetail.score
//                self.finalResult = String(eachDetail.score)
//            case .pain:
//                self.latestWasPainful = eachDetail.isPainful
//                self.finalResult = eachDetail.isPainful == 1 ? "+" : "-"
//            case .both:
//                self.latestScore = eachDetail.score
//                self.latestWasPainful = eachDetail.isPainful
//                self.finalResult = String(eachDetail.score)
//                self.finalResult += eachDetail.isPainful == 1 ? "+" : "-"
//            }
//            
//            print("updated LatestScore: \(self.latestScore)")
//            print("updated pain : \(self.latestWasPainful)")
//            
//            break
//        }
//    }
//}
//
//enum ToConsiderEnum {
//    case score
//    case pain
//    case both
//}
//
//
//extension TrialCore {
//    
////    func convertScoreToString(score: Int64, pain: Int64) -> String? {
////
////        var result = ""
////
////        // for Ankle Clearing, both score scales applied.
////        if score != -1 {
////            result += String(score)
////        }
////
////        if pain != 0 {
////            result += pain > 0 ? "+" : "-"
////        }
////
////        return result != "" ? result : nil
////    }
//    
//    func shortenDirection(direction: String) -> String {
////        switch direction {
////        case "Neutral": return "N"
////        case "Left": return "L"
////        case "Right": return "R"
////        }
//        
//        if direction != "" {
//            return String(direction.first!)
//        } else { return "N" }
//    }
//    
//    
//    func append(_ trialDetail: TrialDetail) {
//        self.trialDetails.update(with: trialDetail)
//    }
//    
//    /// delete trialDetail
//    func delete(trialDetail: TrialDetail) {
//        self.trialDetails.remove(trialDetail)
//    }
//    
//    /// provide initial TrialDetail
//    func startWithInitialTrial() {
//        self.append(TrialDetail.save(belongTo: self))
//    }
//    
//    // function to be called when score updated
//    
//    
//    /// update Score
////    func updateLatestScore() {
////        var latestTrial: TrialDetail?
////        if self.trialDetails.count >= 2 {
////
////            let lastElement = self.trialDetails.sorted {
////                $0.trialNo < $1.trialNo
////            }.last
////
////            if lastElement != nil {
////                latestTrial = lastElement!
////            }
////
////        } else if self.trialDetails.count == 1 {
////            latestTrial = self.trialDetails.first!
////        }
////
////        guard let validLast = latestTrial else { return }
////        self.latestScore = validLast.score == -1 ? -1 : validLast.score
////    }
//    
////    func updateLatestPain() {
////        var latestTrial: TrialDetail? = nil
////        if self.trialDetails.count >= 2 {
////
////            let lastElement = self.trialDetails.sorted {
////                $0.trialNo < $1.trialNo
////            }.last
////
////            if lastElement != nil {
////                latestTrial = lastElement!
////            }
////
////        } else if self.trialDetails.count == 1 {
////            latestTrial = self.trialDetails.first!
////        }
////
////        guard let validLast = latestTrial else { return }
////        self.latestWasPainful = validLast.score == 0 ? 0 : validLast.score
////    }
//}
//
//
//
//
//
//
//
//
//// prev
//
//public var finalResult: String {
//    get { // 이게 잘못된 것 같은데 ??
//        return convertScoreToString(score: self.latestScore, pain: self.latestWasPainful) ?? shortenDirection(direction: direction)
//    }
//}
//
//
////    func convertScoreToString(score: Int64, pain: Int64) -> String? {
////
////        var result = ""
////
////        // for Ankle Clearing, both score scales applied.
////        if score != -1 {
////            result += String(score)
////        }
////
////        if pain != 0 {
////            result += pain > 0 ? "+" : "-"
////        }
////
////        return result != "" ? result : nil
////    }
//
//
//func shortenDirection(direction: String) -> String {
////        switch direction {
////        case "Neutral": return "N"
////        case "Left": return "L"
////        case "Right": return "R"
////        }
//    
//    if direction != "" {
//        return String(direction.first!)
//    } else { return "N" }
//}