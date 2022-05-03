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
    static let startRecordingAfter = Notification.Name(rawValue: "startRecordingAfter")
    static let startCountdownAfter = Notification.Name(rawValue: "startCountDownAfter")
}


extension Notification.Name {
    static let presentCameraKey = NotificationKeys.presentCamera
    static let startRecordingKey = NotificationKeys.startRecording
    static let stopRecordingKey = NotificationKeys.stopRecording
    static let updateConnectionStateKey = NotificationKeys.updateConnectionState
    static let startRecordingAfterKey = NotificationKeys.startRecordingAfter
    static let startCountdownAfterKey = NotificationKeys.startCountdownAfter
}

