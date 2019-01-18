//
//  MessageToolbarInterfaceBuilder.swift
//  MessageToolbarExample
//
//  Created by Vortex on 1/18/19.
//  Copyright © 2019 Tarek Sabry. All rights reserved.
//

import UIKit
import MessageToolbar
import AVFoundation

class MessageToolbarInterfaceBuilder: UIViewController, MessageToolbarDelegate {
    
    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageToolbar.delegate = self
        title = "Interface Builder Test"
        /**
        //You can also do something like this
        messageToolbar.enableVoiceRecord = false
        messageToolbar.enablePhotoPicking = false
        
        //Or even this !
        messageToolbar.disabledSendButtonImage = //Your desired image goes here
        messageToolbar.enabledSendButtonImage = //Your desired image goes here
        **/
    }
    
    func didSend(message: String) {
        textLabel.text = message
    }
    
    func didFinish(picking image: UIImage) {
        selectedImage.image = image
    }
    
    func didFinish(recording voice: Data) {
        do {
            try audioPlayer = AVAudioPlayer(data: voice)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
