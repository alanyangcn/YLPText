//
//  YLPTextView.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/28.
//

import UIKit
/**
 The YYTextViewDelegate protocol defines a set of optional methods you can use
 to receive editing-related messages for YYTextView objects.

 @discussion The API and behavior is similar to UITextViewDelegate,
 see UITextViewDelegate's documentation for more information.
 */
@objc protocol YYTextViewDelegate: NSObjectProtocol, UIScrollViewDelegate {
    @objc optional func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    @objc optional func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    @objc optional func textViewDidBeginEditing(_ textView: UITextView)
    @objc optional func textViewDidEndEditing(_ textView: UITextView)
    @objc optional func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    @objc optional func textViewDidChange(_ textView: UITextView)
    @objc optional func textViewDidChangeSelection(_ textView: UITextView)

    @objc optional func textView(_ textView: YLPTextView?, shouldTap highlight: YLPTextHighlight?, in characterRange: NSRange) -> Bool
    @objc optional func textView(_ textView: YLPTextView?, didTap highlight: YLPTextHighlight?, in characterRange: NSRange, rect: CGRect)
    @objc optional func textView(_ textView: YLPTextView?, shouldLongPress highlight: YLPTextHighlight?, in characterRange: NSRange) -> Bool
    @objc optional func textView(_ textView: YLPTextView?, didLongPress highlight: YLPTextHighlight?, in characterRange: NSRange, rect: CGRect)
}

class YLPTextView: UIScrollView, UITextInput {
    var selectedTextRange: UITextRange?

    var markedTextRange: UITextRange?

    var markedTextStyle: [NSAttributedString.Key: Any]?

    var beginningOfDocument: UITextPosition = .init()

    var endOfDocument: UITextPosition = .init()

    var inputDelegate: UITextInputDelegate?

    var tokenizer: UITextInputTokenizer = UITextInputStringTokenizer(textInput: YLPTextView())

    // MARK: - Accessing the Delegate

    /// =============================================================================
    /// @name Accessing the Delegate
    /// =============================================================================
//    weak var delegate: YYTextViewDelegate?

    // MARK: - Configuring the Text Attributes

    /// =============================================================================
    /// @name Configuring the Text Attributes
    /// =============================================================================

    /// The text displayed by the text view.
    /// Set a new value to this property also replaces the text in `attributedText`.
    /// Get the value returns the plain text in `attributedText`.
    var text: String?

    var font = UIFont.systemFont(ofSize: 12)

    var textColor = UIColor.black

    var textAlignment = NSTextAlignment.natural

    var textVerticalAlignment = YLPTextVerticalAlignment.top

    var dataDetectorTypes: UIDataDetectorTypes = []

    var linkTextAttributes = [String: Any?]()

    var highlightTextAttributes = [String: Any?]()

    var typingAttributes = [String: Any?]()

    var attributedText: NSAttributedString?

    var textParser: YLPTextParser?

    private(set) var textLayout: YLPTextLayout?

    /// The placeholder text displayed by the text view (when the text view is empty).
    /// Set a new value to this property also replaces the text in `placeholderAttributedText`.
    /// Get the value returns the plain text in `placeholderAttributedText`.
    var placeholderText: String?
    /// The font of the placeholder text. Default is same as `font` property.
    /// Set a new value to this property also causes the new font to be applied to the entire `placeholderAttributedText`.
    /// Get the value returns the font at the head of `placeholderAttributedText`.
    var placeholderFont: UIFont?
    /// The color of the placeholder text. Default is gray.
    /// Set a new value to this property also causes the new color to be applied to the entire `placeholderAttributedText`.
    /// Get the value returns the color at the head of `placeholderAttributedText`.
    var placeholderTextColor: UIColor?

    /// The styled placeholder text displayed by the text view (when the text view is empty).
    /// Set a new value to this property also replaces the value of the `placeholderText`,
    /// `placeholderFont`, `placeholderTextColor`.
    /// - Remark: It only support the attributes declared in CoreText and YYTextAttribute.
    /// See `NSAttributedString+YYText` for more convenience methods to set the attributes.
    var placeholderAttributedText: NSAttributedString?

