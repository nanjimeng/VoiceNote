//
//  DYDataCenter.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import Foundation

public class DYDataCenter: NSObject {
    //MARK: 单例
    static let center = DYDataCenter()
    private override init() {
    }
    
    //MARK: 设置构建数据库
    public func setup() {
        //CoreData
        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.verbose)
        
        let dbName = "com.voice.note.data"
        MagicalRecord.setupCoreDataStack(withStoreNamed: dbName)
//        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: dbName)
        
        let path = NSPersistentStore.mr_url(forStoreName: dbName)
        debugPrint("DB Path: \(path!.absoluteString) ")
    }
    
    //MARK: app退出时清理数据库
    public func cleanUp () {
        MagicalRecord.cleanUp()
    }
}
