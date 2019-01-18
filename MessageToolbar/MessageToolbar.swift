//
//  MessageToolbar.swift
//  MessageToolbar
//
//  Created by Vortex on 1/17/19.
//  Copyright © 2019 Vortex. All rights reserved.
//

import UIKit
import AudioToolbox
import Shimmer

@objc public protocol MessageToolbarDelegate: class {
    
    @objc optional func didFinish(picking image: UIImage)
    @objc optional func didDenyPhotoLibraryPermission()
    @objc optional func didCancelPhotoPicking()
    
    @objc optional func didFinish(recording voice: Data)
    @objc optional func didFailToRecord()
    @objc optional func didDenyMicPermission()
    @objc optional func didCancelRecord()
    
    func didSend(message: String)
}

public class MessageToolbar: UIView {
    
    public var pickImageButtonImage: UIImage? {
        didSet {
            pickImageButton.setImage(pickImageButtonImage, for: .normal)
        }
    }
    
    public var recordVoiceButtonImage: UIImage? {
        didSet {
            recordVoiceButton.setImage(recordVoiceButtonImage, for: .normal)
        }
    }
    
    public var disabledSendButtonImage: UIImage? = loadImage(name: "send_gray") {
        didSet {
            sendButton.setImage(disabledSendButtonImage, for: .normal)
        }
    }
    
    public var enabledSendButtonImage: UIImage? = loadImage(name: "send_black")
    
    public var micIconImage: UIImage? = loadImage(name: "microphone_gray")
    
    public var enablePhotoPicking: Bool = true {
        didSet {
            pickImageButton.isHidden = !enablePhotoPicking
        }
    }
    
    public var enableVoiceRecord: Bool = true {
        didSet {
            recordVoiceButton.isHidden = !enableVoiceRecord
        }
    }
    
    public var voiceRecordDuration: Double = 10 {
        didSet {
            timerDuration = voiceRecordDuration
        }
    }
    
    private var timerDuration: Double = 10
    
    public weak var delegate: (UIViewController & MessageToolbarDelegate)? {
        didSet {
            sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            pickImageButton.addTarget(imagePickerService, action: #selector(imagePickerService.presentImagePicker), for: .touchUpInside)
        }
    }
    
    private lazy var messageTextView: GrowingTextView = {
        let textView = GrowingTextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.minHeight = 32
        textView.maxHeight = 64
        textView.placeholder = "Say something..."
        textView.delegate = self
        return textView
    }()
    
    private lazy var pickImageButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(MessageToolbar.loadImage(name: "photo_gray"), for: .normal)
        return button
    }()
    