    /// The inset of the text container's layout area within the text view's content area.
    var textContainerInset: UIEdgeInsets!
    /// An array of UIBezierPath objects representing the exclusion paths inside the
    /// receiver's bounding rectangle. Default value is nil.
    var exclusionPaths: [UIBezierPath]?
    /// Whether the receiver's layout orientation is vertical form. Default is NO.
    /// It may used to edit/display CJK text.
    var verticalForm = false
    /// The text line position modifier used to modify the lines' position in layout.
    /// See `YYTextLinePositionModifier` protocol for more information.
    weak var linePositionModifier: YLPTextLinePositionModifier?
    /// The debug option to display CoreText layout result.
    /// The default value is [YYTextDebugOption sharedDebugOption].
    var debugOption: YLPTextDebugOption?

    /// Scrolls the receiver until the text in the specified range is visible.
    func scrollRangeToVisible(_ range: NSRange) {
    }

    /// The current selection range of the receiver.
    var selectedRange: NSRange?
    /// A Boolean value indicating whether inserting text replaces the previous contents.
    /// The default value is NO.
    var clearsOnInsertion = false
    /// A Boolean value indicating whether the receiver is selectable. Default is YES.
    /// When the value of this property is NO, user cannot select content or edit text.
    var selectable = false
    /// A Boolean value indicating whether the receiver is highlightable. Default is YES.
    /// When the value of this property is NO, user cannot interact with the highlight range of text.
    var highlightable = false

    /// A Boolean value indicating whether the receiver is editable. Default is YES.
    /// When the value of this property is NO, user cannot edit text.
    var editable = false

    /// A Boolean value indicating whether the receiver can paste image from pasteboard. Default is NO.
    /// When the value of this property is YES, user can paste image from pasteboard via "paste" menu.
    var allowsPasteImage = false
    /// A Boolean value indicating whether the receiver can paste attributed text from pasteboard. Default is NO.
    /// When the value of this property is YES, user can paste attributed text from pasteboard via "paste" menu.
    var allowsPasteAttributedString = false
    /// A Boolean value indicating whether the receiver can copy attributed text to pasteboard. Default is YES.
    /// When the value of this property is YES, user can copy attributed text (with attachment image)
    /// from text view to pasteboard via "copy" menu.
    var allowsCopyAttributedString = false

    // MARK: - Manage the undo and redo

    /// =============================================================================
    /// @name Manage the undo and redo
    /// =============================================================================

    /// A Boolean value indicating whether the receiver can undo and redo typing with
    /// shake gesture. The default value is YES.
    var allowsUndoAndRedo = false
    /// The maximum undo/redo level. The default value is 20.
    var maximumUndoLevel = 0

    // MARK: - Replacing the System Input Views

    /// =============================================================================
    /// @name Replacing the System Input Views
    /// =============================================================================

//    /// The custom input view to display when the text view becomes the first responder.
//    /// It can be used to replace system keyboard.
//    /// - Remark: If set the value while first responder, it will not take effect until
//    /// 'reloadInputViews' is called.
//    var inputView: UIView?
//    /// The custom accessory view to display when the text view becomes the first responder.
//    /// It can be used to add a toolbar at the top of keyboard.
//    /// - Remark: If set the value while first responder, it will not take effect until
//    /// 'reloadInputViews' is called.
//    override var inputAccessoryView: UIView?
//
    /// If you use an custom accessory view without "inputAccessoryView" property,
    /// you may set the accessory view's height. It may used by auto scroll calculation.
    var extraAccessoryViewHeight: CGFloat = 0.0

    override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func text(in range: UITextRange) -> String? {
        return nil
    }

    var hasText: Bool = false

    func insertText(_ text: String) {
    }

    func deleteBackward() {
    }
}

extension YLPTextView {
    func replace(_ range: UITextRange, withText text: String) {
    }

    func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
    }

    func unmarkText() {
    }

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        return nil
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        return nil
    }

    func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        return nil
    }

    func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        return .orderedAscending
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        return 1
    }

    func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        return nil
    }

    func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        return nil
    }

    func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        return .natural
    }

    func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
    }

    func firstRect(for range: UITextRange) -> CGRect {
        return .zero
    }

    func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }

    func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    func closestPosition(to point: CGPoint) -> UITextPosition? {
        return nil
    }

    func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        return nil
    }

    func characterRange(at point: CGPoint) -> UITextRange? {
        return nil
    }
}
