//
//  YLPLabel.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit
 
class YLPLabel: UIView {
    

    struct state {
        static var layoutNeedUpdate = true
        static var showingHighlight = true
        static var contentsNeedFade = true
        static var trackingTouch = true
        
    }
    
    override var frame: CGRect {
        didSet {
            if oldValue != frame {
                _innerContainer.size = self.bounds.size
                _setLayoutNeedUpdate()
            }
            
        }
    }
    
    

    private var _innerText = NSMutableAttributedString()
    private var _innerContainer = YLPTextContainer()
    
    
    var attributedText: NSAttributedString? {
        didSet {
            set(attributedText: attributedText)
        }
    }
    var text: String? = nil {
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
                    self._setLayoutNeedUpdate()
                    self.invalidateIntrinsicContentSize()
                }
                
            }
        }
    }
    
    var ignoreCommonProperties = false
    
    var displaysAsynchronously = false {
        didSet {
            (self.layer as? YLPTextAsyncLayer)?.displaysAsynchronously = displaysAsynchronously
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
    // MARK: - 私有属性
    private var longPressTimer: Timer?
    private var highlight: YLPTextHighlight?
    private var highlightLayout: YLPTextLayout?
    private var shrinkInnerLayout: YLPTextLayout?
    private var shrinkHighlightLayout: YLPTextLayout?

    
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
        self.layer.setNeedsDisplay()
    }
    
    private func clearContents() {
        layer.contents = nil
    }
    private func hideHighlight(animated: Bool) {
        if state.showingHighlight {
            state.showingHighlight = false
            state.contentsNeedFade = animated
            self._setLayoutNeedRedraw()
        }
    }
    private func removeHighlight(animated: Bool) {
        self.hideHighlight(animated: animated)
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
        
        if let layer = self.layer as? YLPTextAsyncLayer {
            layer.dele = self
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
}

extension YLPLabel: YYTextAsyncLayerDelegate {
    func newAsyncDisplayTask() -> YYTextAsyncLayerDisplayTask {
        
        var text = _innerText;
        var container = _innerContainer;
        
        let task = YYTextAsyncLayerDisplayTask()
        task.display = { [weak self] (context , size, isCancelled) in
            
            debugPrint(context, size)
            
            let layoutNeedUpdate = state.layoutNeedUpdate
            
            if let layout = YLPTextLayout.layout(container: container, text: text) {
                let boundingSize = layout.textBoundingSize
                var point = CGPoint.zero
//                if verticalAlignment == YYTextVerticalAlignmentCenter {
//                    if drawLayout.container.isVerticalForm {
//                        point.x = -(size.width - boundingSize.width) * 0.5
//                    } else {
//                        point.y = (size.height - boundingSize.height) * 0.5
//                    }
//                } else if verticalAlignment == YYTextVerticalAlignmentBottom {
//                    if drawLayout.container.isVerticalForm {
//                        point.x = -(size.width - boundingSize.width)
//                    } else {
//                        point.y = size.height - boundingSize.height
//                    }
//                }
                point = YLPTextCGPointPixelRound(point)
                layout.draw(in: context, size: size, point: point, view: nil, layer: nil, debug: nil, cancel: isCancelled)
            }
            
            
            
        }
        return task
    }
}
