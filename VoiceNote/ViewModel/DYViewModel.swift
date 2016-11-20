//
//  DYViewModel.swift
//  FlashWord
//
//  Created by darren on 16/6/14.
//  Copyright © 2016年 FlashWord. All rights reserved.
//

import Foundation

public typealias DYCommonCallback = (AnyObject?, NSError?) -> Void

@objc(DYViewModel)
class DYViewModel : NSObject {
    dynamic var tag : String = ""
    dynamic var data : AnyObject?
    
    init(data:AnyObject?) {
        self.data = data
        
        super.init()
        
        setupViewModel()
    }
    
    override convenience init() {
        self.init(data:nil)
    }
    
    deinit {
    }

    /**一般用RAC将data的数据映射到viewmodel对应字段，但对于某些data中存在1对1等关系数据时候，
     * 需要从数据库重新加载关系数据，并重新映射到viewmodel对应字段。参考CollectionPageViewModel,CommentVM
     */
    func setupViewModel() {
    }
    
    /**子类在次函数用RAC将data的数据映射到viewmodel对应字段
     */
    func reloadRelationData() {
    }
}
