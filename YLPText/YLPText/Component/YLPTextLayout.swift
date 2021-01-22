//
//  YLPTextLayout.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import CoreText
import UIKit
struct YLPTextBorderType: OptionSet {
    let rawValue: Int

    static let backgound = YLPTextBorderType(rawValue: 1 << 0)
    static let normal = YLPTextBorderType(rawValue: 1 << 1)
}

class YLPTextContainer: NSObject, NSCopying {
    var readOnly = false
    var verticalForm: Bool = false
    var size: CGSize = .zero
    var insets: UIEdgeInsets = .zero
    var maximumNumberOfRows: UInt = 0

    var path: UIBezierPath?
    /// An array of `UIBezierPath` for path exclusion. Default is nil.
    var exclusionPaths = [UIBezierPath]()
    /// Path line width. Default is 0;
    var pathLineWidth: CGFloat = 0.0
    var pathFillEvenOdd = false

    var truncationType = YYTextTruncationType.none

    var truncationToken: NSAttributedString?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let container = YLPTextContainer()
        container.size = size
        container.insets = insets
        container.path = path
        container.exclusionPaths = exclusionPaths
        container.pathFillEvenOdd = pathFillEvenOdd
        container.pathLineWidth = pathLineWidth
        container.verticalForm = verticalForm
        container.maximumNumberOfRows = maximumNumberOfRows
        container.truncationType = truncationType
        container.truncationToken = truncationToken?.copy() as? NSAttributedString
        
        return container
    }
}

struct YYRowEdge {
    var head: CGFloat = 0
    var foot: CGFloat = 0
}

class YLPTextLayout {
    var lines = [YLPTextLine]()

    private(set) var container: YLPTextContainer!
    private(set) var text: NSAttributedString!
    private(set) var range: NSRange!

    private(set) var frameSetter: CTFramesetter!
    private(set) var frame: CTFrame!

    private(set) var truncatedLine: YLPTextLine?
    private(set) var attachments = [YLPTextAttachment]()
    private(set) var attachmentRanges = [NSRange]()
    private(set) var attachmentRects = [CGRect]()
    private(set) var attachmentContentsSet: Set<AnyHashable>?
    private(set) var rowCount: UInt = 0
    private(set) var visibleRange: NSRange!
    private(set) var textBoundingRect = CGRect.zero
    private(set) var textBoundingSize = CGSize.zero
    private(set) var containsHighlight = false
    private(set) var needDrawBlockBorder = false
    private(set) var needDrawBackgroundBorder = false
    private(set) var needDrawShadow = false
    private(set) var needDrawUnderline = false
    private(set) var needDrawText = false
    private(set) var needDrawAttachment = false
    private(set) var needDrawInnerShadow = false
    private(set) var needDrawStrikethrough = false
    private(set) var needDrawBorder = false
    private var lineRowsIndex: UInt = 0
    private var lineRowsEdge: YYRowEdge? /// < top-left origin
    static func layout(container: YLPTextContainer, text: NSAttributedString) -> YLPTextLayout? {
        return layout(container: container, text: text, range: NSRange(location: 0, length: text.length))
    }

