//
//  YYTextInput.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/22.
//

import UIKit

public class YLPTextSelectionRect: UITextSelectionRect, NSCopying {
    private var _rect: CGRect = .zero
    public override var rect: CGRect {
        set {
            _rect = newValue
        }
        get {
            _rect
        }
    }
    
    private var _writingDirection: UITextWritingDirection = .natural
    public override var writingDirection: UITextWritingDirection {
        set {
            _writingDirection = newValue
        }
        get {
            _writingDirection
        }
    }
    
    
    private var _containsStart: Bool = false
    public override var containsStart: Bool {
        set {
            _containsStart = newValue
        }
        get {
            _containsStart
        }
    }
    
    private var _containsEnd: Bool = false
    public override var containsEnd: Bool {
        set {
            _containsEnd = newValue
        }
        get {
            _containsEnd
        }
    }
    
    private var _isVertical: Bool = false
    public override var isVertical: Bool {
        set {
            _isVertical = newValue
        }
        get {
            _isVertical
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextSelectionRect()
        one.rect = rect
        one.writingDirection = writingDirection
        one.containsStart = containsStart
        one.containsEnd = containsEnd
        one.isVertical = isVertical
        return one
    }
}
