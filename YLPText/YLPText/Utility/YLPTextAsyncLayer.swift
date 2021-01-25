//
//  YYTextAsyncLayer.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

/**
 A display task used by YYTextAsyncLayer to render the contents in background queue.
 */
class YYTextAsyncLayerDisplayTask {
    /**
     This block will be called before the asynchronous drawing begins.
     It will be called on the main thread.
     
     block param layer: The layer.
     */
    var willDisplay: ((_ layer: CALayer?) -> Void)?
    
    /**
     This block is called to draw the layer's contents.
     
     @discussion This block may be called on main thread or background thread,
     so is should be thread-safe.
     
     block param context:      A new bitmap content created by layer.
     block param size:         The content size (typically same as layer's bound size).
     block param isCancelled:  If this block returns `YES`, the method should cancel the
     drawing process and return as quickly as possible.
     */
    var display: ((CGContext, CGSize, @escaping () -> Bool) -> Void)?
    
    /**
     This block will be called after the asynchronous drawing finished.
     It will be called on the main thread.
     
     block param layer:  The layer.
     block param finished:  If the draw process is cancelled, it's `NO`, otherwise it's `YES`;
     */
    var didDisplay: ((_ layer: CALayer?, _ finished: Bool) -> Void)?
}

protocol YYTextAsyncLayerDelegate {
    func newAsyncDisplayTask() -> YYTextAsyncLayerDisplayTask
}

class YLPTextAsyncLayer: CALayer {
    
    var displaysAsynchronously = true
    var dele: YYTextAsyncLayerDelegate?
    
    override init() {
        super.init()
        
        self.contentsScale = UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func display() {
        super.contents = super.contents
        _displayAsync(async: displaysAsynchronously)
    }

    private func _displayAsync(async: Bool) {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, contentsScale)
        if let task = dele?.newAsyncDisplayTask(), let context = UIGraphicsGetCurrentContext() {
            var size = bounds.size
            size.width *= contentsScale
            size.height *= contentsScale
//            context.saveGState()

//            do {
//                if let bgColor = backgroundColor, bgColor.alpha == 1 {
//                    context.setFillColor(bgColor)
//                    context.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
//                    context.fillPath()
//                } else {
//                    context.setFillColor(UIColor.white.cgColor)
//                    context.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
//                    context.fillPath()
//                }
//            }

//            context.restoreGState()

            task.display?(context, bounds.size, {
                false
            })

            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            contents = image?.cgImage
        }
    }
}
