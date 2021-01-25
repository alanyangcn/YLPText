//
//  YLPTextUtilities.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/19.
//

import UIKit
func YYTextNSRangeFromCFRange(_ range: CFRange) -> NSRange {
    return NSRange(location: range.location, length: range.length)
}
func YYTextCFRangeFromNSRange(_ range: NSRange) -> CFRange {
    return CFRangeMake(CFIndex(range.location), CFIndex(range.length))
}

func YYTextUIEdgeInsetsInvert(_ insets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: -insets.top, left: -insets.left, bottom: -insets.bottom, right: -insets.right);
}

@inline(__always) func YLPTextCGPointPixelRound(_ point: CGPoint) -> CGPoint {
    let scale = UIScreen.main.scale
    return CGPoint(
        x: CGFloat(round(Double(point.x * scale)) / Double(scale)),
        y: CGFloat(round(Double(point.y * scale)) / Double(scale)))
}
func edgeInsetRotateVertical(_ insets: UIEdgeInsets) -> UIEdgeInsets {

    return UIEdgeInsets(top: insets.left, left: insets.bottom, bottom: insets.right, right: insets.top)
}
func YLPTextCGPointGetDistanceToPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))
}
func YLPTextCGRectGetCenter(_ rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}
func YLPTextCGRectPixelRound(_ rect: CGRect) -> CGRect {
    let origin = YLPTextCGPointPixelRound(rect.origin)
    let corner = YLPTextCGPointPixelRound(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
    return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
}
