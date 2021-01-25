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
            if ctLine != oldValue {
                lineWidth = CGFloat(CTLineGetTypographicBounds(ctLine, &ascent, &descent, &leading))
                let range = CTLineGetStringRange(ctLine)
                self.range = NSRange(location: range.location, length: range.length)
                
                let count = CTLineGetGlyphCount(ctLine)
                if count > 0 {
                    let runs = CTLineGetGlyphRuns(ctLine)
                    let run =  unsafeBitCast(CFArrayGetValueAtIndex(runs, 0), to: CTRun.self)
                    var pos:CGPoint = .zero
                    CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                    firstGlyphPos = pos.x;
                } else {
                    firstGlyphPos = 0
                }
                trailingWhitespaceWidth = CGFloat(CTLineGetTrailingWhitespaceWidth(ctLine))
            } else {
                lineWidth = 0
                ascent = 0
                descent = 0
                leading = 0
                firstGlyphPos = 0
                trailingWhitespaceWidth = 0
                range = NSRange(location: 0, length: 0 )
            }
            self.reloadBounds()
        }
    } /// < CoreText line
    private var firstGlyphPos: CGFloat = 0.0
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
    
    private func reloadBounds() {
        if vertical {
            bounds = CGRect(x: position.x - descent, y: position.y, width: ascent + descent, height: lineWidth)
            bounds.origin.y += firstGlyphPos
        } else {
            bounds = CGRect(x: position.x, y: position.y - ascent, width: lineWidth, height: ascent + descent)
            bounds.origin.x += firstGlyphPos
        }
        
        attachments.removeAll()
        attachmentRanges.removeAll()
        attachmentRects.removeAll()
        
        if ctLine == nil {
            return
        }
        
        let runs = CTLineGetGlyphRuns(ctLine)
        let runCount = CFArrayGetCount(runs)
        if runCount == 0 {
            return
        }
        
        for r in 0..<runCount {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, CFIndex(r)), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
            let attachment = attrs?[NSAttributedString.Key.ylpTextAttachment] as? YLPTextAttachment
            if let attachment = attachment {
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(CFIndex(0), CFIndex(1)), &runPosition)

                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                var runWidth: CGFloat = 0
                var runTypoBounds: CGRect = .zero
                
                runWidth =  CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                
                if vertical {
                    swap(&position.x, &position.y)
                    
                    runPosition.y  = position.y + runPosition.y
                    runTypoBounds = CGRect(x: position.x + runPosition.x - descent, y: runPosition.y, width: ascent + descent, height: runWidth)
                } else {
                    runPosition.x += position.x
                    runPosition.y = position.y - runPosition.y
                    runTypoBounds = CGRect(x: runPosition.x, y: runPosition.y - ascent, width: runWidth, height: ascent + descent)
                }
                let range = CTRunGetStringRange(run)
                let runRange = NSRange(location: range.location, length: range.length)
                
                attachments.append(attachment)
                attachmentRanges.append(runRange)
                attachmentRects.append(runTypoBounds)
            }
            
        }
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
