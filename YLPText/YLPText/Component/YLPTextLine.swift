//
//  YYTextLine.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import CoreText
import UIKit
class YLPTextLine {

    var index: Int = 0
    var row: Int = 0
    var bounds: CGRect = .zero
    var position: CGPoint = .zero

    var verticalRotateRange: [[YLPTextRunGlyphRange]]?

    private(set) var ctLine: CTLine! {
        didSet {
            range = NSRange(location: 0, length: 0)
        }
    } /// < CoreText line
    private(set) var range: NSRange? /// < string range
    private(set) var vertical = false /// < vertical form
    private(set) var size = CGSize.zero /// < bounds.size
    private(set) var width: CGFloat = 0.0 /// < bounds.size.width
    private(set) var height: CGFloat = 0.0 /// < bounds.size.height
    private(set) var top: CGFloat = 0.0 /// < bounds.origin.y
    private(set) var bottom: CGFloat = 0.0 /// < bounds.origin.y + bounds.size.height
    private(set) var left: CGFloat = 0.0 /// < bounds.origin.x
    private(set) var right: CGFloat = 0.0 /// < bounds.origin.x + bounds.size.width
    private(set) var ascent: CGFloat = 0.0 /// < line ascent
    private(set) var descent: CGFloat = 0.0 /// < line descent
    private(set) var leading: CGFloat = 0.0 /// < line leading
    private(set) var lineWidth: CGFloat = 0.0 /// < line width
    private(set) var trailingWhitespaceWidth: CGFloat = 0.0
    private(set) var attachments = [YLPTextAttachment]() /// < YYTextAttachment
    private(set) var attachmentRanges = [NSRange]() /// < NSRange(NSValue)
    private(set) var attachmentRects = [CGRect]() /// < CGRect(NSValue)
    
    required init() {
        
    }
    class func line(with CTLine: CTLine, position: CGPoint, vertical isVertical: Bool) -> Self {
 
        let line = self.init()
        line.position = position
        line.vertical = isVertical
        line.ctLine = CTLine
        return line
    }
}



enum YLPTextRunGlyphDrawMode : Int {
    /// No rotate.
    case horizontal = 0
    /// Rotate vertical for single glyph.
    case verticalRotate = 1
    /// Rotate vertical for single glyph, and move the glyph to a better position,
    /// such as fullwidth punctuation.
    case verticalRotateMove = 2
}

/// A range in CTRun, used for vertical form.
class YLPTextRunGlyphRange {
    var glyphRangeInRun = NSRange(location: 0, length: 0)
    var drawMode: YLPTextRunGlyphDrawMode = .horizontal

    convenience init(range: NSRange, drawMode mode: YLPTextRunGlyphDrawMode) {
        self.init()
        self.glyphRangeInRun = range
        self.drawMode = mode
    }

}
