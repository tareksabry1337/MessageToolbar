//
//  MessageToolbarCode.swift
//  MessageToolbarExample
//
//  Created by Vortex on 1/18/19.
//  Copyright © 2019 Tarek Sabry. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MessageToolbar

class MessageToolbarCode: UIViewController, MessageToolbarDelegate {
   
    @IBOutlet weak var textLabel: UILabel!
    var audioPlayer: AVAudioPlayer!
    
    //Or just let's do it in code because embrace lazy initalization !
    lazy var messageToolbar: MessageToolbar = {
        let messageToolbar = MessageToolbar()
        messageToolbar.translatesAutoresizingMaskIntoConstraints = false //Why apple does not disable that by default ? >.>
        //For demo purposes I'm going to disable image sending and extend the duration of voice recorder to one minute
        messageToolbar.enablePhotoPicking = false
        messageToolbar.voiceRecordDuration = 60
        messageToolbar.delegate = self
        return messageToolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Code Test"
        view.addSubview(messageToolbar)
        NSLayoutConstraint.activate([
            messageToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            messageToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            messageToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
    
    func didSend(message: String) {
        textLabel.text = message
    }
    
    //Get notified when user is done with recording
    func didFinish(recording voice: Data) {
        do {
            try audioPlayer = AVAudioPlayer(data: voice)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //Or get notified when he cancels it !
    func didCancelRecord() {
        print("User cancelled the recording")
    }
    
}
