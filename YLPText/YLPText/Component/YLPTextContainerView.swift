//
//  YLPTextContainerView.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/21.
//

import UIKit

public class YLPTextContainerView: UIView {
    weak var hostView: UIView?
    var debugOption: YLPTextDebugOption? {
        didSet {
            if debugOption?.needDrawDebug() != oldValue?.needDrawDebug() {
                setNeedsDisplay()
            }
        }
    }

    var textVerticalAlignment: YLPTextVerticalAlignment = .center {
        didSet {
            if textVerticalAlignment != oldValue {
                setNeedsDisplay()
            }
        }
    }

    var layout: YLPTextLayout? {
        didSet {
            if layout != oldValue {
                attachmentChanged = true
                setNeedsDisplay()
            }
        }
    }

    var contentsFadeDuration: TimeInterval = 0.0 {
        didSet {
            if contentsFadeDuration != oldValue, contentsFadeDuration <= 0 {
                layer.removeAnimation(forKey: "contents")
            }
        }
    }

    private var attachmentChanged = false
    private var attachmentViews = [UIView]()
    private var attachmentLayers = [CALayer]()

    func setLayout(_ layout: YLPTextLayout?, withFadeDuration fadeDuration: TimeInterval) {
        contentsFadeDuration = fadeDuration
        self.layout = layout
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }

    override public func draw(_ rect: CGRect) {
        layer.removeAnimation(forKey: "contents")
        if contentsFadeDuration > 0 {
            let transition = CATransition()
            transition.duration = contentsFadeDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            transition.type = .fade
            layer.add(transition, forKey: "contents")
        }

        // update attachment
        if attachmentChanged {
            for view in attachmentViews {
                if view.superview == self {
                    view.removeFromSuperview()
                }
            }
            for layer in attachmentLayers {
                if layer.superlayer == layer {
                    layer.removeFromSuperlayer()
                }
            }
            attachmentViews.removeAll()
            attachmentLayers.removeAll()
        }
        // draw layout
        guard let layout = layout else { return }
        let boundingSize = layout.textBoundingSize
        var point = CGPoint.zero
        if textVerticalAlignment == .center {
            if layout.container.verticalForm {
                point.x = -(bounds.size.width - boundingSize.width) * 0.5
            } else {
                point.y = (bounds.size.height - boundingSize.height) * 0.5
            }
        } else if textVerticalAlignment == .bottom {
            if layout.container.verticalForm {
                point.x = -(bounds.size.width - boundingSize.width)
            } else {
                point.y = bounds.size.height - boundingSize.height
            }
        }

        layout.draw(in: UIGraphicsGetCurrentContext()!, size: bounds.size, point: point, view: self, layer: layer, debug: debugOption, cancel: nil)

        // update attachment
        if attachmentChanged {
            attachmentChanged = false
            for a in layout.attachments {
                if let content = a.content as? UIView {
                    attachmentViews.append(content)
                }
                if let content = a.content as? CALayer {
                    attachmentLayers.append(content)
                }
            }
        }
    }
}
