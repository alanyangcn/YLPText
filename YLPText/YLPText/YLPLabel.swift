//
//  YLPLabel.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

class YLPLabel: UIView, YYTextAsyncLayerDelegate {
    
    struct state {
        static var layoutNeedUpdate = 1
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
    
    var attributedText: NSAttributedString? {
        didSet {
            set(attributedText: attributedText)
        }
    }
    var textAlignment: NSTextAlignment = .natural {
        didSet {
            if oldValue != textAlignment {
                _innerText.ylp_alignment = textAlignment
            }
        }
    }
    
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
    
    override class var layerClass: AnyClass {
        return YYTextAsyncLayer.self
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let layer = self.layer as? YYTextAsyncLayer {
            layer.dele = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
