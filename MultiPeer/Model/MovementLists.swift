//
//  PositionLists.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation

// MARK: - Position
enum MovementList: String, CaseIterable {
    case deepSquat = "Deep Squat"
    case deepSquatVar = "Deep Squat Var"
    case hurdleStep = "Hurdle Step"
    case inlineLunge = "Inline Lunge"
    case ankleClearing = "Ankle Clearing"
    case shoulderMobility = "Shoulder Mobility"
    case shoulderClearing = "Shoulder Clearing"
    case activeStraightLegRaise = "Active Straight-LegRaise"
    case trunkStabilityPushUp = "Trunk Stability Push-up"
    case trunkStabilityPushUpVar = "Trunk Stability Push-up Var"
    case extensionClearing = "Extension Clearing"
    case rotaryStability = "Rotary Stability"
    case flexionClearing = "Flexion Clearing"
}

enum MovementListWithoutVars: String, CaseIterable {
    case deepSquat = "Deep Squat"
//    case deepSquatVar = "Deep Squat Var"
    case hurdleStep = "Hurdle Step"
    case inlineLunge = "Inline Lunge"
    case ankleClearing = "Ankle Clearing"
    case shoulderMobility = "Shoulder Mobility"
    case shoulderClearing = "Shoulder Clearing"
    case activeStraightLegRaise = "Active Straight-LegRaise"
    case trunkStabilityPushUp = "Trunk Stability Push-up"
//    case trunkStabilityPushUpVar = "Trunk Stability Push-up Var"
    case extensionClearing = "Extension Clearing"
    case rotaryStability = "Rotary Stability"
    case flexionClearing = "Flexion Clearing"
}

enum ScoreViewSize {
    case small
    case large
    case none
}



//let ClearingTitleHasNoDirection: [MovementList: Int] = [
//    MovementList.ankleClearing: 2,
//    MovementList.shoulderClearing: 2,
//    movement
//]

let clearingTitleWithOneDirection: [MovementList] = [.extensionClearing, .flexionClearing]


// Make positionList accessable using Index

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}

enum MovementDirectionList: String {
    case left = "Left"
    case right = "Right"
    case neutral = "Neutral"
}

struct Dummy {
    
    static func getPainTestName(from title: String, direction: MovementDirection) -> String? {
        var painTest: String? = nil
        
        painTest =  movementWithPainTestTitle[title]
        
        if painTest != nil {
            if title == MovementList.rotaryStability.rawValue && direction.rawValue == MovementDirectionList.left.rawValue {
                
                painTest = nil
            }
        }
        
        return painTest
    }
    
    static let shortMovementName: [String: String] = [
        MovementList.deepSquat.rawValue: "ds",
        MovementList.deepSquatVar.rawValue: "dsv",
        MovementList.hurdleStep.rawValue: "hs",
        MovementList.inlineLunge.rawValue: "il",
        MovementList.ankleClearing.rawValue: "ac",
        MovementList.shoulderMobility.rawValue: "sm",
        MovementList.shoulderClearing.rawValue: "sc",
        MovementList.activeStraightLegRaise.rawValue: "aslr",
        MovementList.trunkStabilityPushUp.rawValue: "tspu",
        MovementList.trunkStabilityPushUpVar.rawValue: "tspuv",
        MovementList.extensionClearing.rawValue: "ec",
        MovementList.rotaryStability.rawValue: "rs",
        MovementList.flexionClearing.rawValue: "fc"
    ]
    
    
    
    static let directionName: [Int: [String]] = [1: ["Neutral"], 2: ["Left", "Right"]]
    
    static let numOfDirections: [MovementList: Int] = [
        .deepSquat : 1,
        .deepSquatVar : 1,
        .hurdleStep:2,
        .inlineLunge:2,
        .ankleClearing: 2,
        .shoulderMobility:2,
        .shoulderClearing:2,
        .activeStraightLegRaise:2,
        .trunkStabilityPushUp:1,
        .trunkStabilityPushUpVar:1,
        .extensionClearing:1,
        .rotaryStability:2,
        .flexionClearing:1
    ]
    
