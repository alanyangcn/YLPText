//
//  YYTextArchiver.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/21.
//

import UIKit
//  Converted to Swift 5.3 by Swiftify v5.3.21043 - https://swiftify.com/
/// A subclass of `NSKeyedArchiver` which implement `NSKeyedArchiverDelegate` protocol.
/// The archiver can encode the object which contains
/// CGColor/CGImage/CTRunDelegateRef/.. (such as NSAttributedString).
class YYTextArchiver: NSKeyedArchiver, NSKeyedArchiverDelegate {

//    override class func archivedData(withRootObject rootObject: Any) -> Data {
//        var data = NSMutableData()
//        let archiver = self.init(forWritingWith: data)
//        
//        return data as! Data
//    }
//    required override init() {
//        super.init()
//    }

    
}

/// A subclass of `NSKeyedUnarchiver` which implement `NSKeyedUnarchiverDelegate`
/// protocol. The unarchiver can decode the data which is encoded by
/// `YYTextArchiver` or `NSKeyedArchiver`.
class YYTextUnarchiver: NSKeyedUnarchiver, NSKeyedUnarchiverDelegate {
}
