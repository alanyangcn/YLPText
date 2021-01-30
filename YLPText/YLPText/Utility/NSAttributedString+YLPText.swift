//
//  NSAttributedString+YLPText.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

public extension NSAttributedString.Key {
    static let ylpTextBackedString: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextBackedString")
    static let ylpTextBinding: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextBinding")
    static let ylpTextShadow: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextShadow")
    static let ylpTextInnerShadow: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextInnerShadow")
    static let ylpTextUnderline: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextUnderline")
    static let ylpTextStrikethrough: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextStrikethrough")
    static let ylpTextBorder: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextBorder")
    static let ylpTextBackgroundBorder: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextBackgroundBorder")
    static let ylpTextBlockBorder: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextBlockBorder")
    static let ylpTextAttachment: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextAttachment")
    static let ylpTextHighlight: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextHighlight")
    static let ylpTextGlyphTransform: NSAttributedString.Key = NSAttributedString.Key(rawValue: "YLPTextGlyphTransform")
}

public extension NSAttributedString {
    @objc var ylp_font: UIFont? {
        return attribute(name: .font, at: 0) as? UIFont
    }

    @objc var ylp_color: UIColor? {
        return attribute(name: .foregroundColor, at: 0) as? UIColor
    }

    @objc var ylp_textBackgroundBorder: YLPTextBorder? {
        return attribute(name: .ylpTextBackgroundBorder, at: 0) as? YLPTextBorder
    }

    @objc var ylp_shadow: NSShadow? {
        return attribute(name: .shadow, at: 0) as? NSShadow
    }
    
    @objc var ylp_textShadow: YLPTextShadow? {
        return attribute(name: .ylpTextShadow, at: 0) as? YLPTextShadow
    }

    @objc var ylp_textInnnerShadow: YLPTextShadow? {
        return attribute(name: .ylpTextInnerShadow, at: 0) as? YLPTextShadow
    }

    @objc var ylp_alignment: NSTextAlignment {
        return getAlignment(at: 0) ?? .natural
    }

    @objc var ylp_underlineStyle: NSUnderlineStyle {
        return attribute(name: .underlineStyle, at: 0) as? NSUnderlineStyle ?? []
    }
    
    @objc var ylp_lineBreakMode: NSLineBreakMode {
        return getLineBreakMode(at: 0) ?? .byWordWrapping
    }

    func attribute(name: NSAttributedString.Key, at index: Int) -> Any? {
        if index >= length || length == 0 {
            return nil
        }

        return attribute(name, at: index, effectiveRange: nil)
    }

    func yy_paragraphStyle(at index: Int) -> NSParagraphStyle? {
        if let style = yy_attribute(attributeName: .paragraphStyle, at: index) as? NSParagraphStyle {
            return style
        }
        return nil
    }

    func yy_attribute(attributeName: NSAttributedString.Key, at index: Int) -> Any? {
        if index >= length || length == 0 {
            return nil
        }

        return attribute(attributeName, at: index, effectiveRange: nil)
    }

    func getAlignment(at index: Int) -> NSTextAlignment? {
        let paragraphStyle = yy_paragraphStyle(at: index)

        return paragraphStyle?.alignment
    }
    
    func getLineBreakMode(at index: Int) -> NSLineBreakMode? {
        let paragraphStyle = yy_paragraphStyle(at: index)

        return paragraphStyle?.lineBreakMode
    }
    
    func ylp_plainText(for range: NSRange) -> String? {
        if range.location == NSNotFound || range.length == NSNotFound {
            return nil
        }
        var result = ""
        if range.length == 0 {
            return result
        }
        let string = self.string
        enumerateAttribute(NSAttributedString.Key.ylpTextBackedString, in: range, options: [], using: { value, range, stop in
            let backed = value as? YLPTextBackedString
            if backed != nil && backed?.string != nil {
                result += backed?.string ?? ""
            } else {
                result += (string as NSString).substring(with: range)
            }
        })
        return result
    }
}

public extension NSMutableAttributedString {
    override var ylp_font: UIFont? {
        set {
            ylp_set(font: newValue, range: NSRange(location: 0, length: length))
        } @objc
        get {
            attribute(name: .font, at: 0) as? UIFont
        }
    }

