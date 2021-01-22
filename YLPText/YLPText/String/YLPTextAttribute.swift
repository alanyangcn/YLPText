//
//  YLPTextAttribute.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit
enum YYTextAttributeType {
    case YYTextAttributeTypeNone
    case YYTextAttributeTypeUIKit
    case YYTextAttributeTypeCoreText
    case YYTextAttributeTypeYYText
}

enum YYTextTruncationType: Int {
    case none = 0
    case start = 1
    case end = 2
    case middle = 3
}

struct YLPTextLineStyle: OptionSet {
    let rawValue: Int

    // basic style (bitmask:0xFF)
    static let none = YLPTextLineStyle(rawValue: 0x00) /// < (        ) Do not draw a line (Default).
    static let single = YLPTextLineStyle(rawValue: 0x01) /// < (──────) Draw a single line.
    static let thick = YLPTextLineStyle(rawValue: 0x02) /// < (━━━━━━━) Draw a thick line.
    static let double = YLPTextLineStyle(rawValue: 0x09) /// < (══════) Draw a double line.
    // style pattern (bitmask:0xF00)
    static let patternSolid = YLPTextLineStyle(rawValue: 0x000) /// < (────────) Draw a solid line (Default).
    static let patternDot = YLPTextLineStyle(rawValue: 0x100) /// < (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    static let patternDash = YLPTextLineStyle(rawValue: 0x200) /// < (— — — —) Draw a line of dashes.
    static let patternDashDot = YLPTextLineStyle(rawValue: 0x300) /// < (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    static let patternDashDotDot = YLPTextLineStyle(rawValue: 0x400) /// < (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    static let patternCircleDot = YLPTextLineStyle(rawValue: 0x900) /// < (••••••••••••) Draw a line of small circle dots.
}

enum YLPTextVerticalAlignment: Int {
    case top = 0 /// < Top alignment.
    case center = 1 /// < Center alignment.
    case bottom = 2
}

struct YLPTextDirection: OptionSet {
    let rawValue: Int

    static let none: YLPTextDirection = []
    static let top = YLPTextDirection(rawValue: 1 << 0)
    static let right = YLPTextDirection(rawValue: 1 << 1)
    static let bottom = YLPTextDirection(rawValue: 1 << 2)
    static let left = YLPTextDirection(rawValue: 1 << 3)
}

public class YLPTextShadow: NSObject {
    var color: UIColor?
    var offset = CGSize.zero
    var radius: CGFloat = .zero
    var blendMode = CGBlendMode.normal
    var subShadow: YLPTextShadow?

    static func shadow(color: UIColor?, offset: CGSize = .zero, radius: CGFloat = .zero) -> YLPTextShadow {
        let one = YLPTextShadow()
        one.color = color
        one.offset = offset
        one.radius = radius

        return one
    }

    static func shadow(nsShadow: NSShadow?) -> YLPTextShadow? {
        if let ns = nsShadow {
            let one = YLPTextShadow()

            one.offset = ns.shadowOffset
            one.radius = ns.shadowBlurRadius
            if let color = ns.shadowColor as? UIColor {
                // FIXME: 待修复
                one.color = color
            }
            return one
        }
        return nil
    }

    func nsShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = offset
        shadow.shadowBlurRadius = radius
        shadow.shadowColor = color

        return shadow
    }
}

public class YLPTextBorder: NSObject, NSCoding, NSCopying {
    var lineStyle: YLPTextLineStyle = .single /// < border line style
    var strokeWidth: CGFloat = 0.0 /// < border line width
    var strokeColor: UIColor? /// < border line color
    var lineJoin: CGLineJoin = .miter /// < border line join
    var insets: UIEdgeInsets = .zero /// < border insets for text bounds
    var cornerRadius: CGFloat = 0.0 /// < border corder radius
    var shadow: YLPTextShadow? /// < border shadow
    var fillColor: UIColor? /// < inner fill color

    convenience init(lineStyle: YLPTextLineStyle, lineWidth width: CGFloat, stroke color: UIColor?) {
        self.init()
        self.lineStyle = lineStyle
        strokeWidth = width
        strokeColor = color
    }

