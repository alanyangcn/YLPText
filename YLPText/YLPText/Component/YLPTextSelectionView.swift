//
//  YYTextSelectionView.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/22.
//

import UIKit

let kMarkAlpha: CGFloat = 0.2
let kLineWidth: CGFloat = 2.0
let kBlinkDuration = 0.5
let kBlinkFadeDuration = 0.2
let kBlinkFirstDelay = 0.1
let kTouchTestExtend: CGFloat = 14.0
let kTouchDotExtend: CGFloat = 7.0

/// A single dot view. The frame should be foursquare.
/// Change the background color for display.
/// - Remark: Typically, you should not use this class directly.
class YLPSelectionGrabberDot: UIView {
    /// Dont't access this property. It was used by `YYTextEffectWindow`.
    var mirror: UIView?
}

/// A grabber (stick with a dot).
/// - Remark: Typically, you should not use this class directly.
class YLPSelectionGrabber: UIView {
    private(set) var dot: YLPSelectionGrabberDot? /// < the dot view
    var dotDirection: YLPTextDirection = .none /// < don't support composite direction
    var color: UIColor? /// < tint color, default is nil

    func touchRect() -> CGRect {
        var rect = frame.insetBy(dx: -kTouchTestExtend, dy: -kTouchTestExtend)
        var insets = UIEdgeInsets.zero
        if dotDirection.contains(.top) {
            insets.top = -kTouchDotExtend
        }
        if dotDirection.contains(.right) {
            insets.right = -kTouchDotExtend
        }
        if dotDirection.contains(.bottom) {
            insets.bottom = -kTouchDotExtend
        }
        if dotDirection.contains(.left){
            insets.left = -kTouchDotExtend
        }
        rect = rect.inset(by: insets)
        return rect
    }
}

class YLPTextSelectionView: UIView {
    weak var hostView: UIView? /// < the holder view

    /// < the tint color
    var color: UIColor? {
        didSet {
            caretView.backgroundColor = color
            startGrabber.color = color
            endGrabber.color = color
            markViews.forEach({ $0.backgroundColor = color })
        }
    }