    static let shortName: [String: String] = [
        MovementList.deepSquat.rawValue: "DS",
        MovementList.deepSquatVar.rawValue: "DS",
        MovementList.hurdleStep.rawValue: "HS",
        MovementList.inlineLunge.rawValue: "IL",
        MovementList.ankleClearing.rawValue: "AC",
        MovementList.shoulderMobility.rawValue: "SM",
        MovementList.activeStraightLegRaise.rawValue: "ASLR",
        MovementList.trunkStabilityPushUp.rawValue: "TSPU",
        MovementList.trunkStabilityPushUpVar.rawValue: "TSPU",
        MovementList.rotaryStability.rawValue: "RS"
    ]
    
    enum MovementsShowing: String, CaseIterable {
        case deepSquat = "DS"
        case hurdleStep = "HS"
        case inlineLunge = "IL"
        case ankleClearing = "AC"
        case shoulderMobility = "SM"
        case activeStraightLegRaise = "ASLR"
        case trunkStabilityPushUp = "TSPU"
        case rotaryStability = "RS"
    }
}

let MovementsHasPain: [String: String] = [
    MovementList.ankleClearing.rawValue: MovementList.ankleClearing.rawValue,
    MovementList.shoulderMobility.rawValue: MovementList.shoulderClearing.rawValue,
    MovementList.trunkStabilityPushUp.rawValue: MovementList.extensionClearing.rawValue,
    MovementList.trunkStabilityPushUpVar.rawValue: MovementList.extensionClearing.rawValue,
    MovementList.rotaryStability.rawValue: MovementList.flexionClearing.rawValue
]




enum MovementImgs {
    
    static let deepSquat = (title: MovementList.deepSquat.rawValue, imageNames: ["deepSquat"])
    static let hurdleStep = (title: MovementList.hurdleStep.rawValue, imageNames: ["hurdleStepLeft", "hurdleStepRight"])
    static let inlineLunge = (title: MovementList.inlineLunge.rawValue, imageNames: ["inlineLungeLeft","inlineLungeRight"])
    static let ankleClearing = (title: MovementList.ankleClearing.rawValue, imageNames: ["ankleClearingLeft","ankleClearingRight"])
    
    static let shoulderMobility = (title: MovementList.shoulderMobility.rawValue, imageNames: ["shoulderMobilityLeft", "shoulderMobilityRight"])
    static let shoulderClearing = (title: MovementList.shoulderClearing.rawValue, imageNames: ["shoulderClearingLeft", "shoulderClearingRight"])
    static let straightLegRaise = (title: MovementList.activeStraightLegRaise.rawValue, imageNames: ["activeStraightLegRaiseLeft", "activeStraightLegRaiseRight"])
    
    static let stabilityPushup = (title: MovementList.trunkStabilityPushUp.rawValue, imageNames: ["trunkStabilityPushup"])
    static let extensionClearing = (title: MovementList.extensionClearing.rawValue, imageNames: ["extensionClearing"])
    static let rotaryStability = (title: MovementList.rotaryStability.rawValue, imageNames: ["rotaryStabilityLeft","rotaryStabilityRight"])
    static let flexionClearing = (title: MovementList.flexionClearing.rawValue, imageNames: ["flexionClearing"])
}


enum MovementWithImageListEnum {
    static let deepsquat = PositionInfo(title: MovementImgs.deepSquat.0,
                                         imageName: [MovementImgs.deepSquat.imageNames[0]])
    
    static let hurdleStep = PositionInfo(title: MovementImgs.hurdleStep.0,
                                          imageName: [MovementImgs.hurdleStep.imageNames[0],
                                                      MovementImgs.hurdleStep.imageNames[1]])
    
    static let inlineLunge = PositionInfo(title: MovementImgs.inlineLunge.0,
                                           imageName: [MovementImgs.inlineLunge.imageNames[0],
                                                       MovementImgs.inlineLunge.imageNames[1]])
    
    static let ankleClearing = PositionInfo(title: MovementImgs.ankleClearing.0,
                                           imageName: [MovementImgs.ankleClearing.imageNames[0],
                                                       MovementImgs.ankleClearing.imageNames[1]])
    
    
    
    static let shoulderMobility = PositionInfo(title: MovementImgs.shoulderMobility.0,
                                                imageName: [MovementImgs.shoulderMobility.imageNames[0],
                                                            MovementImgs.shoulderMobility.imageNames[1]])
    static let shoulderClearing = PositionInfo(title: MovementImgs.shoulderClearing.0,
                                        imageName: [MovementImgs.shoulderClearing.imageNames[0],
                                                    MovementImgs.shoulderClearing.imageNames[1]])
    static let straightLegRaise = PositionInfo(title: MovementImgs.straightLegRaise.0,
                                                imageName: [MovementImgs.straightLegRaise.imageNames[0],
                                                            MovementImgs.straightLegRaise.imageNames[1]])
    
