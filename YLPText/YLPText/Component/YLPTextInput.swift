//
//  YYTextInput.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/22.
//

import UIKit

/// Text position affinity. For example, the offset appears after the last
/// character on a line is backward affinity, before the first character on
/// the following line is forward affinity.
enum YLPTextAffinity: Int {
    case forward = 0 /// < offset appears before the character
    case backward = 1
}

/// A YYTextPosition object represents a position in a text container; in other words,
/// it is an index into the backing string in a text-displaying view.
/// YYTextPosition has the same API as Apple's implementation in UITextView/UITextField,
/// so you can alse use it to interact with UITextView/UITextField.
class YLPTextPosition: UITextPosition, NSCopying {
    private(set) var offset = 0
    private(set) var affinity: YLPTextAffinity = .forward

    convenience init(offset: Int) {
        self.init()
        self.offset = offset
    }

    convenience init(offset: Int, affinity: YLPTextAffinity) {
        self.init()
        self.offset = offset
        self.affinity = affinity
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return YLPTextPosition(offset: offset, affinity: affinity)
    }

    override var hash: Int {
        return offset * 2 + (affinity == .forward ? 1 : 0)
    }

    override var description: String {
        return String(format: "<YLPTextPosition> (%@%@)", offset, affinity == .forward ? "F" : "B")
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? YLPTextPosition {
            if offset == other.offset && affinity == other.affinity {
                return true
            }
        }

        return false
    }

    func compare(_ otherPosition: YLPTextPosition?) -> ComparisonResult {
        if otherPosition == nil {
            return .orderedAscending
        }
        guard let otherPosition = otherPosition else { return .orderedAscending }
        if offset < otherPosition.offset {
            return .orderedAscending
        }
        if offset > otherPosition.offset {
            return .orderedDescending
        }
        if affinity == .backward && otherPosition.affinity == .forward {
            return .orderedAscending
        }
        if affinity == .forward && otherPosition.affinity == .backward {
            return .orderedDescending
        }
        return .orderedSame
    }
}

/// A YYTextRange object represents a range of characters in a text container; in other words,
/// it identifies a starting index and an ending index in string backing a text-displaying view.
/// YYTextRange has the same API as Apple's implementation in UITextView/UITextField,
/// so you can alse use it to interact with UITextView/UITextField.
class YLPTextRange: UITextRange, NSCopying {
    
    static let defaultRange = YLPTextRange()
    
    private(set) override var start: UITextPosition {
        get {
            _start ?? YLPTextPosition()
        }
        
        set {
            _start = newValue as? YLPTextPosition
        }
    }
    
    private var _start: YLPTextPosition? = YLPTextPosition()
    
    private(set) override var end: UITextPosition {
        get {
            _end ?? YLPTextPosition()
        }
        
        set {
            _end = newValue as? YLPTextPosition
        }
    }
    
    private var _end: YLPTextPosition? = YLPTextPosition()
    
    
    private(set) override var isEmpty: Bool {
        get {
            _isEmpty
        }
        set {
            _isEmpty = newValue
        }
    }
    private var _isEmpty = false
    
    convenience init(range: NSRange) {
        self.init()
        start = YLPTextPosition(offset: range.location)
        end = YLPTextPosition(offset: range.location + range.length)
    }

    convenience init(range: NSRange, affinity: YLPTextAffinity) {
        self.init()
        start = YLPTextPosition(offset: range.location, affinity: affinity)
        end = YLPTextPosition(offset: range.location + range.length, affinity: affinity)
    }

    convenience init(start: YLPTextPosition, end: YLPTextPosition) {
        self.init()
        
        
        self.start = start
        self.end = end
        
    }

    func asRange() -> NSRange {
        if let start = start as? YLPTextPosition, let end = end as? YLPTextPosition {
            return NSRange(location: start.offset, length: end.offset - start.offset)
        }
        return NSRange(location: 0, length: 0)
    }

    override init() {
        super.init()
        
    }
    func copy(with zone: NSZone? = nil) -> Any {
        if let start = start as? YLPTextPosition, let end = end as? YLPTextPosition {
            return YLPTextRange(start: start, end: end) 
        }
        return YLPTextRange()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? YLPTextRange  else { return false }
        
        return start == other.start && end == other.end
    }
}

public class YLPTextSelectionRect: UITextSelectionRect, NSCopying {
    private var _rect: CGRect = .zero
    override public var rect: CGRect {
        set {
            _rect = newValue
        }
        get {
            _rect
        }
    }

    private var _writingDirection: UITextWritingDirection = .natural
    override public var writingDirection: UITextWritingDirection {
        set {
            _writingDirection = newValue
        }
        get {
            _writingDirection
        }
    }

    private var _containsStart: Bool = false
    override public var containsStart: Bool {
        set {
            _containsStart = newValue
        }
        get {
            _containsStart
        }
    }

    private var _containsEnd: Bool = false
    override public var containsEnd: Bool {
        set {
            _containsEnd = newValue
        }
        get {
            _containsEnd
        }
    }

    private var _isVertical: Bool = false
    override public var isVertical: Bool {
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
