//
//  UIViewExtension.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/19.
//

import UIKit
extension UIView {
    public var left: CGFloat {
        get {
            return frame.origin.x
        }

        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    public var top: CGFloat {
        get {
            return frame.origin.y
        }

        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    public var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }

        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }

    public var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }

        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }

    public var width: CGFloat {
        get {
            return frame.size.width
        }

        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    public var height: CGFloat {
        get {
            return frame.size.height
        }

        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    public var centerX: CGFloat {
        get {
            return center.x
        }

        set {
            center = CGPoint(x: newValue, y: center.y)
        }
    }

    public var centerY: CGFloat {
        get {
            return center.y
        }

        set {
            center = CGPoint(x: center.x, y: newValue)
        }
    }

    public var origin: CGPoint {
        get {
            return frame.origin
        }

        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

    public var size: CGSize {
        get {
            return frame.size
        }

        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
  
}
