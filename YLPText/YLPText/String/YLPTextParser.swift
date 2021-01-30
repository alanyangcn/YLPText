//
//  YLPTextParser.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/27.
//

import Foundation

/// The YYTextParser protocol declares the required method for YYTextView and YYLabel
/// to modify the text during editing.
/// You can implement this protocol to add code highlighting or emoticon replacement for
/// YYTextView and YYLabel. See `YYTextSimpleMarkdownParser` and `YYTextSimpleEmoticonParser` for example.
protocol YLPTextParser: NSObjectProtocol {
    /// When text is changed in YYTextView or YYLabel, this method will be called.
    /// - Parameters:
    ///   - text:  The original attributed string. This method may parse the text and
    /// change the text attributes or content.
    ///   - selectedRange:  Current selected range in `text`.
    /// This method should correct the range if the text content is changed. If there's
    /// no selected range (such as YYLabel), this value is NULL.
    /// - Returns: If the 'text' is modified in this method, returns `YES`, otherwise returns `NO`.
    func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool
}
