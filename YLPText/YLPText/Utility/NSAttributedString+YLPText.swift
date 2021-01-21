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

    @objc var ylp_textShadow: YLPTextShadow? {
        return attribute(name: .ylpTextShadow, at: 0) as? YLPTextShadow
    }

    @objc var ylp_textInnnerShadow: YLPTextShadow? {
        return attribute(name: .ylpTextInnerShadow, at: 0) as? YLPTextShadow
    }

    @objc var ylp_alignment: NSTextAlignment {
        return getAlignment(at: 0) ?? .natural
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

    override var ylp_textShadow: YLPTextShadow? {
        set {
            ylp_set(shadow: newValue, range: NSRange(location: 0, length: length))
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

    override var ylp_alignment: NSTextAlignment {
        set {
            ParagraphStyleSet(alignment: newValue, range: NSRange(location: 0, length: length))
        }
        get {
            return getAlignment(at: 0) ?? .natural
        }
    }

    func ylp_set(font: UIFont?, range: NSRange) {
        ylp_setAttribute(name: .font, value: font, range: range)
    }

    func ylp_set(color: UIColor?, range: NSRange) {
        ylp_setAttribute(name: .foregroundColor, value: color, range: range)
    }

    func ylp_set(shadow: YLPTextShadow?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextShadow, value: shadow, range: range)
    }

    func ylp_set(innerShadow: YLPTextShadow?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextInnerShadow, value: innerShadow, range: range)
    }

    func ylp_set(textBackgroundBorder: YLPTextBorder?, range: NSRange) {
        ylp_setAttribute(name: .ylpTextBackgroundBorder, value: textBackgroundBorder, range: range)
    }

    func ylp_set(paragraphStyle: NSParagraphStyle?, range: NSRange) {
        ylp_setAttribute(name: .paragraphStyle, value: paragraphStyle, range: range)
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
                if value.alignment == alignment{
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
}