    static func layout(container: YLPTextContainer, text: NSAttributedString, range: NSRange) -> YLPTextLayout? {
        var cgPath: CGPath?
        var cgPathBox: CGRect = .zero
        var isVerticalForm = false
        var rowMaySeparated = false
        var frameAttrs = [CFString: Any?]()
        var ctSetter: CTFramesetter?
        var ctFrame: CTFrame?
        var ctLines: CFArray?
        var lineOrigins: UnsafeMutablePointer<CGPoint>?

        var lineCount = 0
        var lines = [YLPTextLine]()
        var attachments = [YLPTextAttachment]()
        var attachmentRanges = [NSRange]()
        var attachmentRects = [CGRect]()

        var attachmentContentsSet: Set<AnyHashable>?
        var needTruncation = false
        var truncationToken: NSAttributedString?
        var truncatedLine: YLPTextLine?
        var lineRowsEdge: YYRowEdge?
        let lineRowsIndex: UInt = 0
        var visibleRange: NSRange = NSRange(location: 0, length: 0)
        var maximumNumberOfRows: UInt = 0
        var constraintSizeIsExtended = false
        var constraintRectBeforeExtended: CGRect = .zero

        let text = text.mutableCopy() as! NSMutableAttributedString
        let container = container.copy() as! YLPTextContainer

        if range.location + range.length > text.length {
            return nil
        }
        container.readOnly = true
        maximumNumberOfRows = container.maximumNumberOfRows


        let needFixLayoutSizeBug = true

        let layout = YLPTextLayout()
        layout.text = text
        layout.container = container
        layout.range = range
        isVerticalForm = container.verticalForm

        // set cgPath and cgPathBox
        if container.path == nil && container.exclusionPaths.count == 0 {
            if container.size.width <= 0 || container.size.height <= 0 {
                return nil
            }
            var rect = CGRect(origin: .zero, size: container.size)
            if needFixLayoutSizeBug {
                constraintSizeIsExtended = true
                constraintRectBeforeExtended = rect.inset(by: container.insets);
                constraintRectBeforeExtended = constraintRectBeforeExtended.standardized;
                if (container.verticalForm) {
                    rect.size.width = 0x100000;
                } else {
                    rect.size.height = 0x100000;
                }
            }
            rect = rect.inset(by: container.insets)
            rect = rect.standardized
            cgPathBox = rect
            rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
            cgPath = CGPath(rect: rect, transform: nil)
        } else if container.path != nil && container.path!.cgPath.isRect(&cgPathBox) && container.exclusionPaths.count == 0 {
            let rect = cgPathBox.applying(CGAffineTransform(scaleX: 1, y: -1))
            cgPath = CGPath(rect: rect, transform: nil) // let CGPathIsRect() returns true
        } else {
            rowMaySeparated = true
            var path: CGMutablePath?
            if let thePath = container.path {
                path = thePath.cgPath.mutableCopy()
            } else {
                var rect = CGRect(origin: .zero, size: container.size)
                rect = rect.inset(by: container.insets)
                let rectPath = CGPath(rect: rect, transform: nil)
                path = rectPath.mutableCopy()
            }
            if path != nil {
                (layout.container.exclusionPaths as NSArray).enumerateObjects({ onePath, idx, stop in
                    path?.addPath((onePath as? UIBezierPath)!.cgPath, transform: .identity)
                })

                cgPathBox = path!.boundingBoxOfPath
                var trans = CGAffineTransform(scaleX: 1, y: -1)
                let transPath = path!.mutableCopy(using: &trans)

                path = transPath
            }
            cgPath = path
        }
        if cgPath == nil {
            return nil
        }

        if !container.pathFillEvenOdd {
            frameAttrs[kCTFramePathFillRuleAttributeName] = CTFramePathFillRule.windingNumber
        }
        if container.pathLineWidth > 0 {
            frameAttrs[kCTFramePathWidthAttributeName] = container.pathLineWidth
        }
        if container.verticalForm {
            frameAttrs[kCTFrameProgressionAttributeName] = CTFrameProgression.rightToLeft
        }

        // create CoreText objects
        ctSetter = CTFramesetterCreateWithAttributedString(text)

        guard let ctSetterMust = ctSetter else { return nil }
        ctFrame = CTFramesetterCreateFrame(ctSetterMust, YYTextCFRangeFromNSRange(range), cgPath!, nil)
        if ctFrame == nil {
            return nil
        }
        lines = []
        ctLines = CTFrameGetLines(ctFrame!)
        lineCount = CFArrayGetCount(ctLines)
//        if lineCount > 0 {
//            lineOrigins = malloc(lineCount * sizeof(CGPoint))
//            if lineOrigins == nil {
//                return nil
//            }
//            CTFrameGetLineOrigins(ctFrame!, CFRangeMake(CFIndex(0), lineCount), (lineOrigins)!)
//        }
        if lineCount > 0 {
            lineOrigins = UnsafeMutablePointer<CGPoint>.allocate(capacity: lineCount)
            if lineOrigins == nil {
            }
            CTFrameGetLineOrigins(ctFrame!, CFRangeMake(CFIndex(0), lineCount), lineOrigins!)
        }

        var textBoundingRect: CGRect = .zero
        var textBoundingSize: CGSize = .zero

        var rowIdx = -1
        var rowCount: UInt = 0
        var lastRect = CGRect(x: 0, y: -CGFloat.greatestFiniteMagnitude, width: 0, height: 0)
        var lastPosition = CGPoint(x: 0, y: -CGFloat.greatestFiniteMagnitude)
        if isVerticalForm {
            lastRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: 0, width: 0, height: 0)
            lastPosition = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: 0)
        }

        // calculate line frame
        var lineCurrentIdx: UInt = 0
        for i in 0 ..< lineCount {
            let ctLine = unsafeBitCast(CFArrayGetValueAtIndex(ctLines!, i), to: CTLine.self)
            var ctRuns = CTLineGetGlyphRuns(ctLine)
            if CFArrayGetCount(ctRuns) == 0 {
                continue
            }

            // CoreText coordinate system
            var ctLineOrigin = lineOrigins?[i]

            // UIKit coordinate system
            var position: CGPoint = .zero
            position.x = cgPathBox.origin.x + ctLineOrigin!.x
            position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin!.y

            var line = YLPTextLine.line(with: ctLine, position: position, vertical: isVerticalForm)
            var rect = line.bounds

            if constraintSizeIsExtended {
                if isVerticalForm {
                    if rect.origin.x + rect.size.width > constraintRectBeforeExtended.origin.x + constraintRectBeforeExtended.size.width {
                        break
                    }
                } else {
                    if rect.origin.y + rect.size.height > constraintRectBeforeExtended.origin.y + constraintRectBeforeExtended.size.height {
                        break
                    }
                }
            }

            var newRow = true
            if rowMaySeparated && position.x != lastPosition.x {
                if isVerticalForm {
                    if rect.size.width > lastRect.size.width {
                        if rect.origin.x > lastPosition.x && lastPosition.x > rect.origin.x - rect.size.width {
                            newRow = false
                        }
                    } else {
                        if lastRect.origin.x > position.x && position.x > lastRect.origin.x - lastRect.size.width {
                            newRow = false
                        }
                    }
                } else {
                    if rect.size.height > lastRect.size.height {
                        if rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height {
                            newRow = false
                        }
                    } else {
                        if lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height {
                            newRow = false
                        }
                    }
                }
            }

            if newRow {
                rowIdx += 1
            }
            lastRect = rect
            lastPosition = position

            line.index = Int(lineCurrentIdx)
            line.row = rowIdx
            lines.append(line)
            rowCount = UInt(rowIdx) + 1
            lineCurrentIdx += 1

            if i == 0 {
                textBoundingRect = rect
            } else {
                if maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows {
                    textBoundingRect = textBoundingRect.union(rect)
                }
            }
        }
        if rowCount > 0 {
            if maximumNumberOfRows > 0 {
                if rowCount > maximumNumberOfRows {
                    needTruncation = true
                    rowCount = maximumNumberOfRows
                    repeat {
                        var line = lines.last
                        if line == nil {
                            break
                        }
                        if line!.row < rowCount {
                            break
                        }
                        lines.removeLast()

                    } while true
                }
            }
            var lastLine = lines.last!
            if !needTruncation && lastLine.range!.location + lastLine.range!.length < text.length {
                needTruncation = true
            }

            // Give user a chance to modify the line's position.
//            if container.linePositionModifier {
//                [container.linePositionModifier modifyLines: lines fromText: text inContainer: container]
//                textBoundingRect = CGRectZero
//                for i in 0 ..< lines.count {
//                    var line = lines[i]
//                    if i == 0 {
//                        textBoundingRect = line.bounds
//                    } else {
//                        textBoundingRect = textBoundingRect.union(line.bounds)
//                    }
//                }
//            }
//
//            lineRowsEdge = calloc(rowCount, sizeof(YYRowEdge))
//            if lineRowsEdge == nil {
//                return nil
//            }
//            lineRowsIndex = calloc(rowCount, sizeof(NSUInteger))
//            if lineRowsIndex == 0 {
//                return nil
//            }
            var lineRowsEdge = [YYRowEdge].init(repeating: YYRowEdge(head: 0, foot: 0), count: Int(rowCount))
            var lineRowsIndex = [UInt].init(repeating: 0, count: Int(rowCount))
            var lastRowIdx = -1
            var lastHead: CGFloat = 0
            var lastFoot: CGFloat = 0
            for i in 0 ..< lines.count {
                var line = lines[i]
                var rect = line.bounds
                if line.row != lastRowIdx {
                    if lastRowIdx >= 0 {
                        lineRowsEdge[lastRowIdx] = YYRowEdge(head: lastHead, foot: lastFoot)
                    }
                    lastRowIdx = line.row
                    lineRowsIndex[lastRowIdx] = UInt(i)
                    if isVerticalForm {
                        lastHead = rect.origin.x + rect.size.width
                        lastFoot = lastHead - rect.size.width
                    } else {
                        lastHead = rect.origin.y
                        lastFoot = lastHead + rect.size.height
                    }
                } else {
                    if isVerticalForm {
                        lastHead = max(lastHead, rect.origin.x + rect.size.width)
                        lastFoot = min(lastFoot, rect.origin.x)
                    } else {
                        lastHead = min(lastHead, rect.origin.y)
                        lastFoot = max(lastFoot, rect.origin.y + rect.size.height)
                    }
                }
            }
            lineRowsEdge[lastRowIdx] = YYRowEdge(head: lastHead, foot: lastFoot)

            for i in 1 ..< rowCount {
                let v0 = lineRowsEdge[Int(i) - 1]
                let v1 = lineRowsEdge[Int(i)]
                lineRowsEdge[Int(i) - 1].foot = (v0.foot + v1.head) * 0.5
                lineRowsEdge[Int(i)].head =  (v0.foot + v1.head) * 0.5
            }
        }

        var rect = textBoundingRect
        if container.path != nil {
            if container.pathLineWidth > 0 {
                let inset = container.pathLineWidth / 2
                rect = rect.insetBy(dx: -inset, dy: -inset)
            }
        } else {
            rect = rect.inset(by: YYTextUIEdgeInsetsInvert(container.insets))
        }
        rect = rect.standardized
        var size = rect.size
        if container.verticalForm {
            size.width += container.size.width - (rect.origin.x + rect.size.width)
        } else {
            size.width += rect.origin.x
        }
        size.height += rect.origin.y
        if size.width < 0 {
            size.width = 0
        }
        if size.height < 0 {
            size.height = 0
        }
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        textBoundingSize = size

        visibleRange = YYTextNSRangeFromCFRange(CTFrameGetVisibleStringRange(ctFrame!))
        if needTruncation {
            var lastLine = lines.last
            var lastRange = lastLine!.range
            visibleRange.length = lastRange!.location + lastRange!.length - visibleRange.location

            // create truncated line
            if container.truncationType != YYTextTruncationType.none {
                var truncationTokenLine: CTLine?
                if let truncationToken2 = container.truncationToken {
                    truncationToken = container.truncationToken
                    truncationTokenLine = CTLineCreateWithAttributedString(truncationToken2)
                } else {
                    var runs = CTLineGetGlyphRuns(lastLine!.ctLine)
                    var runCount = CFArrayGetCount(runs)
  
                    if runCount > 0 {
                        let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runCount - 1), to: CTRun.self)
                         
                        var attrs = CTRunGetAttributes(run) as! [String: Any]
                        
                        for k in NSMutableAttributedString.ylp_allDiscontinuousAttributeKeys() {
                            attrs.removeValue(forKey: k)

                        }
                        var font = attrs[NSAttributedString.Key.font.rawValue] as? UIFont
                        var fontSize = font?.pointSize ?? 12
  
                        
                        var uiFont = UIFont.systemFont(ofSize: fontSize * 0.9)
                        font = UIFont(name: uiFont.fontName, size: fontSize)
                        attrs[NSAttributedString.Key.font.rawValue] = font
                        
//                        let color = attrs[kCTForegroundColorAttributeName] as? CGColor?
//                        if color != nil && CFGetTypeID(color) == CGColor.typeID && color?.alpha == 0 {
//                            // ignore clear color
//                            attrs.removeValue(forKey: kCTForegroundColorAttributeName)
//                        }
//                        if !attrs {
//                            attrs = [AnyHashable: Any]()
//                        }
                    }
//                    truncationToken = [[NSAttributedString alloc] initWithString: YYTextTruncationToken attributes: attrs]
//                    truncationTokenLine = CTLineCreateWithAttributedString(CFAttributedStringRef truncationToken)
                }
