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
//    static let startRecordingAfter = Notification.Name(rawValue: "startRecordingAfter")
//    static let startCountdownAfter = Notification.Name(rawValue: "startCountDownAfter")
    static let requestPostMsg = Notification.Name(rawValue: "requestPostMsg")
}


extension Notification.Name {
    static let presentCameraKey = Notification.Name(rawValue: "presentCamera")
    static let startRecordingKey = Notification.Name(rawValue: "startRecording")
    static let stopRecordingKey = Notification.Name(rawValue: "stopRecording")
    static let updateConnectionStateKey = Notification.Name(rawValue: "updateConnectionState")
//    static let startRecordingAfterKey = NotificationKeys.startRecordingAfter
//    static let startCountdownAfterKey = NotificationKeys.startCountdownAfter
    static let requestPostKey = Notification.Name(rawValue: "requestPostMsg")
}