    override var ylp_color: UIColor? {
        set {
            ylp_set(color: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .foregroundColor, at: 0) as? UIColor
        }
    }

    override var ylp_textBackgroundBorder: YLPTextBorder? {
        set {
            ylp_set(textBackgroundBorder: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .ylpTextBackgroundBorder, at: 0) as? YLPTextBorder
        }
    }
    
    override var ylp_shadow: NSShadow? {
        set {
            ylp_set(shadow: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .shadow, at: 0) as? NSShadow
        }

    }

    override var ylp_textShadow: YLPTextShadow? {
        set {
            ylp_set(textShadow: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .ylpTextShadow, at: 0) as? YLPTextShadow
        }
    }

    @objc var ylp_textInnerShadow: YLPTextShadow? {
        set {
            ylp_set(innerShadow: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .ylpTextShadow, at: 0) as? YLPTextShadow
        }
    }

    override var ylp_underlineStyle: NSUnderlineStyle {
        set {
            ylp_set(underlineStyle: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return attribute(name: .underlineStyle, at: 0) as? NSUnderlineStyle ?? []
        }
    }

    override var ylp_alignment: NSTextAlignment {
        set {
            ParagraphStyleSet(alignment: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return getAlignment(at: 0) ?? .natural
        }
    }
    override var ylp_lineBreakMode: NSLineBreakMode {
        set {
            ParagraphStyleSet(lineBreakMode: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return getLineBreakMode(at: 0) ?? .byWordWrapping
        }
        
    }

    func ylp_set(font: UIFont?, range: NSRange) {
        ylp_setAttribute(name: .font, value: font, range: range)
    }

    func ylp_set(color: UIColor?, range: NSRange) {
        ylp_setAttribute(name: .foregroundColor, value: color, range: range)
    }
    func ylp_set(shadow: NSShadow?, range: NSRange) {
        ylp_setAttribute(name: .shadow, value: shadow, range: range)
    }
    func ylp_set(textShadow: YLPTextShadow?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextShadow, value: textShadow, range: range)
    }

    func ylp_set(innerShadow: YLPTextShadow?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextInnerShadow, value: innerShadow, range: range)
    }

    func ylp_set(textBackgroundBorder: YLPTextBorder?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextBackgroundBorder, value: textBackgroundBorder, range: range)
    }

    func ylp_set(underlineStyle: NSUnderlineStyle?, range: NSRange) {
        ylp_setAttribute(name: .underlineStyle, value: underlineStyle, range: range)
    }

    func ylp_set(paragraphStyle: NSParagraphStyle?, range: NSRange) {
        ylp_setAttribute(name: .paragraphStyle, value: paragraphStyle, range: range)
    }

