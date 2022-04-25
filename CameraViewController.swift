//
//  CameraViewController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

// https://stackoverflow.com/questions/44917303/swift-create-custom-capture-session-preset
import Foundation
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController,
    AVCaptureAudioDataOutputSampleBufferDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate {

    private var session: AVCaptureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()

//    private var videoDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//    private var videoDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType)!
    private var videoDevice: AVCaptureDevice!
    private var audioConnection: AVCaptureConnection?
    private var videoConnection: AVCaptureConnection?

    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var videoInput: AVAssetWriterInput?

    private var fileManager: FileManager = FileManager()
    private var recordingURL: URL?

    private var isCameraRecording: Bool = false
    private var isRecordingSessionStarted: Bool = false

    private var recordingQueue = DispatchQueue(label: "recording.queue")
    
    
    let audioSettings = [
        AVFormatIDKey : kAudioFormatAppleIMA4,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 16000.0
    ] as [String : Any]
    
    let videoSettings = [
        AVVideoCodecKey : AVVideoCodecType.h264,
        AVVideoWidthKey : UIScreen.main.bounds.width,
        AVVideoHeightKey : UIScreen.main.bounds.width
    ] as [String : Any]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
        configureWriteInputs()
        setupSquarePreview()
        startSession()
        addOutputs()
    }
    
    
    private func configureSession() {
        self.session.sessionPreset = AVCaptureSession.Preset.high
        self.recordingURL = URL(fileURLWithPath: "\(NSTemporaryDirectory() as String)/file.mov")
        if self.fileManager.isDeletableFile(atPath: self.recordingURL!.path) {
            _ = try? self.fileManager.removeItem(atPath: self.recordingURL!.path)
        }
        self.assetWriter = try? AVAssetWriter(outputURL: self.recordingURL!,
                                              fileType: AVFileType.mov)
    }
    
    private func configureWriteInputs() {
        self.videoInput = AVAssetWriterInput(mediaType: AVMediaType.video,
             outputSettings: videoSettings)
        self.audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio,
             outputSettings: audioSettings)

        self.videoInput?.expectsMediaDataInRealTime = true
        self.audioInput?.expectsMediaDataInRealTime = true

        if self.assetWriter!.canAdd(self.videoInput!) {
            self.assetWriter?.add(self.videoInput!)
        }

        if self.assetWriter!.canAdd(self.audioInput!) {
            self.assetWriter?.add(self.audioInput!)
        }
    }
    
    private func setupDeviceInput() {
        self.deviceInput = try? AVCaptureDeviceInput(device: self.videoDevice)
        if self.session.canAddInput(self.deviceInput!) {
            self.session.addInput(self.deviceInput!)
        }
    }
    
    // MARK: - Now you can configure AVCaptureVideoPreviewLayer to be a square.
    private func setupSquarePreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)

        //importent line of code what will did a trick
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        let rootLayer = self.view.layer
        rootLayer.masksToBounds = true
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)

        rootLayer.insertSublayer(self.previewLayer!, at: 0)
                rootLayer.insertSublayer(self.previewLayer!, at: 0)
    }
    
    private func startSession() {
        self.session.startRunning()
    }
    
    private func addOutputs() {
        DispatchQueue.main.async {
            self.session.beginConfiguration()

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            self.videoConnection = self.videoOutput.connection(with: AVMediaType.video)
            if self.videoConnection?.isVideoStabilizationSupported == true {
                self.videoConnection?.preferredVideoStabilizationMode = .auto
            }
            
            self.session.commitConfiguration()

//            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
//            let audioIn = try? AVCaptureDeviceInput(device: audioDevice)
//
//            if self.session.canAddInput(audioIn) {
//                self.session.addInput(audioIn)
//            }
//
//            if self.session.canAddOutput(self.audioOutput) {
//                self.session.addOutput(self.audioOutput)
//            }
//
//            self.audioConnection = self.audioOutput.connection(with: AVMediaType.audio)
        }
    }
}

