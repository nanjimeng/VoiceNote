//
//  VoiceNoteCellVM.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/20.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

typealias VoiceState = Int

extension VoiceState {
    static let pause = Int(0)
    static let play = Int(1)
}

@objc(VoiceNoteCellVM)
class VoiceNoteCellVM: DYViewModel {
    dynamic var title : String = ""
    dynamic var duration : String = ""
    dynamic var progress : Float = 0 {
        didSet {
            if progress >= 1 {
                state = VoiceState.pause
                progress = 0
            }
        }
    }
    dynamic var state : Int = VoiceState.pause {
        didSet {
            if progress >= 1 {
                state = VoiceState.pause
                progress = 0
            }
        }
    }
    
    override func setupViewModel() {
        guard let voice = self.data as? VoiceNoteData else {
            return
        }
        
         DynamicProperty<String>(object: self, keyPath: #keyPath(title)) <~ DynamicProperty<String>(object: self, keyPath:"data.name").producer.map({ (title) -> String in
            return title ?? ""
         })
        
        DynamicProperty<String>(object: self, keyPath: #keyPath(duration)) <~ DynamicProperty<Float>(object: self, keyPath:"data.duration").producer.map({ (duration) -> String in
            guard let duration = duration else {
                return ""
            }
            
            var time = Int32(duration * 1000)
            let milli = time % 1000
            time = time / 1000
            let minutes = time / 60
            let seconds = time % 60
            return String(format: "%02d:%02d %03d", minutes, seconds, milli)
        })
        
    }
}
