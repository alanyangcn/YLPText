//
//  YYTextDebugOption.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit
// FIXME: 没做完
/// The YYTextDebugTarget protocol defines the method a debug target should implement.
/// A debug target can be add to the global container to receive the shared debug
/// option changed notification.
protocol YYTextDebugTarget: NSObjectProtocol {
    /// When the shared debug option changed, this method would be called on main thread.
    /// It should return as quickly as possible. The option's property should not be changed
    /// in this method.
    /// - Parameter option:  The shared debug option.
    func setDebugOption(_ option: YLPTextDebugOption?)
}



private var _sharedDebugLock = pthread_mutex_t()
private var _sharedDebugTargets: CFMutableSet? = nil
private let _sharedDebugOption: YLPTextDebugOption? = nil

private func sharedDebugSetRetain(_ allocator: CFAllocator?, _ value: UnsafeRawPointer?) -> UnsafeRawPointer? {
    return value
}

private func sharedDebugSetRelease(_ allocator: CFAllocator?, _ value: UnsafeRawPointer?) {
}
func sharedDebugSetFunction(_ value: UnsafeRawPointer?, _ context: UnsafeMutableRawPointer?) {
    let target = unsafeBitCast(value, to: YYTextDebugTarget.self)
    
    target.setDebugOption(_sharedDebugOption)
}

private func removeDebugTarget(_ target: UnsafeRawPointer?) {
//    initSharedDebug()
    pthread_mutex_lock(&_sharedDebugLock)
    
    CFSetRemoveValue(_sharedDebugTargets, target)
    pthread_mutex_unlock(&_sharedDebugLock)
}

/**
 The debug option for YYText.
 */
public class YLPTextDebugOption: NSObject, NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let op = YLPTextDebugOption()
        op.baselineColor = baselineColor
        op.ctFrameBorderColor = ctFrameBorderColor
        op.ctFrameFillColor = ctFrameFillColor
        op.ctLineBorderColor = ctLineBorderColor
        op.ctLineFillColor = ctLineFillColor
        op.ctLineNumberColor = ctLineNumberColor
        op.ctRunBorderColor = ctRunBorderColor
        op.ctRunFillColor = ctRunFillColor
        op.ctRunNumberColor = ctRunNumberColor
        op.cgGlyphBorderColor = cgGlyphBorderColor
        op.cgGlyphFillColor = cgGlyphFillColor
        return op
    }

    var baselineColor: UIColor? /// < baseline color
    var ctFrameBorderColor: UIColor? /// < CTFrame path border color
    var ctFrameFillColor: UIColor? /// < CTFrame path fill color
    var ctLineBorderColor: UIColor? /// < CTLine bounds border color
    var ctLineFillColor: UIColor? /// < CTLine bounds fill color
    var ctLineNumberColor: UIColor? /// < CTLine line number color
    var ctRunBorderColor: UIColor? /// < CTRun bounds border color
    var ctRunFillColor: UIColor? /// < CTRun bounds fill color
    var ctRunNumberColor: UIColor? /// < CTRun number color
    var cgGlyphBorderColor: UIColor? /// < CGGlyph bounds border color
    var cgGlyphFillColor: UIColor? /// < CGGlyph bounds fill color

    /// needDrawDebug
    /// - Returns: `YES`: at least one debug color is visible. `NO`: all debug color is invisible/nil.
    func needDrawDebug() -> Bool {
        if baselineColor != nil ||
            ctFrameBorderColor != nil ||
            ctFrameFillColor != nil ||
            ctLineBorderColor != nil ||
            ctLineFillColor != nil ||
            ctLineNumberColor != nil ||
            ctRunBorderColor != nil ||
            ctRunFillColor != nil ||
            ctRunNumberColor != nil ||
            cgGlyphBorderColor != nil ||
            cgGlyphFillColor != nil {
            return true
        }
        return false
    }

    /// Set all debug color to nil.
    func clear() {
        baselineColor = nil
        ctFrameBorderColor = nil
        ctFrameFillColor = nil
        ctLineBorderColor = nil
        ctLineFillColor = nil
        ctLineNumberColor = nil
        ctRunBorderColor = nil
        ctRunFillColor = nil
        ctRunNumberColor = nil
        cgGlyphBorderColor = nil
        cgGlyphFillColor = nil
    }

    /// Add a debug target.
    /// - Remark: When `setSharedDebugOption:` is called, all added debug target will
    /// receive `setDebugOption:` in main thread. It maintains an unsafe_unretained
    /// reference to this target. The target must to removed before dealloc.
    /// - Parameter target: A debug target.
    class func add(_ target: YYTextDebugTarget?) {
    }

    /// Remove a debug target which is added by `addDebugTarget:`.
    /// - Parameter target: A debug target.
    class func remove(_ target: YYTextDebugTarget?) {
    }

    /// Returns the shared debug option.
    /// - Returns: The shared debug option, default is nil.
    class func sharedDebugOption() -> YLPTextDebugOption? {
        return nil
    }

    /// Set a debug option as shared debug option.
    /// This method must be called on main thread.
    /// - Remark: When call this method, the new option will set to all debug target
    /// which is added by `addDebugTarget:`.
    /// - Parameter option:  A new debug option (nil is valid).
    class func setSharedDebugOption(_ option: YLPTextDebugOption?) {
        assert(Thread.isMainThread, "This method must be called on the main thread")
    }

    private func setSharedDebugOption(_ option: YLPTextDebugOption?) {
        initSharedDebug()
    }

    private func initSharedDebug() {
    }
}
