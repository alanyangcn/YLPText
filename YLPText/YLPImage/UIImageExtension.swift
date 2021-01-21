//
//  UIImageExtension.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/21.
//

import UIKit
extension UIImage {
    class func ylp_image(with size: CGSize, drawBlock: ((_ context: CGContext?) -> Void)?) -> UIImage? {
        guard let drawBlock = drawBlock else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        if context == nil {
            return nil
        }
        drawBlock(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
