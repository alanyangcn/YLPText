//
//  YLPLabel.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

class YLPLabel: UIView {
    struct YLPLabelState {
        var layoutNeedUpdate = true
        var showingHighlight = true
        var contentsNeedFade = true
        var trackingTouch = true
    }

    let kLongPressMinimumDuration = 0.5
    let kLongPressAllowableMovement = 9.0
    let kHighlightFadeDuration = 0.15
    let kAsyncFadeDuration = 0.08

    override var frame: CGRect {
        didSet {
            if oldValue != frame {
                _innerContainer.size = bounds.size
                _setLayoutNeedUpdate()
            }
        }
    }

    var state = YLPLabelState()
    var numberOfLines: UInt = 0

    var attributedText: NSAttributedString? {
        didSet {
            set(attributedText: attributedText)
        }
    }

    var text: String? {
        didSet {
        }
    }

    /**
     The font of the text. Default is 17-point system font.
     Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
     Get the value returns the font at the head of `attributedText`.
     */
    var font: UIFont? = UIFont.systemFont(ofSize: 17) {
        didSet {
            if font == nil {
                font = UIFont.systemFont(ofSize: 17)
            }

            if font != oldValue {
                _innerText.ylp_font = font
                if _innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    var ignoreCommonProperties = false

    var displaysAsynchronously = false {
        didSet {
            (layer as? YLPTextAsyncLayer)?.displaysAsynchronously = displaysAsynchronously
        }
    }

    var clearContentsBeforeAsynchronouslyDisplay = true
    var textAlignment: NSTextAlignment = .natural {
        didSet {
            if oldValue != textAlignment {
                _innerText.ylp_alignment = textAlignment
            }
        }
    }

    var textVerticalAlignment: YLPTextVerticalAlignment = .center {
        didSet {
            if oldValue != textVerticalAlignment {
                if _innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    var fadeOnAsynchronouslyDisplay = true

    // MARK: - 私有属性

    private var longPressTimer: Timer?
    private var highlight: YLPTextHighlight?
    private var highlightLayout: YLPTextLayout?
    private var shrinkInnerLayout: YLPTextLayout?
    private var shrinkHighlightLayout: YLPTextLayout?
    private var _innerText = NSMutableAttributedString()
    private lazy var _innerContainer: YLPTextContainer = {
        let container = YLPTextContainer()
        container.truncationType = .end
        container.maximumNumberOfRows = numberOfLines
        return container
    }()

    private var innerLayout: YLPTextLayout?

    private var attachmentViews = [UIView]()
    private var attachmentLayers = [CALayer]()
    private var highlightRange: NSRange? /// < current highlight range

    private var touchBeganPoint = CGPoint.zero

    // MARK: - 私有方法

    private func set(attributedText: NSAttributedString?) {
        if let innerText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            _innerText = innerText
        }
        if let attr = attributedText {
            if attr.length > 0 {
            }
        } else {
        }

        _setLayoutNeedUpdate()
    }

    private func _setLayoutNeedUpdate() {
        _setLayoutNeedRedraw()
    }

    private func _setLayoutNeedRedraw() {
        layer.setNeedsDisplay()
    }

    private func clearContents() {
        layer.contents = nil
    }

    private func hideHighlight(animated: Bool) {
        if state.showingHighlight {
            state.showingHighlight = false
            state.contentsNeedFade = animated
            _setLayoutNeedRedraw()
        }
    }

    private func removeHighlight(animated: Bool) {
        hideHighlight(animated: animated)
        highlight = nil
        highlightLayout = nil
        shrinkHighlightLayout = nil
    }

    private func _endTouch() {
        endLongPressTimer()
        removeHighlight(animated: true)
        state.trackingTouch = false
    }

    private func endLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }

    override class var layerClass: AnyClass {
        return YLPTextAsyncLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self._init()
        if let layer = self.layer as? YLPTextAsyncLayer {
            layer.dele = self
        }
    }

    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        self._init()
    }
    
    private func _init() {
        self.layer.contentsScale = UIScreen.main.scale
    }
}

extension YLPLabel: YYTextAsyncLayerDelegate {
    func newAsyncDisplayTask() -> YYTextAsyncLayerDisplayTask {
        let contentsNeedFade = state.contentsNeedFade
        let fadeForAsync = displaysAsynchronously && fadeOnAsynchronouslyDisplay
        let text = _innerText
        let container = _innerContainer

        var attachmentViews = self.attachmentViews
        var attachmentLayers = self.attachmentLayers
        let layoutNeedUpdate = state.layoutNeedUpdate
        var layout = (state.showingHighlight && (highlightLayout != nil)) ? highlightLayout : innerLayout
        var layoutUpdated = false
        var shrinkLayout: YLPTextLayout?

        let task = YYTextAsyncLayerDisplayTask()

        task.willDisplay = { [weak self] layer in
            guard let layer = layer else { return }

            layer.removeAnimation(forKey: "contents")

            for view in attachmentViews {
                let isContainsView = layout?.attachmentContentsSet?.contains(view) ?? false
                if layoutNeedUpdate || !isContainsView {
                    if view.superview == self {
                        view.removeFromSuperview()
                    }
                }
            }

            for view in attachmentLayers {
                let isContainsView = layout?.attachmentContentsSet?.contains(view) ?? false
                if layoutNeedUpdate || !isContainsView {
                    if view.superlayer == self {
                        view.removeFromSuperlayer()
                    }
                }
            }
            attachmentViews.removeAll()
            attachmentLayers.removeAll()
        }

        task.display = { [weak self] context, size, isCancelled in
            guard let s = self else { return }

            if isCancelled() || text.length == 0 {
                return
            }

            var drawLayout = layout

            let layoutNeedUpdate = s.state.layoutNeedUpdate
            if layoutNeedUpdate {
                layout = YLPTextLayout.layout(container: container, text: text)
                shrinkLayout = YLPLabel._shrinkLayout(with: layout)
                if isCancelled() {
                    return
                }
                layoutUpdated = true
                drawLayout = (shrinkLayout != nil) ? shrinkLayout : layout
            }
            if let drawLayout = drawLayout {
                let boundingSize = drawLayout.textBoundingSize
                var point = CGPoint.zero

                if s.textVerticalAlignment == .center {
                    if drawLayout.container.isVerticalForm {
                        point.x = -(size.width - boundingSize.width) * 0.5
                    } else {
                        point.y = (size.height - boundingSize.height) * 0.5
                    }
                } else if s.textVerticalAlignment == .bottom {
                    if drawLayout.container.isVerticalForm {
                        point.x = -(size.width - boundingSize.width)
                    } else {
                        point.y = size.height - boundingSize.height
                    }
                }
                point = YLPTextCGPointPixelRound(point)
                drawLayout.draw(in: context, size: size, point: point, view: nil, layer: nil, debug: nil, cancel: isCancelled)
            }
        }

        task.didDisplay = { [weak self] layer, finished in
            guard let layer = layer, let s = self else { return }
            var drawLayout = layout
            if layoutUpdated && (shrinkLayout != nil) {
                drawLayout = shrinkLayout
            }
            if !finished {
                // If the display task is cancelled, we should clear the attachments.
                if let attachments = drawLayout?.attachments {
                    for a in attachments {
                        if a.content is UIView {
//                            if (a.content as! UIView).superview == layer!.delegate {
//                                (a.content as? UIView)?.removeFromSuperview()
//                            }
                        } else if a.content is CALayer {
                            if (a.content as? CALayer)?.superlayer == layer {
                                (a.content as? CALayer)?.removeFromSuperlayer()
                            }
                        }
                    }
                }
                return
            }
            layer.removeAnimation(forKey: "contents")

            guard let view = layer.delegate as? YLPLabel else {
                return
            }

            if s.state.layoutNeedUpdate && layoutUpdated {
                view.innerLayout = layout
                view.shrinkInnerLayout = shrinkLayout
                s.state.layoutNeedUpdate = false
            }

            if let drawLayout = drawLayout {
                let size = layer.bounds.size
                let boundingSize = drawLayout.textBoundingSize
                var point = CGPoint.zero
                if s.textVerticalAlignment == .center {
                    if drawLayout.container.isVerticalForm {
                        point.x = -(size.width - boundingSize.width) * 0.5
                    } else {
                        point.y = (size.height - boundingSize.height) * 0.5
                    }
                } else if s.textVerticalAlignment == .bottom {
                    if drawLayout.container.isVerticalForm {
                        point.x = -(size.width - boundingSize.width)
                    } else {
                        point.y = size.height - boundingSize.height
                    }
                }

                point = YLPTextCGPointPixelRound(point)

                drawLayout.draw(in: nil, size: size, point: point, view: view, layer: layer, debug: nil, cancel: nil)
                for a in drawLayout.attachments {
                    if let content = a.content as? UIView {
                        attachmentViews.append(content)
                    } else if let content = a.content as? CALayer {
                        attachmentLayers.append(content)
                    }
                }

                if contentsNeedFade {
                    let transition = CATransition()
                    transition.duration = s.kHighlightFadeDuration
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    transition.type = .fade
                    layer.add(transition, forKey: "contents")
                } else if fadeForAsync {
                    let transition = CATransition()
                    transition.duration = s.kAsyncFadeDuration
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    transition.type = .fade
                    layer.add(transition, forKey: "contents")
                }
            }
        }

        return task
    }

    class func _shrinkLayout(with layout: YLPTextLayout?) -> YLPTextLayout? {
        if let layout = layout, layout.text.length > 0 && layout.lines.count == 0, let container = layout.container.copy() as? YLPTextContainer {
            container.maximumNumberOfRows = 1
            var containerSize = container.size
            if !container.isVerticalForm {
                containerSize.height = CGFloat.infinity
            } else {
                containerSize.width = CGFloat.infinity
            }
            container.size = containerSize
            return YLPTextLayout.layout(container: container, text: layout.text)
        }

        return nil
    }
}
