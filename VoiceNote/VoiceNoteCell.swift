//
//  VoiceNoteCell.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class VoiceNoteCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playProgressView: VoiceProgressView!

    dynamic var viewModel : VoiceNoteCellVM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupReactive()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupReactive() {
        DynamicProperty<String>(object: self.titleLabel, keyPath: #keyPath(text)) <~ DynamicProperty<String>(object: self, keyPath: #keyPath(viewModel.title)).signal
        
        DynamicProperty<String>(object: self.durationLabel, keyPath: #keyPath(text)) <~ DynamicProperty<String>(object: self, keyPath: #keyPath(viewModel.duration)).signal
    }
}