    static let stabilityPushup = PositionInfo(title: MovementImgs.stabilityPushup.0,
                                               imageName: [MovementImgs.stabilityPushup.imageNames[0]])
    static let extensionClearing = PositionInfo(title: MovementImgs.extensionClearing.0,
                                          imageName: [MovementImgs.extensionClearing.imageNames[0]])
    static let rotaryStability = PositionInfo(title: MovementImgs.rotaryStability.0,
                                               imageName:[MovementImgs.rotaryStability.imageNames[0],
                                                          MovementImgs.rotaryStability.imageNames[1]])
    static let flexionClearing = PositionInfo(title: MovementImgs.flexionClearing.0, imageName:
                                        [MovementImgs.flexionClearing.imageNames[0]])
}

// Clearing 제외한 상태. 변수 이름 변경 필요.
let  MovementImgsDictionary: [String: [String]] = [
    MovementList.deepSquat.rawValue: ["deepSquat"],
    MovementList.hurdleStep.rawValue: ["hurdleStepLeft", "hurdleStepRight"],
    MovementList.inlineLunge.rawValue: ["inlineLungeLeft","inlineLungeRight"],
    MovementList.ankleClearing.rawValue: ["ankleClearingLeft","ankleClearingRight"],
    MovementList.shoulderMobility.rawValue: ["shoulderMobilityLeft", "shoulderMobilityRight"],
    MovementList.activeStraightLegRaise.rawValue: ["activeStraightLegRaiseLeft", "activeStraightLegRaiseRight"],
    MovementList.trunkStabilityPushUp.rawValue: ["trunkStabilityPushup"],
    MovementList.rotaryStability.rawValue: ["rotaryStabilityLeft","rotaryStabilityRight"]
]

let  MovementImgsDictionaryWithVars: [String: [String]] = [
    MovementList.deepSquat.rawValue: ["deepSquat"],
    MovementList.deepSquatVar.rawValue: ["deepSquat"],
    MovementList.hurdleStep.rawValue: ["hurdleStepLeft", "hurdleStepRight"],
    MovementList.inlineLunge.rawValue: ["inlineLungeLeft","inlineLungeRight"],
    MovementList.ankleClearing.rawValue: ["ankleClearingLeft","ankleClearingRight"],
    MovementList.shoulderMobility.rawValue: ["shoulderMobilityLeft", "shoulderMobilityRight"],
    MovementList.activeStraightLegRaise.rawValue: ["activeStraightLegRaiseLeft", "activeStraightLegRaiseRight"],
    MovementList.trunkStabilityPushUp.rawValue: ["trunkStabilityPushup"],
    MovementList.trunkStabilityPushUpVar.rawValue: ["trunkStabilityPushup"],
    MovementList.rotaryStability.rawValue: ["rotaryStabilityLeft","rotaryStabilityRight"]
    
]



// 위, 아래가 중복 데이터임. ;; 어.. 어떤 형태로 사용할 지 정해주는게 좋을 것 같은데 ??
// 현재 안쓰는중
public enum MovementWithPainEnum: String {
    case ankleClearing = "Ankle Clearing"
    case shoulderClearing = "Shoulder Clearing"
    case extensionClearing = "Extension Clearing"
    case flexionClearing = "Flexion Clearing"
}

//public let movementWithPainNoAnkle = [
//    MovementList.shoulderClearing.rawValue,
//    MovementList.flexionClearing.rawValue,
//    MovementList.extensionClearing.rawValue
//]

public let movementWithPain = [
    MovementList.ankleClearing.rawValue,
    MovementList.shoulderClearing.rawValue,
    MovementList.flexionClearing.rawValue,
    MovementList.extensionClearing.rawValue
]

// 둘중 하나는 없애는게 ..
// 이것도 안쓰고있음.
public let movementsHasPain = [
    MovementList.ankleClearing.rawValue,
    MovementList.shoulderClearing.rawValue,
    MovementList.flexionClearing.rawValue,
    MovementList.extensionClearing.rawValue
]

public let movementWithPainTestTitle: [String: String] = [
    MovementList.ankleClearing.rawValue : MovementList.ankleClearing.rawValue,
    MovementList.shoulderMobility.rawValue: MovementList.shoulderClearing.rawValue,
    MovementList.trunkStabilityPushUp.rawValue: MovementList.extensionClearing.rawValue,
    MovementList.trunkStabilityPushUpVar.rawValue: MovementList.extensionClearing.rawValue,
    MovementList.rotaryStability.rawValue: MovementList.flexionClearing.rawValue
]

