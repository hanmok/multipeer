//
//  NotificationKeys.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/28.
//

import Foundation




extension Notification.Name {
    static let presentCameraKey = Notification.Name(rawValue: "presentCamera")
    static let startRecordingKey = Notification.Name(rawValue: "startRecording")
    static let stopRecordingKey = Notification.Name(rawValue: "stopRecording")
    static let updateConnectionStateKey = Notification.Name(rawValue: "updateConnectionState")
    
    static let requestPostKey = Notification.Name(rawValue: "requestPostMsg")
    static let updatePeerTitleKey = Notification.Name(rawValue: "updatePeerTitle")
    
    static let updatePeerCameraDirectionKey = Notification.Name(rawValue: "updatePeerCameraDirection")
    
    static let hidePreviewKey = Notification.Name(rawValue: "hidePreview")
    
    static let screenSettingKey = Notification.Name(rawValue: "popAll")
    
    static let capturingStartedTime = Notification.Name(rawValue: "captureTime")
}