    /// < whether the caret is blinks
    var caretBlinks = false {
        didSet {
            if caretBlinks != oldValue {
                caretView.alpha = 1
                YLPTextSelectionView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_startBlinks), object: nil)
            }
        }
    }

    /// < whether the caret is visible
    var caretVisible = false {
        didSet {
            self.caretView.isHidden = !caretVisible
            self.caretView.alpha = 1
            YLPTextSelectionView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_startBlinks), object: nil)
            if caretBlinks {
                perform(#selector(_startBlinks), with: nil, afterDelay: kBlinkFirstDelay)
            }
        }
    }
    /// < weather the text view is vertical form
    var isVerticalForm = false {
        didSet {
            if isVerticalForm != oldValue {
                self.startGrabber.dotDirection = isVerticalForm ? .right : .top
                self.endGrabber.dotDirection = isVerticalForm ? .left : .bottom
            }
        }
    }
    /// < caret rect (width==0 or height==0)
    var caretRect = CGRect.zero {
        didSet {
            self.caretView.frame = _standardCaretRect(caretRect)
            let minWidth = min(self.caretView.width, self.caretView.height)
            self.caretView.layer.cornerRadius = minWidth * 0.5
        }
    }
    /// < default is empty
    var selectionRects = [YLPTextSelectionRect]() {
        didSet {
            self.markViews.forEach({$0.removeFromSuperview()})
            self.markViews.removeAll()
            self.startGrabber.isHidden = true
            self.endGrabber.isHidden = true
            
            selectionRects.forEach { (r) in
                var rect = r.rect
                rect = rect.standardized
                rect = YLPTextCGRectPixelRound(rect)
                if r.containsStart || r.containsEnd {
                    rect = _standardCaretRect(rect)
                    if r.containsStart {
                        startGrabber.isHidden = false
                        startGrabber.frame = rect
                    }
                    if r.containsEnd {
                        endGrabber.isHidden = false
                        endGrabber.frame = rect
                    }
                } else {
                    if rect.size.width > 0 && rect.size.height > 0 {
                        let mark = UIView(frame: rect)
                        mark.backgroundColor = color
                        mark.alpha = kMarkAlpha
                        insertSubview(mark, at: 0)
                        markViews.append(mark)
                    }
                }
            }
        }
    }
    private(set) lazy var caretView = UIView()
    private(set) var startGrabber = YLPSelectionGrabber()
    private(set) var endGrabber = YLPSelectionGrabber()
    private var caretTimer: Timer?

    private var markViews = [UIView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        clipsToBounds = false

        caretView.isHidden = true
        startGrabber.dotDirection = .top
        startGrabber.isHidden = true
        endGrabber.dotDirection = .bottom
        endGrabber.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        caretTimer?.invalidate()
        caretTimer = nil
    }
    
    @objc func _startBlinks() {
        caretTimer?.invalidate()
        if caretVisible {
            caretTimer = Timer(timeInterval: kBlinkDuration, target: self, selector: #selector(_doBlink), userInfo: nil, repeats: true)
            RunLoop.current.add(caretTimer!, forMode: .default)
        } else {
            caretView.alpha = 1
        }
    }

    @objc func _doBlink() {
        UIView.animate(withDuration: kBlinkFadeDuration, delay: 0, options: .curveEaseInOut, animations: {
            if self.caretView.alpha == 1 {
                self.caretView.alpha = 0
            } else {
                self.caretView.alpha = 1
            }
        })
    }
    func _standardCaretRect(_ caretRect: CGRect) -> CGRect {
        var caretRect = caretRect
        caretRect = caretRect.standardized
        if isVerticalForm {
            if caretRect.size.height == 0 {
                caretRect.size.height = kLineWidth
                caretRect.origin.y -= kLineWidth * 0.5
            }
            if caretRect.origin.y < 0 {
                caretRect.origin.y = 0
            } else if caretRect.origin.y + caretRect.size.height > bounds.size.height {
                caretRect.origin.y = bounds.size.height - caretRect.size.height
            }
        } else {
            if caretRect.size.width == 0 {
                caretRect.size.width = kLineWidth
                caretRect.origin.x -= kLineWidth * 0.5
            }
            if caretRect.origin.x < 0 {
                caretRect.origin.x = 0
            } else if caretRect.origin.x + caretRect.size.width > bounds.size.width {
                caretRect.origin.x = bounds.size.width - caretRect.size.width
                
            }
        }
        caretRect = YLPTextCGRectPixelRound(caretRect)
        if caretRect.origin.x.isNaN || caretRect.origin.x.isInfinite {
            caretRect.origin.x = 0
        }
        if caretRect.origin.y.isNaN || caretRect.origin.y.isInfinite {
            caretRect.origin.y = 0
        }
        if caretRect.size.width.isNaN || caretRect.size.width.isInfinite {
            caretRect.size.width = 0
        }
        if caretRect.size.height.isNaN || caretRect.size.height.isInfinite {
            caretRect.size.height = 0
        }
        return caretRect
    }
    

    func isGrabberContains(_ point: CGPoint) -> Bool {
        return isStartGrabberContains(point) || isEndGrabberContains(point)
    }

    func isStartGrabberContains(_ point: CGPoint) -> Bool {
        if startGrabber.isHidden {
            return false
        }
        let startRect = startGrabber.touchRect()
        let endRect = endGrabber.touchRect()
        if startRect.intersects(endRect) {
            let distStart = YLPTextCGPointGetDistanceToPoint(point, YLPTextCGRectGetCenter(startRect))
            let distEnd = YLPTextCGPointGetDistanceToPoint(point, YLPTextCGRectGetCenter(endRect))
            if distEnd <= distStart {
                return false
            }
        }
        return startRect.contains(point)
    }

    func isEndGrabberContains(_ point: CGPoint) -> Bool {
        if endGrabber.isHidden {
            return false
        }
        let startRect = startGrabber.touchRect()
        let endRect = endGrabber.touchRect()
        if startRect.intersects(endRect) {
            let distStart = YLPTextCGPointGetDistanceToPoint(point, YLPTextCGRectGetCenter(startRect))
            let distEnd = YLPTextCGPointGetDistanceToPoint(point, YLPTextCGRectGetCenter(endRect))
            if distEnd > distStart {
                return false
            }
        }
        return endRect.contains(point)
    }

    func isCaretContains(_ point: CGPoint) -> Bool {
        if caretVisible {
            let rect = caretRect.insetBy(dx: -kTouchTestExtend, dy: -kTouchTestExtend)
            return rect.contains(point)
        }
        return false
    }

    func isSelectionRectsContains(_ point: CGPoint) -> Bool {
        if selectionRects.count == 0 {
            return false
        }
        for rect in selectionRects {
            if rect.rect.contains(point) {
                return true
            }
        }
        return false
    }
}
