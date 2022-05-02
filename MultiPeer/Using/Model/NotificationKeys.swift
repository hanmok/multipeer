//
//  NotificationKeys.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/28.
//

import Foundation



public enum NotificationKeys {
    static let presentCamera = Notification.Name(rawValue: "presentCamera")
    static let startRecording = Notification.Name(rawValue: "startRecording")
    static let stopRecording = Notification.Name(rawValue: "stopRecording")
    static let updateConnectionState = Notification.Name(rawValue: "updateConnectionState")
    static let startRecordingAt = Notification.Name(rawValue: "startRecordingAt")
}


extension Notification.Name {
    static let presentCamera = NotificationKeys.presentCamera
    static let startRecording = NotificationKeys.startRecording
    static let stopRecording = NotificationKeys.stopRecording
    static let updateConnectionState = NotificationKeys.updateConnectionState
    static let startRecordingAt = NotificationKeys.startRecordingAt
}

