//
//  AddVoiceNoteController.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit
import AVFoundation

class AddVoiceNoteController: UIViewController {
    //MARK: Date Formatter
    public static let dateFormatter : DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }();
    
    @IBOutlet weak var waveView: VoiceWaveView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButtonX: NSLayoutConstraint!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var ignoreButtonX: NSLayoutConstraint!
    
    //内部变量
    var wasIdleTimerDisabled = false
    var meterUpdateDisplayLink: CADisplayLink?
    var oldSessionCategory : String!
    
    //录音相关
    lazy var recordFileName : String = {
        let name = ProcessInfo.processInfo.globallyUniqueString + ".m4a"
        return name
    }()
    lazy var recordFilePath : String = {
        let path = NSTemporaryDirectory().appending(self.recordFileName)
        return path
    }()
    lazy var audioRecorder : AVAudioRecorder? = {
        var recorder : AVAudioRecorder? = nil
        do {
            
            let settings: [String : Any]  = [
                AVFormatIDKey : kAudioFormatMPEG4AAC,
                AVSampleRateKey : 44100,
                AVNumberOfChannelsKey : 1,
                AVEncoderAudioQualityKey : 0
                ]
            
            recorder = try AVAudioRecorder(url: URL(fileURLWithPath: self.recordFilePath),
                                                    settings:settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
        }
        return recorder
    }()
    var duration : Float = 0
    
    
    //播放
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (succeed) in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdateMeter()
        wasIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioRecorder?.delegate = nil
        audioRecorder?.stop()
        audioRecorder = nil
        
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        audioPlayer = nil
        
        stopUpdateMeter()
        
        UIApplication.shared.isIdleTimerDisabled = wasIdleTimerDisabled
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Action
    @IBAction func onButtonRacordTouchDown() {
        debugPrint("Invalid onButtonRacordTouchDown")
        
        guard let audioRecorder = self.audioRecorder else {
            debugPrint("Invalid audioRecorder")
            return
        }
        
        //删除旧的录音文件
        if FileManager.default.fileExists(atPath: recordFilePath) {
            do {
                try FileManager.default.removeItem(atPath: recordFilePath)
            } catch let error as NSError {
                debugPrint("\(error.localizedDescription)")
                return
            }
        }
        
        do {
            oldSessionCategory = AVAudioSession.sharedInstance().category
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            UIApplication.shared.isIdleTimerDisabled = true
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
            return
        }
        
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func onButtonRacordTouchUp() {
        debugPrint("Invalid onButtonRacordTouchUp")
        
        guard let audioRecorder = self.audioRecorder else {
            debugPrint("Invalid audioRecorder")
            return
        }
        
        let duration = audioRecorder.currentTime
        if duration <= 0.75 {
            //录音太短不保存
            return
        }
        self.duration = Float(duration)
        
         audioRecorder.stop()
    }
    
    @IBAction func onButtonPlayClick() {
        do {
            oldSessionCategory = AVAudioSession.sharedInstance().category
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            UIApplication.shared.isIdleTimerDisabled = true
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
            return
        }
        
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.recordFilePath))
                audioPlayer?.delegate = self
                audioPlayer?.isMeteringEnabled = true
            } catch let error as NSError {
                debugPrint("\(error.localizedDescription)")
            }
        }
        
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    @IBAction func onButtonSaveClick() {
        let fileName = self.recordFileName
        let duration = self.duration
        let storePath = VoiceNoteData.fileStorePath(fileName: fileName)
        
        do {
            try? FileManager.default.removeItem(atPath: storePath)
            try FileManager.default.moveItem(atPath: self.recordFilePath, toPath: storePath)
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
            return
        }
        
//        let context =  NSManagedObjectContext.mr_context(withParent: NSManagedObjectContext.mr_default())
//        let date = Date()
//        let voice = VoiceNoteData.mr_createEntity(in: context)
//        voice?.date = date
//        voice?.duration = duration
//        voice?.fileName = fileName
//        voice?.name = AddVoiceNoteController.dateFormatter.string(from: date)
//        context.mr_saveToPersistentStoreAndWait()
        
        MagicalRecord.save({ (context) in
            let date = Date()
            let voice = VoiceNoteData.mr_createEntity(in: context)
            voice?.date = date
            voice?.duration = duration
            voice?.fileName = fileName
            voice?.name = AddVoiceNoteController.dateFormatter.string(from: date)
        }, completion: {[weak self] (saveDone, error) in
            guard let sSelf = self else {
                return
            }
            
            if error == nil {
                if saveDone {
                    _ = sSelf.navigationController?.popViewController(animated: true)
                } else {
                    debugPrint("save failed")
                }
            } else {
                debugPrint("\(error!.localizedDescription)")
            }
        })
    }
    
    @IBAction func onButtonIgnoreClick() {
        audioPlayer?.delegate = nil;
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            try FileManager.default.removeItem(atPath: recordFilePath)
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
            return
        }
        
        hideButtonPlay()
    }
    
    //MARK: Animate Buttons
    func showButtonPlay() {
        UIView.animate(withDuration: 0.45, animations: {
            self.playButton.alpha = 1
            self.ignoreButton.alpha = 1
            self.saveButton.alpha = 1
            self.recordButton.alpha = 0
            
            let offset = self.view.bounds.size.width*0.25
            self.playButtonX.constant = -offset
            self.ignoreButtonX.constant = offset
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func hideButtonPlay() {
        UIView.animate(withDuration: 0.45, animations: {
            self.playButton.alpha = 0
            self.ignoreButton.alpha = 0
            self.saveButton.alpha = 0
            self.recordButton.alpha = 1
            
            self.playButtonX.constant = 0
            self.ignoreButtonX.constant = 0
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: Update Meters
    func startUpdateMeter() {
        meterUpdateDisplayLink?.invalidate()
        let displayLink = CADisplayLink.init(target: self, selector: #selector(updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.meterUpdateDisplayLink = displayLink
    }
    
    func stopUpdateMeter() {
        meterUpdateDisplayLink?.invalidate()
        self.meterUpdateDisplayLink = nil
    }
    
    func updateMeters() {
        var waveColor = UIColor.darkGray
        var level: Float = 0
        if audioRecorder != nil && audioRecorder!.isRecording{
            audioRecorder!.updateMeters()
            level = pow(10, audioRecorder!.averagePower(forChannel: 0) * 0.025)
            debugPrint("level \(level)")
            waveColor = UIColor.blue
        } else if audioPlayer != nil && audioPlayer!.isPlaying {
            audioPlayer!.updateMeters()
            level = pow(10, audioPlayer!.averagePower(forChannel: 0) * 0.025)
            waveColor = UIColor.blue
        }
        waveView.waveColor = waveColor
        waveView.update(level: CGFloat(level))
    }
}

extension AddVoiceNoteController : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if FileManager.default.fileExists(atPath: recordFilePath) {
                showButtonPlay()
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(oldSessionCategory)
                UIApplication.shared.isIdleTimerDisabled = wasIdleTimerDisabled
            } catch let error as NSError {
                debugPrint("\(error.localizedDescription)")
                return
            }
        } else {
            do {
                try FileManager.default.removeItem(atPath: recordFilePath)
            } catch let error as NSError {
                debugPrint("\(error.localizedDescription)")
                return
            }
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error else {
            return
        }
        
        debugPrint(error.localizedDescription)
    }
}

extension AddVoiceNoteController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       audioPlayer?.delegate = nil;
       audioPlayer?.stop()
       audioPlayer = nil
        
        do {
            try AVAudioSession.sharedInstance().setCategory(oldSessionCategory)
            UIApplication.shared.isIdleTimerDisabled = wasIdleTimerDisabled
        } catch let error as NSError {
            debugPrint("\(error.localizedDescription)")
            return
        }
    }
}

