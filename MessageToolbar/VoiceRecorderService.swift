//
//  SoundRecorderService.swift
//  MessageToolbar
//
//  Created by Vortex on 1/17/19.
//  Copyright © 2019 Vortex. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceRecorderService: NSObject, AVAudioRecorderDelegate {
    
    private weak var viewController: (UIViewController & MessageToolbarDelegate)?
    private var recordingIsCancelled = false
    
    private var directoryURL: URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0]
        let soundURL = documentDirectory.appendingPathComponent("recorded_voice.m4a")
        return soundURL
    }
    
    private lazy var audioRecorder: AVAudioRecorder? = {
        guard let directoryURL = directoryURL else { return nil }
        do {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let audioRecorder = try AVAudioRecorder(url: directoryURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            return audioRecorder
        } catch {
            viewController?.didFailToRecord?()
            return nil
        }
    }()
    
    private let timeInterval: Double
    
    init(viewController: (UIViewController & MessageToolbarDelegate)?, timeInterval: Double) {
        self.viewController = viewController
        self.timeInterval = timeInterval
        super.init()
        self.setupAudioSession()
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            session.requestRecordPermission { [weak self] allowed in
                guard let self = self else { return }
                if !allowed {
                    self.viewController?.didDenyMicPermission?()
                }
            }
        } catch {
            viewController?.didFailToRecord?()
        }
    }
    
    func startRecording() {
        audioRecorder?.record(forDuration: timeInterval)
    }
    
    func stopRecording(cancelled: Bool) {
        self.recordingIsCancelled = cancelled
        audioRecorder?.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard !recordingIsCancelled else {
            viewController?.didCancelRecord?()
            recordingIsCancelled = false
            return
        }
        if flag {
            guard let directoryURL = directoryURL else { return }
            do {
                let voiceData = try Data(contentsOf: directoryURL)
                viewController?.didFinish?(recording: voiceData)
            } catch {
                viewController?.didFailToRecord?()
            }
        } else {
            viewController?.didFailToRecord?()
        }
    }
    
}
