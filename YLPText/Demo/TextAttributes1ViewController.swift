//
//  TextAttributes1ViewController.swift
//  YLPText
//
//  Created by 杨立鹏 on 2021/1/18.
//

import UIKit

class TextAttributes1ViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let text: NSMutableAttributedString = NSMutableAttributedString()
        

//        do {
//            let one: NSMutableAttributedString = NSMutableAttributedString(string: "Shadow")
//            let shadow = YLPTextShadow()
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor.blue
//            shadow.color = UIColor.red
//            shadow.offset = CGSize(width: 0, height: 1)
//            shadow.radius = 5
//            one.ylp_textShadow = shadow
//            text.append(one)
//            text.append(padding())
//        }
       
//        do {
//            let one = NSMutableAttributedString(string: "Inner Shadow")
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor.yellow
//            let shadow = YLPTextShadow()
//            shadow.color = .black
//            shadow.offset = CGSize(width: 0, height: 1)
//            shadow.radius = 1
//            one.ylp_textInnerShadow = shadow
//            text.append(one)
//            text.append(padding())
//        }
        
//        do {
//            let one = NSMutableAttributedString(string: "Multiple Shadows")
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
//
//            let shadow = YLPTextShadow()
//            shadow.color = UIColor(white: 0.000, alpha: 0.20)
//            shadow.offset = CGSize(width: 0, height: -1)
//            shadow.radius = 1.5
//            let subShadow = YLPTextShadow()
//            subShadow.color = UIColor(white: 1, alpha: 0.99)
//            subShadow.offset = CGSize(width: 0, height: 1)
//            subShadow.radius = 1.5
//            shadow.subShadow = subShadow
//            one.ylp_textShadow = shadow
//
//            let innerShadow = YLPTextShadow()
//            innerShadow.color = UIColor(red: 0.851, green: 0.311, blue: 0.000, alpha: 0.780)
//            innerShadow.offset = CGSize(width: 0, height: 1)
//            innerShadow.radius = 1
//            one.ylp_textInnerShadow = innerShadow
//
//            text.append(one)
//            text.append(padding())
//
//        }
        
//        do {
//            let one = NSMutableAttributedString(string: "Background Image")
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
//
//            let size = CGSize(width: 20, height: 20)
//            let background = UIImage.ylp_image(with: size, drawBlock: { context in
//                let c0 = UIColor(red: 0.054, green: 0.879, blue: 0.000, alpha: 1.000)
//                let c1 = UIColor(red: 0.869, green: 1.000, blue: 0.030, alpha: 1.000)
//                c0.setFill()
//                context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
//                c1.setStroke()
//                context?.setLineWidth(2)
//                var i: CGFloat = 0
//                while i < size.width * 2 {
//                    context?.move(to: CGPoint(x: i, y: -2))
//                    context?.addLine(to: CGPoint(x: i - size.height, y: size.height + 2))
//                    i += 4
//                }
//                context?.strokePath()
//            })
//            if let background = background {
//                one.ylp_color = UIColor(patternImage: background)
//            }
//
//            text.append(one)
//            text.append(padding())
//        }
//        do {
//            let one = NSMutableAttributedString(string: "Border")
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
//
//            let border = YLPTextBorder()
//            border.strokeColor = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
//            border.strokeWidth = 3
//            border.lineStyle = .patternCircleDot
//            border.cornerRadius = 3
//            border.insets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
//            one.ylp_textBackgroundBorder = border
//
////            text.append(padding())
//            text.append(one)
////            text.append(padding())
////            text.append(padding())
////            text.append(padding())
////            text.append(padding())
//        }
        do {
            let one = NSMutableAttributedString(string: "Link")
            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
            one.ylp_underlineStyle = [.thick];
            one.ylp_setTextHighlight(range: NSRange(location: 0, length: one.length), color: UIColor(red: 0.093, green: 0.492, blue: 1.000, alpha: 1.000), backgroundColor: UIColor(white: 0.000, alpha: 0.220), userInfo: nil, tap: { _,_,_,_  in
                print("tap -> ")
            }, longPress: nil)

            

                        text.append(one)
                        text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Another Link")
            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
            one.ylp_color = UIColor.red

            let border = YLPTextBorder()
            border.cornerRadius = 50
            border.insets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -10)
            border.strokeWidth = 0.5
            border.strokeColor = one.ylp_color
            border.lineStyle = .single
            one.ylp_textBackgroundBorder = border

            let highlightBorder = border.copy() as! YLPTextBorder
            highlightBorder.strokeWidth = 0
            highlightBorder.strokeColor = one.ylp_color
            highlightBorder.fillColor = one.ylp_color

            let highlight = YLPTextHighlight()
            highlight.setColor(.white)
            highlight.setBackgroundBorder(highlightBorder)
            highlight.tapAction = { _,_,_,_ in
                
            }
            
            text.append(one)
            text.append(padding())
        }
        
//        do {
//            
//            let one = NSMutableAttributedString(string: "Yet Another Link")
//            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
//            one.ylp_color = UIColor.white
//
//            let shadow = YLPTextShadow()
//            shadow.color = UIColor(white: 0.000, alpha: 0.490)
//            shadow.offset = CGSize(width: 0, height: 1)
//            shadow.radius = 5
//            one.ylp_textShadow = shadow
//            
//            let shadow0 = YLPTextShadow()
//            shadow0.color = UIColor(white: 0.000, alpha: 0.20)
//            shadow0.offset = CGSize(width: 0, height: -1)
//            shadow0.radius = 1.5
//            let shadow1 = YLPTextShadow()
//            shadow1.color = UIColor(white: 1, alpha: 0.99)
//            shadow1.offset = CGSize(width: 0, height: 1)
//            shadow1.radius = 1.5
//            shadow0.subShadow = shadow1
//            
//            let innerShadow0 = YLPTextShadow()
//            innerShadow0.color = UIColor(red: 0.851, green: 0.311, blue: 0.000, alpha: 0.780)
//            innerShadow0.offset = CGSize(width: 0, height: 1)
//            innerShadow0.radius = 1
//
//            let highlight = YLPTextHighlight()
//            highlight.color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
//            highlight.shadow = shadow0
//            highlight.innerShadow = innerShadow0
//            one.yy_setTextHighlight(highlight, range: one.yy_rangeOfAll)
//            
//            text.append(one)
//        }
        
        let label = YLPLabel()
        label.attributedText = text
        label.width = self.view.width
        label.height = self.view.height - 88
        label.top = 88
        label.textAlignment = .center
        label.textVerticalAlignment = .center
//        label.centerX = self.view.center.x
        label.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        view.addSubview(label)
    }

    
    deinit {
        debugPrint("销毁")
    }
    
    func padding() -> NSAttributedString {
        let pad = NSMutableAttributedString(string: "\n\n")
        pad.ylp_font = UIFont.systemFont(ofSize: 4)
        return pad
    }
}
