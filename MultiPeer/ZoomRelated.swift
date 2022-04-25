////
////  ZoomRelated.swift
////  MultiPeer
////
////  Created by 핏투비 iOS on 2022/04/22.
////
//
//import Foundation
//
//
///// Checks if video capture is supported by the hardware.
//public var isVideoCaptureSupported: Bool {
//    get {
//        var deviceTypes: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInWideAngleCamera,
//                                                         AVCaptureDevice.DeviceType.builtInTelephotoCamera]
//        if #available(iOS 11.0, *) {
//            deviceTypes.append(.builtInDualCamera)
//            if #available(iOS 11.1, *) {
//                deviceTypes.append(.builtInTrueDepthCamera)
//            }
//        } else {
//            deviceTypes.append(.builtInDuoCamera)
//        }
//        if #available(iOS 13.0, *) {
//            deviceTypes.append(.builtInWideAngleCamera)
//            deviceTypes.append(.builtInUltraWideCamera)
//        }
//        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .unspecified)
//        return discoverySession.devices.count > 0
//    }
//}
//
//
//public class func primaryVideoDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
//
//    // -- Changes begun
//    if #available(iOS 13.0, *) {
//
//        let hasUltraWideCamera: Bool = true // Set this variable to true if your device is one of the following - iPhone 11, iPhone 11 Pro, & iPhone 11 Pro Max
//
//        if hasUltraWideCamera {
//
//            // Your iPhone has UltraWideCamera.
//            let deviceTypes: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInUltraWideCamera]
//            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: position)
//            return discoverySession.devices.first
//
//        }
//
//    }
//    // -- Changes end
//
//
//    var deviceTypes: [AVCaptureDevice.DeviceType] = [AVCaptureDevice.DeviceType.builtInWideAngleCamera] // builtInWideAngleCamera // builtInUltraWideCamera
//    if #available(iOS 11.0, *) {
//        deviceTypes.append(.builtInDualCamera)
//    } else {
//        deviceTypes.append(.builtInDuoCamera)
//    }
//
//    // prioritize duo camera systems before wide angle
//    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: position)
//
//    for device in discoverySession.devices {
//        if #available(iOS 11.0, *) {
//            if (device.deviceType == AVCaptureDevice.DeviceType.builtInDualCamera) {
//                return device
//            }
//        } else {
//            if (device.deviceType == AVCaptureDevice.DeviceType.builtInDuoCamera) {
//                return device
//            }
//        }
//    }
//
//    return discoverySession.devices.first
//
//}
//
//
//