//                if truncationTokenLine {
//                    var type = CTLineTruncationType.end
//                    if container.truncationType == YYTextTruncationType.start {
//                        type = CTLineTruncationType.start
//                    } else if container.truncationType == YYTextTruncationType.middle {
//                        type = CTLineTruncationType.middle
//                    }
//                    var lastLineText = [text attributedSubstringFromRange: lastLine.range].mutableCopy
//                    [lastLineText appendAttributedString: truncationToken]
//                    var ctLastLineExtend = CTLineCreateWithAttributedString(CFAttributedStringRef lastLineText)
//                    if ctLastLineExtend {
//                        var truncatedWidth = lastLine.width
//                        var cgPathRect = CGRect.zero
//                        if CGPathIsRect(cgPath, &cgPathRect) {
//                            if isVerticalForm {
//                                truncatedWidth = cgPathRect.size.height
//                            } else {
//                                truncatedWidth = cgPathRect.size.width
//                            }
//                        }
//                        var ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine)
//                        CFRelease(ctLastLineExtend)
//                        if ctTruncatedLine {
//                            truncatedLine = [YYTextLine lineWithCTLine: ctTruncatedLine position: lastLine.position vertical: isVerticalForm]
//                            truncatedLine.index = lastLine.index
//                            truncatedLine.row = lastLine.row
//                            CFRelease(ctTruncatedLine)
//                        }
//                    }
//                    CFRelease(truncationTokenLine)
//                }
            }
        }

        if isVerticalForm {
        //            var rotateCharset = YYTextVerticalFormRotateCharacterSet()
        //            var rotateMoveCharset = YYTextVerticalFormRotateAndMoveCharacterSet()

//            let lineBlock: ((YLPTextLine) -> Void)? = { line in
//
//                var runs = CTLineGetGlyphRuns(line.ctLine)
//
//                let runCount = CFArrayGetCount(runs)
//                if runCount == 0 {
//                    return
//                }
//                var lineRunRanges =  [[YLPTextRunGlyphRange]]()
//                    line.verticalRotateRange = lineRunRanges
//                    for r in 0..<runCount {
//                        let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
//                        var runRanges = [YLPTextRunGlyphRange]()
//                        lineRunRanges.append(runRanges)
//                        var glyphCount = CTRunGetGlyphCount(run)
//                        if glyphCount == 0 {
//                            continue
//                        }
//
//                        var runStrIdx = glyphCount + 1
//                        CTRunGetStringIndices(run, CFRangeMake(CFIndex(0), CFIndex(0)), &runStrIdx)
//
//                        var runStrRange = CTRunGetStringRange(run)
//                        runStrIdx[glyphCount ?? 0] = (runStrRange?.location ?? 0) + (runStrRange?.length ?? 0)
//                        var runAttrs: CFDictionary? = nil
//                        if let run = run {
//                            runAttrs = CTRunGetAttributes(run)
//                        }
//                        let font = CFDictionaryGetValue(runAttrs, UnsafeRawPointer(&kCTFontAttributeName)) as? CTFont
//                        let isColorGlyph = YYTextCTFontContainsColorBitmapGlyphs(font)
//
//                        var prevIdx = 0
//                        var prevMode = YYTextRunGlyphDrawModeHorizontal as? YYTextRunGlyphDrawMode
//                        let layoutStr = layout.text.string
//                        //  Converted to Swift 5.3 by Swiftify v5.3.21043 - https://swiftify.com/
//                        for g in 0..<glyphCount {
//                            var glyphRotate = Bool(0)
//                            var glyphRotateMove = false
//                            let runStrLen = CFIndex(runStrIdx[g + 1] - runStrIdx[g])
//                            if isColorGlyph {
//                                glyphRotate = true
//                            } else if runStrLen == 1 {
//                                let c = unichar(layoutStr[layoutStr.index(layoutStr.startIndex, offsetBy: runStrIdx[g])])
//                                glyphRotate = rotateCharset.characterIsMember(c)
//                                if glyphRotate {
//                                    glyphRotateMove = rotateMoveCharset.characterIsMember(c)
//                                }
//                            } else if runStrLen > 1 {
//                                let glyphStr = layoutStr.substring(with: NSRange(location: runStrIdx[g], length: runStrLen))
//                                var glyphRotate = (glyphStr as NSString).rangeOfCharacter(from: rotateCharset).location != NSNotFound
//                                if glyphRotate {
//                                    glyphRotateMove = (glyphStr as NSString).rangeOfCharacter(from: rotateMoveCharset).location != NSNotFound
//                                }
//                            }
//
//                            let mode = (glyphRotateMove ? YYTextRunGlyphDrawModeVerticalRotateMove : (glyphRotate ? YYTextRunGlyphDrawModeVerticalRotate : YYTextRunGlyphDrawModeHorizontal)) as? YYTextRunGlyphDrawMode
//                            if g == 0 {
//                                prevMode = mode
//                            } else if mode != prevMode {
//                                let aRange = YYTextRunGlyphRange(range: NSRange(location: prevIdx, length: g - prevIdx), drawMode: prevMode)
//                                runRanges.append(aRange)
//                                prevIdx = g
//                                prevMode = mode
//                            }
//                        }
//                    }
//                if prevIdx < glyphCount {
//                    let aRange = YYTextRunGlyphRange(range: NSRange(location: prevIdx, length: glyphCount - prevIdx), drawMode: prevMode)
//                    runRanges.append(aRange)
//                }
//                }
//
//            for line in lines {
//                lineBlock?(line)
//            }
//            if let line = truncatedLine {
//                lineBlock?(truncatedLine)
//            }
        }

        if visibleRange.length > 0 {
            layout.needDrawText = true

            let block: ((_ attrs: [AnyHashable: Any]?, _ range: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void) = { attrs, _, _ in
                guard let attrs = attrs else { return }
                if (attrs[NSAttributedString.Key.ylpTextHighlight] != nil) {
                    layout.containsHighlight = true
                }
                if attrs[NSAttributedString.Key.ylpTextBlockBorder] != nil {
                    layout.needDrawBlockBorder = true
                }
                if attrs[NSAttributedString.Key.ylpTextBackgroundBorder] != nil {
                    layout.needDrawBackgroundBorder = true
                }
                if (attrs[NSAttributedString.Key.ylpTextShadow] != nil) || (attrs[NSAttributedString.Key.shadow] != nil) {
                    layout.needDrawShadow = true
                }
                if (attrs[NSAttributedString.Key.ylpTextUnderline] != nil) {
                    layout.needDrawUnderline = true
                }
                if (attrs[NSAttributedString.Key.ylpTextAttachment] != nil) {
                    layout.needDrawAttachment = true
                }
                if (attrs[NSAttributedString.Key.ylpTextInnerShadow] != nil) {
                    layout.needDrawInnerShadow = true
                }
                if (attrs[NSAttributedString.Key.ylpTextStrikethrough] != nil) {
                    layout.needDrawStrikethrough = true
                }
                if (attrs[NSAttributedString.Key.ylpTextBorder] != nil) {
                    layout.needDrawBorder = true
                }
            }

            layout.text?.enumerateAttributes(in: visibleRange, options: .longestEffectiveRangeNotRequired, using: block)
            if truncatedLine != nil {
                truncationToken?.enumerateAttributes(in: NSRange(location: 0, length: truncationToken?.length ?? 0), options: .longestEffectiveRangeNotRequired, using: block)
            }
        }

        for i in 0 ..< lines.count {
            var line = lines[i]
            if let truncatedLine = truncatedLine, line.index == truncatedLine.index {
                line = truncatedLine
            }

            if line.attachments.count > 0 {
                attachments.append(contentsOf: line.attachments)

                attachmentRanges.append(contentsOf: line.attachmentRanges)
                attachmentRects.append(contentsOf: line.attachmentRects)

                for attachment in line.attachments {
                    if let content = attachment.content {
//                        attachmentContentsSet?.insert(attachment.content)
                    }
                }
            }
        }

        layout.frameSetter = ctSetter
        layout.frame = ctFrame
        layout.lines = lines
        layout.truncatedLine = truncatedLine
        layout.attachments = attachments
        layout.attachmentRanges = attachmentRanges
        layout.attachmentRects = attachmentRects
        layout.attachmentContentsSet = attachmentContentsSet
        layout.rowCount = rowCount
        layout.visibleRange = visibleRange
        layout.textBoundingRect = textBoundingRect
        layout.textBoundingSize = textBoundingSize
        layout.lineRowsEdge = lineRowsEdge
        layout.lineRowsIndex = lineRowsIndex

        return layout
    }

    static func ylpTextDrawBlockBorder(layout: YLPTextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Void)?) {
        context.saveGState()
        context.translateBy(x: point.x, y: point.y)

        let isVertical = layout.container.verticalForm
        let verticalOffset = isVertical ? (size.width - layout.container!.size.width) : 0

        let lines = layout.lines

        for (index, line) in lines.enumerated() {
            if cancel != nil {
                break
            }

//            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            let runs = CTLineGetGlyphRuns(line.ctLine)
            for r in 0 ..< CFArrayGetCount(runs) {
                let run = CFArrayGetValueAtIndex(runs, r)
                let glyphCount = CTRunGetGlyphCount(run as! CTRun)
                if glyphCount == 0 {
                    continue
                }
                let attrs = CTRunGetAttributes(run as! CTRun) as! Dictionary<String, Any?>

                let border = attrs[NSAttributedString.Key.ylpTextBlockBorder.rawValue] as? YLPTextBorder
                if border == nil {
                    continue
                }

                var lineStartIndex = line.index
                while lineStartIndex > 0 {
                    if lines[lineStartIndex - 1].row == line.row {
                        lineStartIndex -= 1
                    } else {
                        break
                    }
                }

                var unionRect = CGRect.zero
                let lineStartRow = lines[lineStartIndex].row
                var lineContinueIndex = lineStartIndex
                var lineContinueRow = lineStartRow
                repeat {
                    let one = lines[lineContinueIndex]
                    if lineContinueIndex == lineStartIndex {
                        unionRect = one.bounds
                    } else {
                        unionRect = unionRect.union(one.bounds)
                    }
                    if lineContinueIndex + 1 == lines.count {
                        break
                    }
                    let next = lines[lineContinueIndex + 1]
                    if next.row != lineContinueRow {
                        let nextBorder = NSAttributedString().attribute(name: NSAttributedString.Key.ylpTextBlockBorder, at: 0) as? YLPTextBorder
                        if nextBorder == border {
                            lineContinueRow += 1
                        } else {
                            break
                        }
                    }
                    lineContinueIndex += 1
                } while true

                if isVertical {
                    let insets = layout.container!.insets
                    unionRect.origin.y = insets.top
                    unionRect.size.height = layout.container!.size.height - insets.top - insets.bottom
                } else {
                    let insets = layout.container!.insets
                    unionRect.origin.x = insets.left
                    unionRect.size.width = layout.container!.size.width - insets.left - insets.right
                }
                unionRect.origin.x += verticalOffset
//                YYTextDrawBorderRects(context, size, border, @[[NSValue valueWithCGRect:unionRect]], isVertical);

//                l = lineContinueIndex
                break
            }
        }

        context.restoreGState()
    }

    func draw(in context: CGContext, size: CGSize, point: CGPoint, view: UIView?, layer: CALayer?, debug: YYTextDebugOption?, cancel: (() -> Bool)?) {
//        drawShadow(layout: self, context: context, size: size, point: point, cancel: cancel)
        drawText(layout: self, context: context, size: size, point: point, cancel: cancel)
//        drawInnerShadow(layout: self, context: context, size: size, point: point, cancel: cancel)
//        drawBorder(layout: self, context: context, size: size, point: point, type: .backgound, cancel: cancel)
    }

    /// 绘制边框
    /// - Parameters:
    ///   - layout: layout
    ///   - context: 图形上下文
    ///   - size: size
    ///   - point: point
    ///   - cancel: 是否取消
    func drawBorder(layout: YLPTextLayout, context: CGContext, size: CGSize, point: CGPoint, type: YLPTextBorderType, cancel: (() -> Bool)?) {
        context.saveGState()
        context.translateBy(x: point.x, y: point.y)

        let isVertical = layout.container.verticalForm
        let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0

        let borderKey: NSAttributedString.Key = (type == YLPTextBorderType.normal ? .ylpTextBorder : .ylpTextBackgroundBorder)

        var needJumpRun = false
        var jumpRunIndex = 0
        var l = 0
        while l < layout.lines.count {
            if let cancel = cancel, cancel() {
                break
            }
            var line = layout.lines[l]
            if let truncatedLine = layout.truncatedLine, truncatedLine.index == line.index {
                line = truncatedLine
            }
            let runs = CTLineGetGlyphRuns(line.ctLine)
            let rMax = CFArrayGetCount(runs)
            var r = 0
            while r < rMax {
                if needJumpRun {
                    needJumpRun = false
                    r = jumpRunIndex + 1
                    if r >= rMax {
                        break
                    }
                }

                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
                let glyphCount = CTRunGetGlyphCount(run)
                if glyphCount == 0 {
                    r += 1
                    continue
                }

                let attrs = CTRunGetAttributes(run) as? [String: Any]

                guard let border = attrs?[borderKey.rawValue] as? YLPTextBorder else {
                    r += 1
                    continue
                }

                let runRange = CTRunGetStringRange(run)
                if runRange.location == kCFNotFound || runRange.length == 0 {
                    r += 1
                    continue
                }
                if runRange.location + runRange.length > layout.text.length {
                    r += 1
                    continue
                }

                var runRects: [CGRect] = []
                var endLineIndex = l
                var endRunIndex = r
                var endFound = false

                var ll = l
                while ll < lines.count {
                    if endFound {
                        break
                    }
                    let iLine = lines[ll]
                    let iRuns = CTLineGetGlyphRuns(iLine.ctLine)

                    var extLineRect = CGRect.null

                    var rr = (ll == l) ? r : 0, rrMax = CFArrayGetCount(iRuns)
                    while rr < rrMax {
                        let iRun = unsafeBitCast(CFArrayGetValueAtIndex(iRuns, rr), to: CTRun.self)
                        let iAttrs = CTRunGetAttributes(iRun) as? [String: Any]
                        let iBorder = iAttrs?[borderKey.rawValue] as? YLPTextBorder
                        if border != iBorder {
                            endFound = true
                            break
                        }
                        endLineIndex = ll
                        endRunIndex = rr

                        var iRunPosition = CGPoint.zero
                        CTRunGetPositions(iRun, CFRangeMake(CFIndex(0), CFIndex(1)), &iRunPosition)
                        var ascent: CGFloat = .zero
                        var descent: CGFloat = .zero
                        var iRunWidth: CGFloat = 0
                        iRunWidth = CGFloat(CTRunGetTypographicBounds(iRun, CFRangeMake(CFIndex(0), CFIndex(0)), &ascent, &descent, nil))

                        if isVertical {
                            swap(&iRunPosition.x, &iRunPosition.y)
                            iRunPosition.y += iLine.position.y
                            let iRect = CGRect(x: verticalOffset + line.position.x - descent, y: iRunPosition.y, width: ascent + descent, height: iRunWidth)
                            if extLineRect.isNull {
                                extLineRect = iRect
                            } else {
                                extLineRect = extLineRect.union(iRect)
                            }
                        } else {
                            iRunPosition.x += iLine.position.x
                            let iRect = CGRect(x: iRunPosition.x, y: iLine.position.y - ascent, width: iRunWidth, height: ascent + descent)
                            if extLineRect.isNull {
                                extLineRect = iRect
                            } else {
                                extLineRect = extLineRect.union(iRect)
                            }
                        }

                        rr += 1
                    }
                    if !extLineRect.isNull {
                        runRects.append(extLineRect)
                    }

                    var drawRects: [CGRect] = []

                    var re = 0, reMax = runRects.count
                    var curRect = runRects.first ?? .zero

                    while re < reMax {
                        let rect = runRects[re]
                        if isVertical {
                            if abs(rect.origin.x - curRect.origin.x) < 1 {
                                curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical)
                            } else {
                                drawRects.append(curRect)
                                curRect = rect
                            }
                        } else {
                            if abs(rect.origin.y - curRect.origin.y) < 1 {
                                curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical)
                            } else {
                                drawRects.append(curRect)
                                curRect = rect
                            }
                        }
                        re += 1
                    }

                    if curRect != .zero {
                        drawRects.append(curRect)
                    }

                    drawBorderRects(context: context, size: size, border: border, rects: drawRects, isVertical: isVertical)

                    if l == endLineIndex {
                        r = endRunIndex
                    } else {
                        l = endLineIndex - 1
                        needJumpRun = true
                        jumpRunIndex = endRunIndex
                        break
                    }
                    ll += 1
                }
                r += 1
            }
            l += 1
        }
        context.restoreGState()
    }

    private func YYTextMergeRectInSameLine(_ rect1: CGRect, _ rect2: CGRect, _ isVertical: Bool) -> CGRect {
        if isVertical {
            let top = min(rect1.origin.y, rect2.origin.y)
            let bottom = max(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height)
            let width = max(rect1.size.width, rect2.size.width)
            return CGRect(x: rect1.origin.x, y: top, width: width, height: bottom - top)
        } else {
            let left = min(rect1.origin.x, rect2.origin.x)
            let right = max(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width)
            let height = max(rect1.size.height, rect2.size.height)
            return CGRect(x: left, y: rect1.origin.y, width: right - left, height: height)
        }
    }

    private func drawBorderRects(context: CGContext, size: CGSize, border: YLPTextBorder, rects: [CGRect], isVertical: Bool) {
        if rects.count == 0 {
            return
        }

        let shadow = border.shadow
        if let color = shadow?.color {
            context.saveGState()
            context.setShadow(offset: shadow?.offset ?? CGSize.zero, blur: shadow?.radius ?? 0.0, color: color.cgColor)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
        }

        var paths: [UIBezierPath] = []
        for i in 0 ..< rects.count {
            var rect = rects[i]
            if isVertical {
                rect = rect.inset(by: edgeInsetRotateVertical(border.insets))
            } else {
                rect = rect.inset(by: border.insets)
            }
            rect = YLPTextCGRectPixelRound(rect)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius)
            path.close()
            paths.append(path)
        }
        if border.fillColor != nil {
            context.saveGState()
            if let CGColor = border.fillColor?.cgColor {
                context.setFillColor(CGColor)
            }
            for path in paths {
                context.addPath(path.cgPath)
            }
            context.fillPath()
            context.restoreGState()
        }

        let type = YLPTextLineStyle(rawValue: border.lineStyle.rawValue & 0xFF)
        if border.strokeColor != nil && border.lineStyle.rawValue > 0 && border.strokeWidth > 0 {
            // -------------------------- single line ------------------------------//
            context.saveGState()
            for path in paths {
                var bounds = path.bounds.union(CGRect(origin: CGPoint.zero, size: size))
                bounds = bounds.insetBy(dx: -2 * border.strokeWidth, dy: -2 * border.strokeWidth)
                context.addRect(bounds)
                context.addPath(path.cgPath)
                context.clip(using: .evenOdd)
            }
            border.strokeColor?.setStroke()
            setLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context)
            var inset: CGFloat = -border.strokeWidth * 0.5
            if type == .thick {
                inset *= 2
                context.setLineWidth(border.strokeWidth * 2)
            }
            var radiusDelta = -inset
            if border.cornerRadius <= 0 {
                radiusDelta = 0
            }
            context.setLineJoin(border.lineJoin)
            for i in 0 ..< rects.count {
                var rect = rects[i]
                if isVertical {
                    rect = rect.inset(by: edgeInsetRotateVertical(border.insets))
                } else {
                    rect = rect.inset(by: border.insets)
                }
                rect = rect.insetBy(dx: inset, dy: inset)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + radiusDelta)
                path.close()
                context.addPath(path.cgPath)
            }
            context.strokePath()
            context.restoreGState()

            if type == .double {
                context.saveGState()
                var inset: CGFloat = -border.strokeWidth * 2
                for i in 0 ..< rects.count {
                    var rect = rects[i]
                    rect = rect.inset(by: border.insets)
                    rect = rect.insetBy(dx: inset, dy: inset)
                    let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + 2 * border.strokeWidth)
                    path.close()

                    var bounds = path.bounds.union(CGRect(origin: CGPoint.zero, size: size))
                    bounds = bounds.insetBy(dx: -2 * border.strokeWidth, dy: -2 * border.strokeWidth)
                    context.addRect(bounds)
                    context.addPath(path.cgPath)
                    context.clip(using: .evenOdd)
                }
                if let CGColor = border.strokeColor?.cgColor {
                    context.setStrokeColor(CGColor)
                }
                setLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context)
                context.setLineJoin(border.lineJoin)
                inset = -border.strokeWidth * 2.5
                radiusDelta = border.strokeWidth * 2
                if border.cornerRadius <= 0 {
                    radiusDelta = 0
                }
                for i in 0 ..< rects.count {
                    var rect = rects[i]
                    rect = rect.inset(by: border.insets)
                    rect = rect.insetBy(dx: inset, dy: inset)
                    let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + radiusDelta)
                    path.close()
                    context.addPath(path.cgPath)
                }
                context.strokePath()
                context.restoreGState()
            }

            if let _ = shadow?.color {
                context.endTransparencyLayer()
                context.restoreGState()
            }
        }
    }

    private func setLinePatternInContext(_ style: YLPTextLineStyle, _ width: CGFloat, _ phase: CGFloat, _ context: CGContext) {
        context.setLineWidth(width)
        context.setLineCap(.butt)
        context.setLineJoin(.miter)

        let dash: CGFloat = 12
        let dot: CGFloat = 5
        let space: CGFloat = 3
        let pattern = YLPTextLineStyle(rawValue: style.rawValue & 0xF00)
        if pattern == .patternSolid {
            context.setLineDash(phase: phase, lengths: [])
        } else if pattern == .patternDot {
            let lengths = [width * dot, width * space]
            context.setLineDash(phase: phase, lengths: lengths)
        } else if pattern == .patternDash {
            let lengths = [width * dash, width * space]
            context.setLineDash(phase: phase, lengths: lengths)
        } else if pattern == .patternDashDot {
            let lengths = [width * dash, width * space, width * dot, width * space]
            context.setLineDash(phase: phase, lengths: lengths)
        } else if pattern == .patternDashDotDot {
            let lengths = [width * dash, width * space, width * dot, width * space, width * dot, width * space]
            context.setLineDash(phase: phase, lengths: lengths)
        } else if pattern == .patternCircleDot {
            let lengths = [width * 0, width * 3]
            context.setLineDash(phase: phase, lengths: lengths)
            context.setLineCap(.round)
            context.setLineJoin(.round)
        }
    }

    @inline(__always) private func YLPTextCGRectPixelRound(_ rect: CGRect) -> CGRect {
        let origin = YLPTextCGPointPixelRound(rect.origin)
        let corner = YLPTextCGPointPixelRound(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }

    /// 绘制阴影
    /// - Parameters:
    ///   - layout: layout
    ///   - context: 图形上下文
    ///   - size: size
    ///   - point: point
    ///   - cancel: 是否取消
    func drawShadow(layout: YLPTextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)?) {
        let offsetAlterX: CGFloat = size.width + 0xFFFF

        let isVertical = layout.container!.verticalForm
        let verticalOffset: CGFloat = isVertical ? (size.width - layout.container!.size.width) : 0

        context.saveGState()
        do {
            context.translateBy(x: point.x, y: point.y)
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
            let lines = layout.lines
            for l in 0 ..< layout.lines.count {
                var line = lines[l]
                if let truncatedLine = layout.truncatedLine, truncatedLine.index == line.index {
                    line = truncatedLine
                }
                let lineRunRanges = line.verticalRotateRange
                let linePosX = line.position.x
                let linePosY = size.height - line.position.y
                var runs: CFArray?
                if let CTLine = line.ctLine {
                    runs = CTLineGetGlyphRuns(CTLine)
                }

                for r in 0 ..< CFArrayGetCount(runs) {
                    let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)

                    context.textMatrix = .identity
                    context.textPosition = CGPoint(x: linePosX, y: linePosY)
                    let attrs = CTRunGetAttributes(run) as? [AnyHashable: Any]
                    let shadow = attrs?[NSAttributedString.Key.ylpTextShadow] as? YLPTextShadow

                    if let shadow = shadow {
                        var offset = shadow.offset
                        offset.width -= offsetAlterX
                        context.saveGState()
                        do {
                            context.setShadow(offset: offset, blur: shadow.radius, color: shadow.color?.cgColor)
                            context.setBlendMode(shadow.blendMode)
                            context.translateBy(x: offsetAlterX, y: 0)
                            drawRun(line, run, context, size, isVertical, lineRunRanges?[r], verticalOffset)
                        }
                        context.restoreGState()
                    }
                }
            }
        }
        context.restoreGState()
    }

    /// 绘制文字
    /// - Parameters:
    ///   - layout: layout
    ///   - context: 图形上下文
    ///   - size: size
    ///   - point: point
    ///   - cancel: 是否取消
    private func drawText(layout: YLPTextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)?) {
        context.saveGState()
        do {
            context.translateBy(x: point.x, y: point.y)
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)

            let isVertical = layout.container?.verticalForm ?? false
            let verticalOffset = isVertical ? (size.width - (layout.container?.size.width ?? 0.0)) : 0

            for l in 0 ..< layout.lines.count {
                var line = layout.lines[l]
                if let truncatedLine = layout.truncatedLine, truncatedLine.index == line.index {
                    line = truncatedLine
                }
                let lineRunRanges = line.verticalRotateRange
                let posX = line.position.x + verticalOffset
                let posY = size.height - line.position.y
                let runs = CTLineGetGlyphRuns(line.ctLine)
                
                for r in 0..<CFArrayGetCount(runs) {
                    let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
                    context.textMatrix = .identity
                    context.textPosition = CGPoint(x: posX, y: posY)
                    drawRun(line, run, context, size, isVertical, lineRunRanges?[r], verticalOffset)
                    
                }
            }
            // Use this to draw frame for test/debug.
            // CGContextTranslateCTM(context, verticalOffset, size.height);
            // CTFrameDraw(layout.frame, context);
        }
        context.restoreGState()
    }

    private func drawRun(_ line: YLPTextLine?, _ run: CTRun, _ context: CGContext, _ size: CGSize, _ isVertical: Bool, _ runRanges: [YLPTextRunGlyphRange]?, _ verticalOffset: CGFloat) {
        let runTextMatrix = CTRunGetTextMatrix(run)
        let runTextMatrixIsID = runTextMatrix.isIdentity

        if let runAttrs = CTRunGetAttributes(run) as? [String: Any?] {
            
        }
//        runAttrs[]
//        let glyphTransformValue = CFDictionaryGetValue(runAttrs, &YYTextGlyphTransformAttributeName) as? NSValue

        CTRunDraw(run, context, CFRangeMake(0, 0))
    }

    // MARK: - 已完成

    func drawInnerShadow(layout: YLPTextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)?) {
        context.saveGState()
        context.translateBy(x: point.x, y: point.y)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity

        let isVertical = layout.container.verticalForm
        let verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0

        for l in 0 ..< layout.lines.count {
            var line = layout.lines[l]
            if let cancel = cancel, cancel() {
                break
            }
            if let truncatedLine = layout.truncatedLine, truncatedLine.index == line.index {
                line = truncatedLine
            }
            let lineRunRanges = line.verticalRotateRange
            let linePosX = line.position.x
            let linePosY: CGFloat = size.height - line.position.y
            let runs = CTLineGetGlyphRuns(line.ctLine)

            for r in 0 ..< CFArrayGetCount(runs) {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)

                let glyphCount = CTRunGetGlyphCount(run)
                if glyphCount == 0 {
                    continue
                }
                context.textMatrix = .identity
                context.textPosition = CGPoint(x: linePosX, y: linePosY)
                let attrs = CTRunGetAttributes(run) as! Dictionary<String, Any?>

                let shadow = attrs[NSAttributedString.Key.ylpTextInnerShadow.rawValue] as? YLPTextShadow
                if let shadow = shadow {
                    if shadow.color == nil {
//                        shadow = shadow.subShadow ?? YLPTextShadow()
                        continue
                    }
                    var runPosition = CGPoint.zero
                    CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)
                    var runImageBounds = CTRunGetImageBounds(run, context, CFRangeMake(0, 0))
                    runImageBounds.origin.x += runPosition.x
                    if runImageBounds.size.width < 0.1 || runImageBounds.size.height < 0.1 {
                        continue
                    }

                    let runAttrs = CTRunGetAttributes(run)
//                    let glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
//                    if (glyphTransformValue) {
//                        runImageBounds = CGRectMake(0, 0, size.width, size.height);
//                    }

                    // text inner shadow
                    context.saveGState()
                    do {
                        context.setBlendMode(shadow.blendMode)
                        context.setShadow(offset: CGSize.zero, blur: 0, color: nil)
                        context.setAlpha(shadow.color!.cgColor.alpha)
                        context.clip(to: runImageBounds)
                        context.beginTransparencyLayer(auxiliaryInfo: nil)
                        do {
                            let opaqueShadowColor = shadow.color!.withAlphaComponent(1)
                            context.setShadow(offset: shadow.offset, blur: shadow.radius, color: opaqueShadowColor.cgColor)
                            context.setFillColor(opaqueShadowColor.cgColor)
                            context.setBlendMode(.sourceOut)
                            context.beginTransparencyLayer(auxiliaryInfo: nil)
                            do {
                                context.fill(runImageBounds)
                                context.setBlendMode(.destinationIn)
                                context.beginTransparencyLayer(auxiliaryInfo: nil)

                                drawRun(line, run, context, size, isVertical, lineRunRanges?[r], verticalOffset)
                                context.endTransparencyLayer()
                            }
                            context.endTransparencyLayer()
                        }
                        context.endTransparencyLayer()
                    }
                    context.restoreGState()
                }
            }
        }
        context.restoreGState()
    }

    func textDrawRun(line: YLPTextLine, run: CTRun, context: CGContext, size: CGSize, isVertical: Bool, runRanges: Array<Any>, verticalOffset: CGFloat) {
        let runTextMatrix = CTRunGetTextMatrix(run)
        let runTextMatrixIsID = runTextMatrix.isIdentity

        let runAttrs = CTRunGetAttributes(run)
//        let glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(NSAttributedString.Key.ylpTextGlyphTransform));
//        if (!isVertical && !glyphTransformValue) { // draw run
//            if (!runTextMatrixIsID) {
//                context.saveGState();
//                let trans = context.textMatrix;
//                context.textMatrix = trans.concatenating(runTextMatrix);
//            }
//            CTRunDraw(run, context, CFRangeMake(0, 0));
//            if (!runTextMatrixIsID) {
//                context.restoreGState();
//            }
//        } else { // draw glyph
//            let runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
//            if (!runFont) {
//                return
//            }
//            let glyphCount = CTRunGetGlyphCount(run);
//            if (glyphCount <= 0) {
//                return
//            }
//
//            CGGlyph glyphs[glyphCount];
//            CGPoint glyphPositions[glyphCount];
//            CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
//            CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
//
//            let fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
//            fillColor = YYTextGetCGColor(fillColor);
//            let strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
//
//            context.saveGState();
//                CGContextSetFillColorWithColor(context, fillColor);
//                if (strokeWidth == nil || strokeWidth.floatValue == 0) {
//                    CGContextSetTextDrawingMode(context, kCGTextFill);
//                } else {
//                    let strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
//                    if (!strokeColor) {
//                        strokeColor = fillColor
//                    }
//                    CGContextSetStrokeColorWithColor(context, strokeColor);
//                    CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
//                    if (strokeWidth.floatValue > 0) {
//                        CGContextSetTextDrawingMode(context, kCGTextStroke);
//                    } else {
//                        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//                    }
//                }
//
//                if (isVertical) {
//                    CFIndex runStrIdx[glyphCount + 1];
//                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                    let runStrRange = CTRunGetStringRange(run);
//                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                    var glyphAdvances[glyphCount];
//                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                    let ascent = CTFontGetAscent(runFont);
//                    let descent = CTFontGetDescent(runFont);
//                    let glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                    let zeroPoint = CGPoint.zero;
//
//                    for oneRange in runRanges {
//                        let range = oneRange.glyphRangeInRun;
//                        let rangeMax = range.location + range.length;
//                        let mode = oneRange.drawMode;
//
//                        for (NSUInteger g = range.location; g < rangeMax; g++) {
//                            CGContextSaveGState(context)
//                                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                                if (glyphTransformValue) {
//                                    CGContextSetTextMatrix(context, glyphTransform);
//                                }
//                                if (mode) { // CJK glyph, need rotated
//                                    let ofs = (ascent - descent) * 0.5;
//                                    let w = glyphAdvances[g].width * 0.5;
//                                    let x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
//                                    let y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
//                                    if (mode == YYTextRunGlyphDrawModeVerticalRotateMove) {
//                                        x += w;
//                                        y += w;
//                                    }
//                                    CGContextSetTextPosition(context, x, y);
//                                } else {
//                                    CGContextRotateCTM(context, YYTextDegreesToRadians(-90));
//                                    CGContextSetTextPosition(context,
//                                                             line.position.y - size.height + glyphPositions[g].x,
//                                                             line.position.x + verticalOffset + glyphPositions[g].y);
//                                }
//
//                                if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
//                                    CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                                } else {
//                                    let cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                    CGContextSetFont(context, cgFont);
//                                    CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                    CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                    CGFontRelease(cgFont);
//                                }
//
//                            CGContextRestoreGState(context);
//                        }
//                    }
//                } else { // not vertical
//                    if (glyphTransformValue) {
//                        CFIndex runStrIdx[glyphCount + 1];
//                        CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                        CFRange runStrRange = CTRunGetStringRange(run);
//                        runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                        CGSize glyphAdvances[glyphCount];
//                        CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                        CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                        CGPoint zeroPoint = CGPointZero;
//
//                        for (NSUInteger g = 0; g < glyphCount; g++) {
//                            CGContextSaveGState(context); {
//                                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                                CGContextSetTextMatrix(context, glyphTransform);
//                                CGContextSetTextPosition(context,
//                                                         line.position.x + glyphPositions[g].x,
//                                                         size.height - (line.position.y + glyphPositions[g].y));
//
//                                if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
//                                    CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                                } else {
//                                    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                    CGContextSetFont(context, cgFont);
//                                    CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                    CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                    CGFontRelease(cgFont);
//                                }
//                            } CGContextRestoreGState(context);
//                        }
//                    } else {
//                        if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
//                            CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
//                        } else {
//                            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                            CGContextSetFont(context, cgFont);
//                            CGContextSetFontSize(context, CTFontGetSize(runFont));
//                            CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
//                            CGFontRelease(cgFont);
//                        }
//                    }
//                }
//
//             CGContextRestoreGState(context);
    }
}
