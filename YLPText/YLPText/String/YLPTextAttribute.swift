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
