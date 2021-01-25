//
//  YLPTextMagnifier.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/22.
//

import UIKit
/// Magnifier type
enum YYTextMagnifierType : Int {
    case caret ///< Circular magnifier
    case ranged
}

/**
 A magnifier view which can be displayed in `YYTextEffectWindow`.
 
 @discussion Use `magnifierWithType:` to create instance.
 Typically, you should not use this class directly.
 */
class YYTextMagnifier: UIView {
    private(set) var type: YYTextMagnifierType? ///< Type of magnifier
    private(set) var fitSize = CGSize.zero ///< The 'best' size for magnifier view.
    private(set) var snapshotSize = CGSize.zero ///< The 'best' snapshot image size for magnifier.
    var snapshot: UIImage? ///< The image in magnifier (readwrite).
    weak var hostView: UIView? ///< The coordinate based view.
    var hostCaptureCenter = CGPoint.zero ///< The snapshot capture center in `hostView`.
    var hostPopoverCenter = CGPoint.zero ///< The popover center in `hostView`.
    var hostVerticalForm = false ///< The host view is vertical form.
    var captureDisabled = false ///< A hint for `YYTextEffectWindow` to disable capture.
    var captureFadeAnimation = false ///< Show fade animation when the snapshot image changed.
}
