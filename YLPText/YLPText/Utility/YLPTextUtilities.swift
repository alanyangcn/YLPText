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
