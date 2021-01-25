//
//  YLPTextEffectWindow.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/22.
//

import UIKit
class YYTextEffectWindow: UIWindow {
    /// Returns the shared instance (returns nil in App Extension).
    static let shared = YYTextEffectWindow()

    /// Show the magnifier in this window with a 'popup' animation. @param mag A magnifier.
    func show(_ mag: YYTextMagnifier?) {
    }

    /// Update the magnifier content and position. @param mag A magnifier.
    func move(_ mag: YYTextMagnifier?) {
    }

    /// Remove the magnifier from this window with a 'shrink' animation. @param mag A magnifier.
    func hide(_ mag: YYTextMagnifier?) {
    }

    /// Show the selection dot in this window if the dot is clipped by the selection view.
    /// @param selection A selection view.
    func showSelectionDot(_ selection: YLPTextSelectionView?) {
    }

    /// Remove the selection dot from this window.
    /// @param selection A selection view.
    func hideSelectionDot(_ selection: YLPTextSelectionView?) {
    }
}
