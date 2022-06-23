//
//  MsgModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


import Foundation


struct MsgWithMovementDetail: Codable {
    var message: MessageType
    var detailInfo: MovementDirectionScoreInfo // 이게 문제
    
}

struct PeerInfo: Codable {
    var msgType: MessageType
    var info: Info
}

struct Info: Codable {
    var movementDetail: MovementDirectionScoreInfo?
    var idWithDirection: DeviceNameWithCameraDirection?
    var movementTitleDirection: MovementTitleDirectionInfo?
//    var postReqInfo: PostReqInfo?
    var ftpInfo: FTPInfo?
    var ftpInfoString: FtpInfoString?
}

struct FtpInfoString: Codable {
    var fileName: String
}

struct DeviceNameWithCameraDirection: Codable {
    var peerId: String
    var cameraDirection: CameraDirection
}

struct MsgWithTime: Codable {
    let msg: MessageType
    let timeInMilliSec: Int
}

struct PeerCommunicationHelper {
    static let msgToKeyDic: [MessageType: Notification.Name] = [
        .startRecordingMsg: .startRecordingKey,
        .stopRecordingMsg: .stopRecordingKey,
        .hidePreviewMsg: .hidePreviewKey,
        
        .presentCameraMsg: .presentCameraKey,
        .updatePeerTitleMsg: .updatePeerTitleKey,
        .requestPostMsg: .requestPostKey,
        
        .updatePeerCameraDirectionMsg: .updatePeerCameraDirectionKey
    ]
}



// MARK: - Message

public enum MessageType: String, Codable {
    case hidePreviewMsg
    case startRecordingMsg
    case stopRecordingMsg
    
    case presentCameraMsg
    case updatePeerTitleMsg

    case requestPostMsg
    
    case updatePeerCameraDirectionMsg
    case none
}



// MARK: - Connection State
public enum ConnectionState: String, Codable {
    case connected
    case disconnected
}





/*
 connectionManager.send(PeerInfo(msgType: .presentCamera, info: Info(movementDetail: MovementDirectionScoreInfo(title: selectedTrial.title, direction: direction))))

 
 public enum MessageType: String, Codable {
     case hidePreviewMsg
     case startRecordingMsg
     case stopRecordingMsg
     
     case presentCameraMsg
     case requestPostMsg
     case updatePeerTitleMsg
     
     case updatePeerCameraDirectionMsg
 }

 hidePreviewMsg -> Msg Only
 startRecordingMsg -> Msg Only
 stopRecordingMsg -> Msg Only
 
 // postMsg : Score Needed
 
 presentCamera -> Title, Direction, Msg
 updatePeerTitleMsg -> Title, Direction, Msg
 
 requestPostMsg -> title, Direction, score, pain
 
 
 updatePeerCameraDirectionMsg -> Device's name, cameraDirection
 
 // 또.. 필요한게 뭐가 있나... ??
 peer 는 Trial Core, Detail, Screen 에 대한 정보 모를 수 잇음.
 
 */

//



