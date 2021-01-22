//
//  YYTextAsyncLayer.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

class YYTextAsyncLayerDisplayTask {
    var display: ((CGContext, CGSize, @escaping () -> Bool) -> Void)?
}

protocol YYTextAsyncLayerDelegate {
    func newAsyncDisplayTask() -> YYTextAsyncLayerDisplayTask
}

class YLPTextAsyncLayer: CALayer {
    
    var displaysAsynchronously = true
    var dele: YYTextAsyncLayerDelegate?
    
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
