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

        var trackingTouch = true
        var swallowTouch = true
        var touchMoved = true

        var hasTapAction = true
        var hasLongPressAction = true

        var contentsNeedFade = true
    }

    static let kLongPressMinimumDuration = 0.5
    static let kLongPressAllowableMovement: CGFloat = 9.0
    static let kHighlightFadeDuration = 0.15
    static let kAsyncFadeDuration = 0.08

    override var frame: CGRect {
        didSet {
            if oldValue != frame {
                innerContainer.size = bounds.size
                if !ignoreCommonProperties {
                    state.layoutNeedUpdate = true
                }

                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    self._clearContents()
                }
                self._setLayoutNeedRedraw()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
            if oldValue != frame {
                innerContainer.size = bounds.size
                if !ignoreCommonProperties {
                    state.layoutNeedUpdate = true
                }

                if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                    self._clearContents()
                }
                self._setLayoutNeedRedraw()
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if ignoreCommonProperties {
            return innerLayout?.textBoundingSize ?? .zero
        }

        if !verticalForm && size.width <= 0 {
            self.size.width = CGFloat.infinity
        }
        if verticalForm && size.height <= 0 {
            self.size.height = CGFloat.infinity
        }

        if (!verticalForm && size.width == bounds.size.width) || (verticalForm && size.height == bounds.size.height) {
            _updateIfNeeded()
            let layout = innerLayout
            var contains = false
            if layout?.container.maximumNumberOfRows == 0 {
                if layout?.truncatedLine == nil {
                    contains = true
                }
            } else {
                if (layout?.rowCount ?? 0) <= (layout?.container.maximumNumberOfRows ?? 0) {
                    contains = true
                }
            }
            if contains {
                return layout?.textBoundingSize ?? .zero
            }
        }
        return .zero
    }

    override var accessibilityLabel: String? {
        set {
        }
        get {
            return innerLayout?.text.ylp_plainText(for: NSRange(location: 0, length: innerLayout?.text.length ?? 0))
        }
    }

    /// The text displayed by the label. Default is nil.
    /// Set a new value to this property also replaces the text in `attributedText`.
    /// Get the value returns the plain text in `attributedText`.
    var text: String? {
        didSet {
            if text != oldValue {
                let needAddAttributes = innerText.length == 0 && (text?.count ?? 0) > 0

                let range = NSRange(location: 0, length: innerText.length)
                innerText.replaceCharacters(in: range, with: text ?? "")

                innerText.ylp_removeDiscontinuousAttributes(in: range)

                if needAddAttributes {
                    innerText.ylp_font = font
                    innerText.ylp_color = textColor
                    innerText.ylp_shadow = _shadowFromProperties()
                    innerText.ylp_alignment = textAlignment
                    switch lineBreakMode {
                    case NSLineBreakMode.byWordWrapping, NSLineBreakMode.byCharWrapping, NSLineBreakMode.byClipping:
                        innerText.ylp_lineBreakMode = lineBreakMode
                    case NSLineBreakMode.byTruncatingHead, NSLineBreakMode.byTruncatingTail, NSLineBreakMode.byTruncatingMiddle:
                        innerText.ylp_lineBreakMode = NSLineBreakMode.byWordWrapping
                    default:
                        break
                    }
                }
                if let textParser = textParser, textParser.parseText(innerText, selectedRange: nil) {
                    _updateOuterTextProperties()
                }

                if !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }

                    _setLayoutNeedUpdate()
                    _endTouch()

                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The font of the text. Default is 17-point system font.
    /// Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
    /// Get the value returns the font at the head of `attributedText`.

    var font: UIFont? = UIFont.systemFont(ofSize: 17) {
        didSet {
            if font == nil {
                font = UIFont.systemFont(ofSize: 17)
            }

            if font != oldValue {
                innerText.ylp_font = font
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The color of the text. Default is black.
    /// Set a new value to this property also causes the new color to be applied to the entire `attributedText`.
    /// Get the value returns the color at the head of `attributedText`.
    var textColor: UIColor = .black {
        didSet {
            if textColor != oldValue {
                innerText.ylp_color = textColor
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                }
            }
        }
    }

    /// The shadow color of the text. Default is nil.
    /// Set a new value to this property also causes the shadow color to be applied to the entire `attributedText`.
    /// Get the value returns the shadow color at the head of `attributedText`.
    var shadowColor: UIColor? {
        didSet {
            if shadowColor != oldValue {
                innerText.ylp_shadow = _shadowFromProperties()
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                }
            }
        }
    }

    /// The shadow offset of the text. Default is CGSizeZero.
    /// Set a new value to this property also causes the shadow offset to be applied to the entire `attributedText`.
    /// Get the value returns the shadow offset at the head of `attributedText`.
    var shadowOffset = CGSize.zero {
        didSet {
            if shadowOffset != oldValue {
                innerText.ylp_shadow = _shadowFromProperties()
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                }
            }
        }
    }

    /// The shadow blur of the text. Default is 0.
    /// Set a new value to this property also causes the shadow blur to be applied to the entire `attributedText`.
    /// Get the value returns the shadow blur at the head of `attributedText`.
    var shadowBlurRadius: CGFloat = 0.0 {
        didSet {
            if shadowBlurRadius != oldValue {
                innerText.ylp_shadow = _shadowFromProperties()
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                }
            }
        }
    }

    /// The technique to use for aligning the text. Default is NSTextAlignmentNatural.
    /// Set a new value to this property also causes the new alignment to be applied to the entire `attributedText`.
    /// Get the value returns the alignment at the head of `attributedText`.
    var textAlignment: NSTextAlignment = .natural {
        didSet {
            if oldValue != textAlignment {
                innerText.ylp_alignment = textAlignment
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The text vertical aligmnent in container. Default is YYTextVerticalAlignmentCenter.
    var textVerticalAlignment: YLPTextVerticalAlignment = .center {
        didSet {
            if oldValue != textVerticalAlignment {
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The styled text displayed by the label.
    /// Set a new value to this property also replaces the value of the `text`, `font`, `textColor`,
    /// `textAlignment` and other properties in label.
    /// - Remark: It only support the attributes declared in CoreText and YYTextAttribute.
    /// See `NSAttributedString+YYText` for more convenience methods to set the attributes.
    var attributedText: NSAttributedString? {
        didSet {
            set(attributedText: attributedText)
        }
    }

    /// The technique to use for wrapping and truncating the label's text.
    /// Default is NSLineBreakByTruncatingTail.
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail {
        didSet {
            if oldValue != lineBreakMode {
                innerText.ylp_lineBreakMode = lineBreakMode

                switch lineBreakMode {
                case .byWordWrapping, .byCharWrapping, .byClipping:
                    innerContainer.truncationType = .none
                    innerText.ylp_lineBreakMode = lineBreakMode
                case .byTruncatingHead:
                    innerContainer.truncationType = .start
                    innerText.ylp_lineBreakMode = .byWordWrapping
                case .byTruncatingTail:
                    innerContainer.truncationType = .end
                    innerText.ylp_lineBreakMode = .byWordWrapping
                case .byTruncatingMiddle:
                    innerContainer.truncationType = .middle
                    innerText.ylp_lineBreakMode = .byWordWrapping
                default:
                    break
                }

                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The truncation token string used when text is truncated. Default is nil.
    /// When the value is nil, the label use "…" as default truncation token.
    var truncationToken: NSAttributedString? {
        didSet {
            if oldValue != truncationToken {
                innerContainer.truncationToken = truncationToken?.copy() as? NSAttributedString

                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// The maximum number of lines to use for rendering text. Default value is 1.
    /// 0 means no limit.
    var numberOfLines: UInt = 1 {
        didSet {
            if oldValue != numberOfLines {
                innerContainer.maximumNumberOfRows = numberOfLines
                if innerText.length > 0, !ignoreCommonProperties {
                    if displaysAsynchronously && clearContentsBeforeAsynchronouslyDisplay {
                        _clearContents()
                    }
                    _setLayoutNeedUpdate()
                    _endTouch()
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }

    /// When `text` or `attributedText` is changed, the parser will be called to modify the text.
    /// It can be used to add code highlighting or emoticon replacement to text view.
    /// The default value is nil.
    /// See `YYTextParser` protocol for more information.
    var textParser: YLPTextParser?
    /// The current text layout in text view. It can be used to query the text layout information.
    /// Set a new value to this property also replaces most properties in this label, such as `text`,
    /// `color`, `attributedText`, `lineBreakMode`, `textContainerPath`, `exclusionPaths` and so on.
    var textLayout: YLPTextParser?

    // MARK: - Configuring the Text Container

    /// =============================================================================
    /// @name Configuring the Text Container
    /// =============================================================================

    /// A UIBezierPath object that specifies the shape of the text frame. Default value is nil.
    var textContainerPath: UIBezierPath?
    /// An array of UIBezierPath objects representing the exclusion paths inside the
    /// receiver's bounding rectangle. Default value is nil.
    var exclusionPaths: [UIBezierPath]?
    /// The inset of the text container's layout area within the text view's content area.
    /// Default value is UIEdgeInsetsZero.
    var textContainerInset: UIEdgeInsets = .zero
    /// Whether the receiver's layout orientation is vertical form. Default is false.
    /// It may used to display CJK text.
    var verticalForm = false

    /// The text line position modifier used to modify the lines' position in layout.
    /// Default value is nil.
    /// See `YYTextLinePositionModifier` protocol for more information.
    weak var linePositionModifier: YLPTextLinePositionModifier?
    /// The debug option to display CoreText layout result.
    /// The default value is [YYTextDebugOption sharedDebugOption].
    var debugOption: YLPTextDebugOption = YLPTextDebugOption.sharedDebugOption()

    // MARK: - Getting the Layout Constraints

    /// =============================================================================
    /// @name Getting the Layout Constraints
    /// =============================================================================

    /// The preferred maximum width (in points) for a multiline label.
    /// - Remark: This property affects the size of the label when layout constraints
    /// are applied to it. During layout, if the text extends beyond the width
    /// specified by this property, the additional text is flowed to one or more new
    /// lines, thereby increasing the height of the label. If the text is vertical
    /// form, this value will match to text height.
    var preferredMaxLayoutWidth: CGFloat = 0.0

    // MARK: - Interacting with Text Data

    /// =============================================================================
    /// @name Interacting with Text Data
    /// =============================================================================

    /// When user tap the label, this action will be called (similar to tap gesture).
    /// The default value is nil.
    var textTapAction: YLPTextAction?

    /// When user long press the label, this action will be called (similar to long press gesture).
    /// The default value is nil.
    var textLongPressAction: YLPTextAction?
    /// When user tap the highlight range of text, this action will be called.
    /// The default value is nil.
    var highlightTapAction: YLPTextAction?
    /// When user long press the highlight range of text, this action will be called.
    /// The default value is nil.
    var highlightLongPressAction: YLPTextAction?

    // MARK: - Configuring the Display Mode

    /// =============================================================================
    /// @name Configuring the Display Mode
    /// =============================================================================

    /// A Boolean value indicating whether the layout and rendering codes are running
    /// asynchronously on background threads.
    /// The default value is `false`.
    var displaysAsynchronously = false {
        didSet {
            (layer as? YLPTextAsyncLayer)?.displaysAsynchronously = displaysAsynchronously
        }
    }

    /// If the value is YES, and the layer is rendered asynchronously, then it will
    /// set label.layer.contents to nil before display.
    /// The default value is `true`.
    /// - Remark: When the asynchronously display is enabled, the layer's content will
    /// be updated after the background render process finished. If the render process
    /// can not finished in a vsync time (1/60 second), the old content will be still kept
    /// for display. You may manually clear the content by set the layer.contents to nil
    /// after you update the label's properties, or you can just set this property to YES.
    var clearContentsBeforeAsynchronouslyDisplay = true

    /// If the value is YES, and the layer is rendered asynchronously, then it will add
    /// a fade animation on layer when the contents of layer changed.
    /// The default value is `true`.
    var fadeOnAsynchronouslyDisplay = true
    /// If the value is YES, then it will add a fade animation on layer when some range
    /// of text become highlighted.
    /// The default value is `true`.
    var fadeOnHighlight = true
    /// Ignore common properties (such as text, font, textColor, attributedText...) and
    /// only use "textLayout" to display content.
    /// The default value is `false`.
    /// - Remark: If you control the label content only through "textLayout", then
    /// you may set this value to YES for higher performance.
    var ignoreCommonProperties = false

    // MARK: - 私有属性

    private var innerText = NSMutableAttributedString()
    private var innerLayout: YLPTextLayout?
    private lazy var innerContainer: YLPTextContainer = {
        let container = YLPTextContainer()
        container.truncationType = .end
        container.maximumNumberOfRows = numberOfLines
        return container
    }()

    private var attachmentViews = [UIView]()
    private var attachmentLayers = [CALayer]()

    private var highlightRange = NSRange(location: 0, length: 0) /// < current highlight range
    private var highlight: YLPTextHighlight?
    private var highlightLayout: YLPTextLayout?

    private var shrinkInnerLayout: YLPTextLayout?
    private var shrinkHighlightLayout: YLPTextLayout?

    private var longPressTimer: Timer?
    private var touchBeganPoint = CGPoint.zero
    private var state = YLPLabelState()

    override class var layerClass: AnyClass {
        return YLPTextAsyncLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        _initLabel()
        if let layer = self.layer as? YLPTextAsyncLayer {
            layer.dele = self
        }
    }

    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        _initLabel()
    }
}

extension YLPLabel: YYTextAsyncLayerDelegate {
    func newAsyncDisplayTask() -> YYTextAsyncLayerDisplayTask {
        let contentsNeedFade = state.contentsNeedFade
        let fadeForAsync = displaysAsynchronously && fadeOnAsynchronouslyDisplay
        let text = innerText
        let container = innerContainer

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
                    transition.duration = YLPLabel.kHighlightFadeDuration
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    transition.type = .fade
                    layer.add(transition, forKey: "contents")
                } else if fadeForAsync {
                    let transition = CATransition()
                    transition.duration = YLPLabel.kAsyncFadeDuration
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    transition.type = .fade
                    layer.add(transition, forKey: "contents")
                }
            }
        }

        return task
    }
}

// MARK: - 私有方法

extension YLPLabel {
    private func _updateIfNeeded() {
        if state.layoutNeedUpdate {
            state.layoutNeedUpdate = false
            _updateLayout()
            layer.setNeedsDisplay()
        }
    }

    private func _updateLayout() {
        innerLayout = YLPTextLayout.layout(container: innerContainer, text: innerText)
        shrinkInnerLayout = YLPLabel._shrinkLayout(with: innerLayout)
    }

    private func _setLayoutNeedUpdate() {
        state.layoutNeedUpdate = true
        _clearInnerLayout()
        _setLayoutNeedRedraw()
    }

    private func _setLayoutNeedRedraw() {
        layer.setNeedsDisplay()
    }

    private func _clearInnerLayout() {
        if innerLayout == nil {
            return
        }
        let layout = innerLayout
        innerLayout = nil
        shrinkInnerLayout = nil

        // FIXME: 不懂
//        DispatchQueue.global(qos: .utility).async(execute: {
//            let text = layout?.text // capture to block and release in background
//            if (layout?.attachments.count) != nil {
//                DispatchQueue.main.async(execute: {
//                    text?.length
//                })
//            }
//        })
    }

    private func _innerLayout() -> YLPTextLayout? {
        return shrinkInnerLayout != nil ? shrinkInnerLayout : innerLayout
    }

    private func _highlightLayout() -> YLPTextLayout? {
        return shrinkHighlightLayout != nil ? shrinkHighlightLayout : highlightLayout
    }

    private class func _shrinkLayout(with layout: YLPTextLayout?) -> YLPTextLayout? {
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

    private func _startLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = Timer(timeInterval: YLPLabel.kLongPressMinimumDuration, target: self, selector: #selector(_trackDidLongPress), userInfo: nil, repeats: false)
        if let timer = longPressTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func _endLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }

    @objc private func _trackDidLongPress() {
        endLongPressTimer()

        if state.hasLongPressAction && (textLongPressAction != nil) {
            var range: NSRange?
            var rect: CGRect?
            let point = _convertPoint(toLayout: touchBeganPoint)

            if let innerLayout = innerLayout {
                let textRange = innerLayout.textRange(at: point)

                var textRect = innerLayout.rect(for: textRange!)

                textRect = _convertRect(fromLayout: textRect)
                range = textRange?.asRange()
                rect = textRect
            }

            textLongPressAction?(self, innerText, range, rect)
        }

        if let highlight = highlight {
            if let longPressAction = highlight.longPressAction != nil ? highlight.longPressAction : highlightLongPressAction {
                let start = YLPTextPosition(offset: highlightRange.location)
                let end = YLPTextPosition(offset: highlightRange.location + highlightRange.length, affinity: .backward)

                let range = YLPTextRange(start: start, end: end)

                var rect = innerLayout?.rect(for: range) ?? .zero
                rect = _convertRect(fromLayout: rect)

                longPressAction(self, innerText, highlightRange, rect)

                removeHighlight(animated: true)
                state.trackingTouch = false
            }
        }
    }

    func _getHighlight(at point: CGPoint, range: NSRangePointer?) -> YLPTextHighlight? {
        var point = point

        if let innerLayout = innerLayout, innerLayout.containsHighlight == true {
            point = _convertPoint(toLayout: point)

            if let textRange = innerLayout.textRange(at: point) {
                var startIndex = (textRange.start as? YLPTextPosition)?.offset ?? 0
                if startIndex == innerText.length {
                    if startIndex > 0 {
                        startIndex -= 1
                    }
                }
                var highlightRange = NSRange(location: 0, length: 0)

                let highlight = innerText.attribute(
                    NSAttributedString.Key.ylpTextHighlight,
                    at: startIndex,
                    longestEffectiveRange: &highlightRange,
                    in: NSRange(location: 0, length: innerText.length)) as? YLPTextHighlight

                if highlight == nil {
                    return nil
                }

                range?.pointee = highlightRange
                return highlight
            }
        }
        return nil
    }

    func _showHighlight(animated: Bool) {
        guard let highlight = highlight else { return }

        if highlightLayout != nil {
            if !state.showingHighlight {
                state.showingHighlight = true
                state.contentsNeedFade = animated
                _setLayoutNeedRedraw()
            }
        } else {
            let hiText = innerText
            let newAttrs = highlight.attributes
            (newAttrs as NSDictionary).enumerateKeysAndObjects({ key, value, _ in
                hiText.ylp_setAttribute(name: key as! NSAttributedString.Key, value: value, range: highlightRange)
            })
            highlightLayout = YLPTextLayout.layout(container: innerContainer, text: hiText)
            shrinkHighlightLayout = YLPLabel._shrinkLayout(with: highlightLayout)
            if highlightLayout == nil {
                self.highlight = nil
            }
        }
    }

    func _hideHighlight(animated: Bool) {
        if state.showingHighlight {
            state.showingHighlight = false
            state.contentsNeedFade = animated
            _setLayoutNeedRedraw()
        }
    }

    func _removeHighlight(animated: Bool) {
        _hideHighlight(animated: animated)
        highlight = nil
        highlightLayout = nil
        shrinkHighlightLayout = nil
    }

    func _endTouch() {
        _endLongPressTimer()
        _removeHighlight(animated: true)
        state.trackingTouch = false
    }

    private func _convertPoint(toLayout point: CGPoint) -> CGPoint {
        var point = point
        guard let innerLayout = innerLayout else { return .zero }
        let boundingSize = innerLayout.textBoundingSize
        if innerLayout.container.isVerticalForm {
            var w = innerLayout.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x += innerLayout.container.size.width - w
            if textVerticalAlignment == .center {
                point.x += (bounds.size.width - boundingSize.width) * 0.5
            } else if textVerticalAlignment == .bottom {
                point.x += bounds.size.width - boundingSize.width
            }
            return point
        } else {
            if textVerticalAlignment == .center {
                point.y -= (bounds.size.height - boundingSize.height) * 0.5
            } else if textVerticalAlignment == .bottom {
                point.y -= bounds.size.height - boundingSize.height
            }
        }
        return point
    }

    func _convertPoint(fromLayout point: CGPoint) -> CGPoint {
        var point = point
        guard let innerLayout = innerLayout else { return .zero }
        let boundingSize = innerLayout.textBoundingSize
        if innerLayout.container.isVerticalForm {
            var w = innerLayout.textBoundingSize.width
            if w < bounds.size.width {
                w = bounds.size.width
            }
            point.x -= innerLayout.container.size.width - w
            if boundingSize.width < bounds.size.width {
                if textVerticalAlignment == .center {
                    point.x -= (bounds.size.width - boundingSize.width) * 0.5
                } else if textVerticalAlignment == .bottom {
                    point.x -= bounds.size.width - boundingSize.width
                }
            }
            return point
        } else {
            if boundingSize.height < bounds.size.height {
                if textVerticalAlignment == .center {
                    point.y += (bounds.size.height - boundingSize.height) * 0.5
                } else if textVerticalAlignment == .bottom {
                    point.y += bounds.size.height - boundingSize.height
                }
            }
            return point
        }
    }

    func _convertRect(toLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(toLayout: rect.origin)
        return rect
    }

    func _convertRect(fromLayout rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin = _convertPoint(fromLayout: rect.origin)
        return rect
    }

    func _defaultFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 17)
    }

    func _shadowFromProperties() -> NSShadow? {
        if (shadowColor == nil) || shadowBlurRadius < 0 {
            return nil
        }
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        #if !TARGET_INTERFACE_BUILDER
            shadow.shadowOffset = shadowOffset
        #else
            shadow.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        #endif
        shadow.shadowBlurRadius = shadowBlurRadius
        return shadow
    }

    func _updateOuterLineBreakMode() {
        if innerContainer.truncationType == .none {
            switch innerContainer.truncationType {
            case .start:
                lineBreakMode = NSLineBreakMode.byTruncatingHead
            case .end:
                lineBreakMode = NSLineBreakMode.byTruncatingTail
            case .middle:
                lineBreakMode = NSLineBreakMode.byTruncatingMiddle
            default:
                break
            }
        } else {
            lineBreakMode = innerText.ylp_lineBreakMode
        }
    }

    func _updateOuterTextProperties() {
        text = innerText.ylp_plainText(for: NSRange(location: 0, length: innerText.length))
        font = innerText.ylp_font
        if font == nil {
            font = _defaultFont()
        }
        textColor = innerText.ylp_color ?? .black

        textAlignment = innerText.ylp_alignment
        lineBreakMode = innerText.ylp_lineBreakMode
        let shadow = innerText.ylp_shadow

        shadowColor = shadow?.shadowColor as? UIColor
        shadowOffset = shadow?.shadowOffset ?? .zero
        shadowBlurRadius = shadow?.shadowBlurRadius ?? 0
        attributedText = innerText
        _updateOuterLineBreakMode()
    }

    func _updateOuterContainerProperties() {
        truncationToken = innerContainer.truncationToken
        numberOfLines = innerContainer.maximumNumberOfRows
        textContainerPath = innerContainer.path
        exclusionPaths = innerContainer.exclusionPaths
        textContainerInset = innerContainer.insets
        verticalForm = innerContainer.isVerticalForm
        linePositionModifier = innerContainer.linePositionModifier
        _updateOuterLineBreakMode()
    }

    func _clearContents() {
        layer.contents = nil
    }

    func _initLabel() {
        (layer as? YLPTextAsyncLayer)?.displaysAsynchronously = false
        layer.contentsScale = UIScreen.main.scale
        contentMode = .redraw
    }

    private func set(attributedText: NSAttributedString?) {
        if let inner = attributedText?.mutableCopy() as? NSMutableAttributedString {
            innerText = inner
        }
        if let attr = attributedText {
            if attr.length > 0 {
            }
        } else {
        }

        _setLayoutNeedUpdate()
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

    private func endLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}

// MARK: - Touches

extension YLPLabel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _updateIfNeeded()

        let touch = touches.first

        guard let point = touch?.location(in: self) else { return }

        highlight = _getHighlight(at: point, range: &highlightRange)
        highlightLayout = nil
        shrinkHighlightLayout = nil
        state.hasTapAction = textTapAction != nil
        state.hasLongPressAction = textLongPressAction != nil

        if (highlight != nil) || (textTapAction != nil) || (textLongPressAction != nil) {
            touchBeganPoint = point
            state.trackingTouch = true
            state.swallowTouch = true
            state.touchMoved = false
            _startLongPressTimer()
            if highlight != nil {
                _showHighlight(animated: false)
            }
        } else {
            state.trackingTouch = false
            state.swallowTouch = false
            state.touchMoved = false
        }
        if !state.swallowTouch {
            super.touchesBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        _updateIfNeeded()
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }

        if state.trackingTouch {
            if state.touchMoved {
                let moveH = point.x - touchBeganPoint.x
                let moveV = point.y - touchBeganPoint.y
                if abs(moveH) > abs(moveV) {
                    if abs(moveH) > YLPLabel.kLongPressAllowableMovement {
                        state.touchMoved = true
                    }
                } else {
                    if abs(moveV) > YLPLabel.kLongPressAllowableMovement {
                        state.touchMoved = true
                    }
                }
            }
            if state.touchMoved && (highlight != nil) {
                let highlight = _getHighlight(at: point, range: nil)
                if highlight == self.highlight {
                    _showHighlight(animated: fadeOnHighlight)
                } else {
                    _hideHighlight(animated: fadeOnHighlight)
                }
            }
        }

        if !state.swallowTouch {
            super.touchesMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }

        if state.trackingTouch {
            _endLongPressTimer()
            if state.touchMoved && (textTapAction != nil) {
                var range = NSRange(location: NSNotFound, length: 0)
                var rect = CGRect.zero
                let point = _convertPoint(toLayout: touchBeganPoint)
                let textRange = innerLayout?.textRange(at: point)
                var textRect = innerLayout?.rect(for: textRange!)
                textRect = _convertRect(fromLayout: textRect ?? .zero)
                if let textRange = textRange {
                    range = textRange.asRange()
                    if let textRect = textRect {
                        rect = textRect
                    }
                }
                textTapAction?(self, innerText, range, rect)
            }
            if highlight != nil {
                if state.touchMoved || _getHighlight(at: point, range: nil) == highlight {
                    let tapAction = highlight?.tapAction ?? highlightTapAction
                    if tapAction != nil {
                        let start = YLPTextPosition(offset: highlightRange.location)
                        let end = YLPTextPosition(offset: highlightRange.location + highlightRange.length, affinity: .backward)
                        let range = YLPTextRange(start: start, end: end)
                        var rect = innerLayout?.rect(for: range)
                        rect = _convertRect(fromLayout: rect ?? .zero)
                        tapAction?(self, innerText, highlightRange, rect)
                    }
                }
                _removeHighlight(animated: fadeOnHighlight)
            }
        }

        if !state.swallowTouch {
            super.touchesEnded(touches, with: event)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _endTouch()
        if !state.swallowTouch {
            super.touchesCancelled(touches, with: event)
        }
    }
}
