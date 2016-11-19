//
//  VoiceNoteCell.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit

class VoiceNoteCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playbackProgressPlaceholderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func applyData(voice: VoiceNoteData) {
        titleLabel.text = voice.name
        
        var duration = Int32(voice.duration * 1000)
        let milli = duration % 1000
        duration = duration / 1000
        let minutes = duration / 60
        let seconds = duration % 60
        durationLabel.text = String(format: "%02d:%02d %03d", minutes, seconds, milli)
    }

}
