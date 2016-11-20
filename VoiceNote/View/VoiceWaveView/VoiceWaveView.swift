//
//  VoiceWaveView.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit

class VoiceWaveView: UIView {
    //MARK: 
    var phase: CGFloat = 0;
    var amplitude: CGFloat = 1.0;
    var idleAmplitude: CGFloat = 0.01;
    var frequency: CGFloat = 1.5;
    var numberOfWaves: UInt = 5
    var phaseShift: CGFloat = -0.15;
    var density: CGFloat = 5.0;
    var primaryWaveLineWidth: CGFloat = 3.0;
    var secondaryWaveLineWidth: CGFloat = 1.0;
    var waveColor: UIColor = UIColor.brown;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
    }
    
    func update(level: CGFloat) {
        self.phase += self.phaseShift;
        self.amplitude = fmax(level, self.idleAmplitude);
        
         setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.clear(self.bounds);
        self.backgroundColor?.set()
        context.fill(rect)
        
        let halfHeight = self.bounds.height*0.5
        let width = self.bounds.width;
        let halfWidth = width*0.5;
        let maxAmplitude = halfHeight - 4.0;
        
        for index in 0 ..< numberOfWaves {
            context.setLineWidth(index==0 ? primaryWaveLineWidth : secondaryWaveLineWidth)
            
            let  progress = 1.0 - CGFloat(index) / CGFloat(numberOfWaves);
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude;
            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0));
            waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()
            
            
            for x in stride(from: 0.0, to: width+density, by: density) {
                var scale = 1 / halfWidth * (x-halfWidth)
                scale = scale * scale
                scale =  1 - scale
                let y = scale * maxAmplitude * normedAmplitude * sin(2 * CGFloat(M_PI) * (x / width) * frequency + phase) + halfHeight
                
                if x <= 0 {
                    context.move(to: CGPoint(x: x, y: y))
                } else {
                    context.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.strokePath();
        }
    }

}