    convenience init(fillColor color: UIColor?, cornerRadius: CGFloat) {
        self.init()
        fillColor = color
        self.cornerRadius = cornerRadius
        insets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: -2)
    }

    override init() {
        super.init()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(lineStyle, forKey: "lineStyle")
        aCoder.encode(strokeWidth, forKey: "strokeWidth")
        aCoder.encode(strokeColor, forKey: "strokeColor")
        aCoder.encode(lineJoin, forKey: "lineJoin")
        aCoder.encode(insets, forKey: "insets")
        aCoder.encode(cornerRadius, forKey: "cornerRadius")
        aCoder.encode(shadow, forKey: "shadow")
        aCoder.encode(fillColor, forKey: "fillColor")
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init()
        lineStyle = aDecoder.decodeObject(forKey: "lineStyle") as? YLPTextLineStyle ?? .none
        strokeWidth = aDecoder.decodeObject(forKey: "strokeWidth") as? CGFloat ?? 0.0
        strokeColor = aDecoder.decodeObject(forKey: "strokeColor") as? UIColor
        lineJoin = aDecoder.decodeObject(forKey: "join") as? CGLineJoin ?? .miter
        insets = aDecoder.decodeObject(forKey: "insets") as? UIEdgeInsets ?? .zero
        cornerRadius = aDecoder.decodeObject(forKey: "cornerRadius") as? CGFloat ?? 0
        shadow = aDecoder.decodeObject(forKey: "shadow") as? YLPTextShadow
        fillColor = aDecoder.decodeObject(forKey: "fillColor") as? UIColor
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextBorder()
        one.lineStyle = lineStyle
        one.strokeWidth = strokeWidth
        one.strokeColor = strokeColor
        one.lineJoin = lineJoin
        one.insets = insets
        one.cornerRadius = cornerRadius
//        one.shadow = shadow.copy
        one.fillColor = fillColor
        return one
    }
}

class YLPTextAttachment: NSObject, NSCoding, NSCopying {
    var content: AnyObject? /// < Supported type: UIImage, UIView, CALayer
    var contentMode: (UIView.ContentMode)! /// < Content display mode.
    var contentInsets: UIEdgeInsets! /// < The insets when drawing content.
    var userInfo: [AnyHashable: Any]? /// < The user information dictionary.

    class func attachment(withContent content: AnyObject?) -> YLPTextAttachment {
        let one = YLPTextAttachment()
        one.content = content
        return one
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: "content")
        aCoder.encode(NSValue(uiEdgeInsets: contentInsets), forKey: "contentInsets")
        aCoder.encode(userInfo, forKey: "userInfo")
    }

    override init() {
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        content = aDecoder.decodeObject(forKey: "content") as AnyObject?
        contentInsets = (aDecoder.decodeObject(forKey: "contentInsets") as? NSValue)?.uiEdgeInsetsValue
        userInfo = aDecoder.decodeObject(forKey: "userInfo") as? [AnyHashable: Any]
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextAttachment()
        if let content = content {
            if content.responds(to: #selector(copy)) {
                one.content = content.copy() as AnyObject
            } else {
                one.content = content
            }
        }

        one.contentInsets = contentInsets
        one.userInfo = userInfo
        return one
    }
}

class YLPTextDecoration: NSObject, NSCoding, NSCopying {
    var style: YLPTextLineStyle? /// < line style
    var width: NSNumber? /// < line width (nil means automatic width)
    var color: UIColor? /// < line color (nil means automatic color)
    var shadow: YLPTextShadow? /// < line shadow

    required init?(coder: NSCoder) {
        super.init()
    }

    func encode(with coder: NSCoder) {
    }

    override init() {
        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextDecoration()
        one.style = style
        one.width = width
        one.color = color
        return one
    }
}
 
public typealias YLPTextAction = (UIView?, NSAttributedString?, NSRange, CGRect) -> Void

/**
 YYTextHighlight objects are used by the NSAttributedString class cluster
 as the values for touchable highlight attributes (stored in the attributed string
 under the key named YYTextHighlightAttributeName).

 When display an attributed string in `YYLabel` or `YYTextView`, the range of
 highlight text can be toucheds down by users. If a range of text is turned into
 highlighted state, the `attributes` in `YYTextHighlight` will be used to modify
 (set or remove) the original attributes in the range for display.
 */