    private lazy var recordVoiceButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(MessageToolbar.loadImage(name: "microphone_gray"
        ), for: .normal)
        button.addGestureRecognizer(longPressGesture)
        return button
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPressGesture.allowableMovement = 10
        longPressGesture.minimumPressDuration = 0.2
        longPressGesture.cancelsTouchesInView = false
        return longPressGesture
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(MessageToolbar.loadImage(name: "send_gray"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pickImageButton, recordVoiceButton, sendButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var shimmeringView: FBShimmeringView = {
        let view = FBShimmeringView()
        view.backgroundColor = backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shimmeringSpeed = 140
        view.shimmeringOpacity = 0.2
        view.shimmeringBeginFadeDuration = 0.3
        view.shimmeringDirection = .left
        view.isShimmering = true
        return view
    }()
    
    private var shimmeringLeadingToTrailingConstraint: NSLayoutConstraint!
    private var shimmeringLeadingToLeadingConstraint: NSLayoutConstraint!
    
    private lazy var shimmeringLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Swipe left to cancel,\nlet go to send"
        label.font = label.font.withSize(14)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.backgroundColor = backgroundColor
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var micIcon: UIImageView = {
        let imageView = UIImageView(image: micIconImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(14)
        return label
    }()
    
    private lazy var imagePickerService: ImagePickerService = {
        let imagePickerService = ImagePickerService(viewController: delegate)
        return imagePickerService
    }()
    
    private lazy var voiceRecorderService: VoiceRecorderService = {
        let voiceRecorderService = VoiceRecorderService(viewController: delegate, timeInterval: voiceRecordDuration)
        return voiceRecorderService
    }()
    
    private var didFinishRecord = false
    private var voiceRecorderTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setBackgroundColor()
        layoutUI()
        setDurationLabelText(timeRemaining: timerDuration)
    }
    
    func setBackgroundColor(color: UIColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)) {
        backgroundColor = color
    }
    
    private func addSubviews() {
        addSubview(messageTextView)
        addSubview(buttonsStackView)
        addSubview(shimmeringView)
        shimmeringView.addSubview(shimmeringLabel)
        shimmeringView.contentView = shimmeringLabel
        shimmeringView.addSubview(micIcon)
        shimmeringView.addSubview(durationLabel)
    }

    private func setupMessageTextViewConstraints() {
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            messageTextView.trailingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor, constant: -8),
            messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func setupButtonsConstraints() {
        [pickImageButton, recordVoiceButton, sendButton].forEach {
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 30),
                $0.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func setupShimmeringViewConstraints() {
        shimmeringLeadingToTrailingConstraint = shimmeringView.leadingAnchor.constraint(equalTo: trailingAnchor)
        shimmeringLeadingToLeadingConstraint = shimmeringView.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            shimmeringView.topAnchor.constraint(equalTo: topAnchor),
            shimmeringLeadingToTrailingConstraint,
            shimmeringView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shimmeringView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupShimmeringLabelConstraints() {
        NSLayoutConstraint.activate([
            shimmeringLabel.centerXAnchor.constraint(equalTo: shimmeringView.centerXAnchor, constant: 0),
            shimmeringLabel.centerYAnchor.constraint(equalTo: shimmeringView.centerYAnchor, constant: 0)
        ])
    }

    private func setupMicIconConstraints() {
        NSLayoutConstraint.activate([
            micIcon.leadingAnchor.constraint(equalTo: shimmeringView.leadingAnchor, constant: 8),
            micIcon.centerYAnchor.constraint(equalTo: shimmeringView.centerYAnchor),
            micIcon.widthAnchor.constraint(equalToConstant: 20),
            micIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupDurationLabelConstraints() {
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: micIcon.trailingAnchor, constant: 8),
            durationLabel.centerYAnchor.constraint(equalTo: micIcon.centerYAnchor)
        ])
    }
    
    private func layoutUI() {
        addSubviews()
        setupMessageTextViewConstraints()
        setupButtonsConstraints()
        setupStackViewConstraints()
        setupShimmeringViewConstraints()
        setupShimmeringLabelConstraints()
        setupMicIconConstraints()
        setupDurationLabelConstraints()
    }
    
    private func updateSendButton(state: Bool) {
        if state {
            sendButton.setImage(enabledSendButtonImage, for: .normal)
        } else {
            sendButton.setImage(disabledSendButtonImage, for: .normal)
        }
        sendButton.isEnabled = state
    }
    
    @objc private func sendMessage() {
        delegate?.didSend(message: messageTextView.text)
        messageTextView.text = ""
        updateSendButton(state: false)
    }
    
    private func showShimmeringView() {
        shimmeringLeadingToTrailingConstraint.isActive = false
        shimmeringLeadingToLeadingConstraint.isActive = true
        UIView.animate(withDuration: 0.28, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
    
    private func hideShimmeringView() {
        shimmeringLeadingToLeadingConstraint.isActive = false
        shimmeringLeadingToTrailingConstraint.isActive = true
        UIView.animate(withDuration: 0.28, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        let button = gesture.view as! UIButton
        let location = gesture.location(in: button)
        switch gesture.state {
        case .began :
            AudioServicesPlaySystemSound(1519)
            showShimmeringView()
            didFinishRecord = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                self.voiceRecorderService.startRecording()
                self.startTimer()
            }
            
        case .changed:
            let cancelPosition = location.x
            if cancelPosition <= -center.x + 70 {
                if !didFinishRecord {
                    voiceRecorderService.stopRecording(cancelled: true)
                    hideShimmeringView()
                    AudioServicesPlaySystemSound(1521)
                    didFinishRecord = true
                    resetTimer()
                }
            }
        case .ended:
            voiceRecorderService.stopRecording(cancelled: false)
            hideShimmeringView()
            resetTimer()
        default:
            break
        }
        
    }
    
    private func setDurationLabelText(timeRemaining: Double) {
        let minutesLeft = Int(timeRemaining) / 60 % 60
        let secondsLeft = Int(timeRemaining) % 60
        durationLabel.text = String(format: "%01d:%02d", minutesLeft, secondsLeft)
    }
    
    private func startTimer() {
        resetTimer()
        if voiceRecorderTimer == nil {
            voiceRecorderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
            voiceRecorderTimer?.fire()
        }
    }
    
    private func resetTimer() {
        voiceRecorderTimer?.invalidate()
        voiceRecorderTimer = nil
        timerDuration = voiceRecordDuration
        setDurationLabelText(timeRemaining: timerDuration)
    }
    
    @objc func timerRunning() {
        timerDuration -= 1
        setDurationLabelText(timeRemaining: timerDuration)
        micIcon.fadeOutAndIn(duration: 0.5)
        if timerDuration == 0 {
            voiceRecorderTimer?.invalidate()
            timerDuration = voiceRecordDuration
            setDurationLabelText(timeRemaining: timerDuration)
        }
    }
    
    private static func loadImage(name: String) -> UIImage? {
        if let url = Bundle(for: MessageToolbar.self).url(forResource: "MessageToolbar", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        }
        return nil
    }
}


extension MessageToolbar: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let range = Range(range, in: textView.text) {
            let updatedText = textView.text.replacingCharacters(in: range, with: text)
            updateSendButton(state: updatedText.count != 0)
        }
        return true

    }

}
