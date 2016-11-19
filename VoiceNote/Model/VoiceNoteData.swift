//
//  VoiceNoteData.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import Foundation
import CoreData

@objc(VoiceNoteData)
public class VoiceNoteData: NSManagedObject {
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoiceNoteData> {
//        return NSFetchRequest<VoiceNoteData>(entityName: "VoiceNoteData");
//    }
    @NSManaged public var fileName: String?
    @NSManaged public var name: String?
    @NSManaged public var duration: Float
    @NSManaged public var date: Date?
}


extension VoiceNoteData {
    private class var storeURL: URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let directoryURL = documentURL.appendingPathComponent("Voice")
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            assertionFailure("Error creating directory: \(error)")
        }
        return directoryURL as URL
    }
    
    class func fileStorePath(fileName: String) -> String {
        return self.storeURL.appendingPathComponent(fileName).path
    }
    
    func fileStorePath() -> String {
        return VoiceNoteData.fileStorePath(fileName: self.fileName ?? "")
    }
}
