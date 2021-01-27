//
//  YLPTextWeakProxy.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/27.
//

import UIKit

//private func DeallocCallback(_ ref: UnsafeMutableRawPointer?) {
//    var self = ref as? YLPTextRunDelegate
//    self = nil // release
//}
//
//private func GetAscentCallback(_ ref: UnsafeMutableRawPointer?) -> CGFloat {
//    let self = ref as? YLPTextRunDelegate
//    return ascent
//}
//
//private func GetDecentCallback(_ ref: UnsafeMutableRawPointer?) -> CGFloat {
//    let self = ref as? YLPTextRunDelegate
//    return descent
//}
//
//private func GetWidthCallback(_ ref: UnsafeMutableRawPointer?) -> CGFloat {
//    let self = ref as? YLPTextRunDelegate
//    return width
//}

/// Wrapper for CTRunDelegateRef.
/// Example:
/// YYTextRunDelegate *delegate = [YYTextRunDelegate new];
/// delegate.ascent = 20;
/// delegate.descent = 4;
/// delegate.width = 20;
/// CTRunDelegateRef ctRunDelegate = delegate.CTRunDelegate;
/// if (ctRunDelegate) {
/// add to attributed string
/// CFRelease(ctRunDelegate);
/// }

class YLPTextRunDelegate: NSObject, NSCopying, NSCoding {
    /// Additional information about the the run delegate.
    var userInfo: [AnyHashable: Any]?
    /// The typographic ascent of glyphs in the run.
    var ascent: CGFloat = 0.0
    /// The typographic descent of glyphs in the run.
    var descent: CGFloat = 0.0
    /// The typographic width of glyphs in the run.
    var width: CGFloat = 0.0

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ascent, forKey: "ascent")
        aCoder.encode(descent, forKey: "descent")
        aCoder.encode(width, forKey: "width")
        aCoder.encode(userInfo, forKey: "userInfo")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        ascent = aDecoder.decodeObject(forKey: "ascent") as? CGFloat ?? 0.0
        descent = aDecoder.decodeObject(forKey: "descent") as? CGFloat ?? 0.0
        width = aDecoder.decodeObject(forKey: "width") as? CGFloat ?? 0.0
        userInfo = aDecoder.decodeObject(forKey: "userInfo") as? [AnyHashable: Any]
    }

    override init() {
        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextRunDelegate()
        one.ascent = ascent
        one.descent = descent
        one.width = width
        one.userInfo = userInfo
        return one
    }

    /**
     Creates and returns the CTRunDelegate.

     @discussion You need call CFRelease() after used.
     The CTRunDelegateRef has a strong reference to this YYTextRunDelegate object.
     In CoreText, use CTRunDelegateGetRefCon() to get this YYTextRunDelegate object.

     @return The CTRunDelegate object.
     */
//    func ctRunDelegate() -> CTRunDelegate? {
//        var callbacks: CTRunDelegateCallbacks
//        callbacks.version = CFIndex(kCTRunDelegateCurrentVersion)
//        callbacks.dealloc = DeallocCallback
//        callbacks.getAscent = GetAscentCallback
//        callbacks.getDescent = GetDecentCallback
//        callbacks.getWidth = GetWidthCallback
//
//        return CTRunDelegateCreate(&callbacks, &copy())
//    }
}