    func ylp_set(textHighlight: YLPTextHighlight?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextHighlight, value: textHighlight, range: range)
    }

    func ylp_setAttribute(name: NSAttributedString.Key, value: Any?, range: NSRange) {
        if let value = value {
            addAttribute(name, value: value, range: range)
        } else {
            removeAttribute(name, range: range)
        }
    }

    func ParagraphStyleSet(alignment: NSTextAlignment, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { [self] value, subRange, _ in
            var style: NSMutableParagraphStyle?
            if let value = value as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                }
                if value.alignment == alignment {
                    return
                }
                if value is NSMutableParagraphStyle {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value.mutableCopy() as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.alignment == alignment {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.alignment = alignment
            ylp_set(paragraphStyle: style, range: subRange)
        })
    }
    
    func ParagraphStyleSet(lineBreakMode: NSLineBreakMode, range: NSRange) {
        enumerateAttribute(.paragraphStyle, in: range, options: [], using: { [self] value, subRange, _ in
            var style: NSMutableParagraphStyle?
            if let value = value as? NSParagraphStyle {
                if CFGetTypeID(value) == CTParagraphStyleGetTypeID() {
                }
                if value.lineBreakMode == lineBreakMode {
                    return
                }
                if value is NSMutableParagraphStyle {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value.mutableCopy() as? NSMutableParagraphStyle
                }
            } else {
                if NSParagraphStyle.default.lineBreakMode == lineBreakMode {
                    return
                }
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.lineBreakMode = lineBreakMode
            ylp_set(paragraphStyle: style, range: subRange)
        })
    }

    func ylp_setTextHighlight(range: NSRange, color: UIColor?, backgroundColor: UIColor?, userInfo: [AnyHashable: Any]?, tap tapAction: YLPTextAction?, longPress longPressAction: YLPTextAction?) {
        let highlight = YLPTextHighlight(backgroundColor: backgroundColor)
        highlight.userInfo = userInfo
        highlight.tapAction = tapAction
        highlight.longPressAction = longPressAction
        if let color = color {
            ylp_set(color: color, range: range)
        }
        ylp_set(textHighlight: highlight, range: range)
    }

    func ylp_setTextHighlight(range: NSRange, color: UIColor?, backgroundColor: UIColor?, tap tapAction: YLPTextAction?) {
        ylp_setTextHighlight(range: range, color: color, backgroundColor: backgroundColor, userInfo: nil, tap: tapAction, longPress: nil)
    }

    func ylp_setTextHighlight(range: NSRange, color: UIColor?, backgroundColor: UIColor?, userInfo: [AnyHashable: Any]?) {
        ylp_setTextHighlight(range: range, color: color, backgroundColor: backgroundColor, userInfo: userInfo, tap: nil, longPress: nil)
    }

    func ylp_insert(_ string: String, at location: Int) {
        replaceCharacters(in: NSRange(location: location, length: 0), with: string)
        ylp_removeDiscontinuousAttributes(in: NSRange(location: location, length: string.count))
    }

    func ylp_append(_ string: String) {
        let length = self.length
        replaceCharacters(in: NSRange(location: length, length: 0), with: string)
        ylp_removeDiscontinuousAttributes(in: NSRange(location: length, length: string.count))
    }

    // FIXME: 需要记录操作日志
//    func yy_setClearColorToJoinedEmoji() {
//        let str = self.string
//        if str.count < 8 {
//            return
//        }
//
//        var containsJoiner = false
//        do {
//            let cfStr = str as CFString
//            var needFree = false
//            var chars: UniChar? = nil
//            chars = CFStringGetCharactersPtr(cfStr)
//            if chars == nil {
//                chars = malloc(str.length * MemoryLayout<UniChar>.size)
//                if let chars = chars {
//                    needFree = true
//                    CFStringGetCharacters(cfStr, CFRangeMake(CFIndex(0), str.length), UnsafeMutablePointer<UniChar>(mutating: &chars))
//                }
//            }
//            if chars == nil {
//                // fail to get unichar..
//                containsJoiner = true
//            } else {
//                var i = 0, max = Int(str.length)
//                while i < max {
//                    if IntegerLiteralConvertible(chars?[i] ?? 0) == 0x200d {
//                        // 'ZERO WIDTH JOINER' (U+200D)
//                        containsJoiner = true
//                        break
//                    }
//                    i += 1
//                }
//                if needFree {
//                    free(chars)
//                }
//            }
//        }
//
//        if !containsJoiner {
//            return
//        }
//
//        // NSRegularExpression is designed to be immutable and thread safe.
//        private var regex: NSRegularExpression?
//        // `dispatch_once()` call was converted to a static variable initializer
//
//        let clear = UIColor.clear
//        regex?.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { [self] result, flags, stop in
//            yy_setColor(clear, range: result?.range)
//        })
//    }

    func ylp_removeDiscontinuousAttributes(in range: NSRange) {
        let keys = NSMutableAttributedString.ylp_allDiscontinuousAttributeKeys()
        for key in keys {
            removeAttribute(NSAttributedString.Key(key), range: range)
        }
    }

    class func ylp_allDiscontinuousAttributeKeys() -> [String] {
        return [
            kCTSuperscriptAttributeName as String,
            kCTRunDelegateAttributeName as String,
            NSAttributedString.Key.ylpTextBackedString.rawValue,
            NSAttributedString.Key.ylpTextBinding.rawValue,
            NSAttributedString.Key.ylpTextAttachment.rawValue,
            kCTRubyAnnotationAttributeName as String,
            NSAttributedString.Key.attachment.rawValue,
        ]
    }
}