public let movementWithVariation: [String: String] = [
    MovementList.deepSquat.rawValue : MovementList.deepSquatVar.rawValue,
    MovementList.trunkStabilityPushUp.rawValue: MovementList.trunkStabilityPushUpVar.rawValue
]



// MARK: - Score

public enum ScoreType {
    case zeroThreeHold
    case zeroToThree
    case zeroToTwo
    case painOrNot
    case RYG
}

let movementNameToScoreType: [String: ScoreType] = [
    MovementList.deepSquat.rawValue: .zeroThreeHold,
    MovementList.deepSquatVar.rawValue: .zeroToTwo,
    
    MovementList.hurdleStep.rawValue: .zeroToThree,
    MovementList.inlineLunge.rawValue: .zeroToThree,

    MovementList.ankleClearing.rawValue: .RYG,
//        PositionList.ankleClearing.rawValue: .RGB,
    
    MovementList.shoulderMobility.rawValue: .zeroToThree,
//        PositionList.shoulderClearing.rawValue: .painOrNot,
    
    MovementList.activeStraightLegRaise.rawValue: .zeroToThree,
    
    MovementList.trunkStabilityPushUp.rawValue: .zeroThreeHold,
    MovementList.trunkStabilityPushUpVar.rawValue: .zeroToTwo,
//        PositionList.extensionClearing.rawValue: .painOrNot,
    
    MovementList.rotaryStability.rawValue: .zeroToThree,
//        PositionList.flexionClearing.rawValue: .painOrNot
]


enum CameraAngleEnum: String, CaseIterable {
    case front
    case between
    case side
}


enum Rank: String {
    case boss
    case follower
}






enum FlagType: String {
    case updatingTrialCore
    case defaultSubjectScreen
    case printingSequence
    case printingScoresFromCell
    case rsBug
    case durationBug
    case peerConnectivity
    case peerRequest
    case upperIndex
}

/// left, right, both
enum connectedDeviceAmount {
    case zero
    case one
//    case right
    case two
}

enum RecordingMode {
    case onRecording
    case onPreparing
//    case onPreparing
}

//let countToSideDic: [Int: connectedDeviceAmount?] = [0: nil, 1: .one, 2: .two]
let countToSideDic: [Int: connectedDeviceAmount] = [0: .zero, 1: .one, 2: .two]


struct PostReqInfo: Codable {
    var subjectName: String

    var screenId: UUID
    var title: String
    var direction: String
    var score: Int
    var pain: Int

    var trialNo: Int
    var currentDate: Date
    var additionalInfo: String
    //    var videoUrl: URL
    //    var cameraDirection: Int
}

struct FTPInfo: Codable {
    var date: Date
    var inspectorName: String
    var subjectName: String
    var screenIndex: Int
    
    var title: String
    var direction: String
    var trialNo: Int
    
    var phoneNumber: String
    var gender: Int
    var birth: Int
    var kneeLength: Double
    var palmLength: Double

    var cameraAngle: Int = 1
    
    static let someFileName = """
    currentDate(2022.06.16_16.35.36)_
    inspectoerName(배익준)_
    subjectName(이한목)_
    screenIndex(2)_
    title(ac)direction(r)trialNo(2)_
    phoneNumber(01090417421)_
    gender(1: male, 2: female)_
    birth(1969)_
    kneeLength(0042)_
    palmLength(0018)_
    cameraAngle(1: front, 2: side, 3: 45 degree)
    """
}

//struct Inspector: Codable {
//    let name: String
//    let phoneNumber: String
//}
/*
 
func postRequest(
    movementTitle: String,
    direction: String,
    score: Int,
    pain: Int, trialCount: Int,
    videoURL: URL,
    cameraDirection: String,
    screenKey: UUID,
    closure: @escaping () -> Void ) {
    
    print("---------------- post request!! ----------------")
    
    print("title: \(movementTitle), direction: \(direction), scroe: \(score), pain: \(pain), trialCount: \(trialCount), cameraDirection: \(cameraDirection), screenKey: \(screenKey) ")
    print("videoURL: \(videoURL)")
    print("---------------- post request ended!! ----------------\n\n\n")
}
 
*/
