//
//  YLPTextContainerView.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/21.
//

import UIKit

class YLPTextContainerView: UIView {
    
    weak var hostView: UIView?
    var debugOption: YYTextDebugOption?
    var textVerticalAlignment: YLPTextVerticalAlignment = .center
    var layout: YLPTextLayout?
    var contentsFadeDuration: TimeInterval = 0.0
    
    private var attachmentChanged = false
    private var attachmentViews = [UIView]()
    private var attachmentLayers = [CALayer]()
    
    func setLayout(_ layout: YLPTextLayout?, withFadeDuration fadeDuration: TimeInterval) {
    }
}