public class YLPTextHighlight: NSObject, NSCoding, NSCopying {
    /// Attributes that you can apply to text in an attributed string when highlight.
    /// Key:   Same as CoreText/YYText Attribute Name.
    /// Value: Modify attribute value when highlight (NSNull for remove attribute).
    var attributes = [NSAttributedString.Key: Any?]()
    /// The user information dictionary, default is nil.
    var userInfo: [AnyHashable: Any]?
    /// Tap action when user tap the highlight, default is nil.
    /// If the value is nil, YYTextView or YYLabel will ask it's delegate to handle the tap action.
    var tapAction: YLPTextAction?
    /// Long press action when user long press the highlight, default is nil.
    /// If the value is nil, YYTextView or YYLabel will ask it's delegate to handle the long press action.
    var longPressAction: YLPTextAction?

    override init() {
        super.init()
    }

    convenience init(attributes: [NSAttributedString.Key: Any?]) {
        self.init()
        self.attributes = attributes
    }

    convenience init(backgroundColor: UIColor?) {
        self.init()
        let highlightBorder = YLPTextBorder()
        highlightBorder.insets = UIEdgeInsets(top: -2, left: -1, bottom: -2, right: -1)
        highlightBorder.cornerRadius = 3
        highlightBorder.fillColor = backgroundColor
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(Data(), forKey: "attributes")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let one = YLPTextHighlight()
        one.attributes = attributes
        return one
    }

    func setFont(_ font: UIFont?) {
        if let font = font {
            attributes[kCTFontAttributeName as NSAttributedString.Key] = font

        } else {
            attributes[kCTFontAttributeName as NSAttributedString.Key] = nil
        }
    }

    func setColor(_ color: UIColor?) {
        if let color = color {
            attributes[kCTForegroundColorAttributeName as NSAttributedString.Key] = color.cgColor
            attributes[.foregroundColor] = color
        } else {
            attributes[kCTForegroundColorAttributeName as NSAttributedString.Key] = nil
            attributes[.foregroundColor] = nil
        }
    }

    func setStrokeWidth(_ width: CGFloat?) {
        if let width = width {
            attributes[kCTStrokeWidthAttributeName as NSAttributedString.Key] = width

        } else {
            attributes[kCTStrokeWidthAttributeName as NSAttributedString.Key] = nil
        }
    }

    func setStrokeColor(_ color: UIColor?) {
        if let color = color {
            attributes[kCTStrokeColorAttributeName as NSAttributedString.Key] = color.cgColor
            attributes[.strokeColor] = color
        } else {
            attributes[kCTStrokeColorAttributeName as NSAttributedString.Key] = nil
            attributes[.strokeColor] = nil
        }
    }

    private func setTextAttribute(attributeName: NSAttributedString.Key, value: Any?) {
        attributes[attributeName] = value
    }

    func setShadow(_ shadow: YLPTextShadow?) {
        setTextAttribute(attributeName: .ylpTextShadow, value: shadow)
    }

    func setInnerShadow(_ shadow: YLPTextShadow?) {
        setTextAttribute(attributeName: .ylpTextInnerShadow, value: shadow)
    }

    func setUnderline(_ underline: YLPTextDecoration?) {
        setTextAttribute(attributeName: .ylpTextUnderline, value: underline)
    }

    func setStrikethrough(_ strikethrough: YLPTextDecoration?) {
        setTextAttribute(attributeName: .ylpTextStrikethrough, value: strikethrough)
    }

    func setBackgroundBorder(_ border: YLPTextBorder?) {
        setTextAttribute(attributeName: .ylpTextBackgroundBorder, value: border)
    }

    func setBorder(_ border: YLPTextBorder?) {
        setTextAttribute(attributeName: .ylpTextBorder, value: border)
    }

    func setAttachment(_ attachment: YLPTextAttachment?) {
        setTextAttribute(attributeName: .ylpTextAttachment, value: attachment)
    }
}
