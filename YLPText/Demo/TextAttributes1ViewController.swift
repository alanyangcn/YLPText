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
        do {
            let one = NSMutableAttributedString(string: "Border")
            one.ylp_font = UIFont.boldSystemFont(ofSize: 30)
            one.ylp_color = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)

            let border = YLPTextBorder()
            border.strokeColor = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
            border.strokeWidth = 3
            border.lineStyle = .patternCircleDot
            border.cornerRadius = 3
            border.insets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
            one.ylp_textBackgroundBorder = border
            
//            text.append(padding())
            text.append(one)
//            text.append(padding())
//            text.append(padding())
//            text.append(padding())
//            text.append(padding())
        }
        let label = YLPLabel()
        label.attributedText = text
        label.width = 200
        label.height = 200
        label.top = 200
        label.textAlignment = .center
        
        
        label.centerX = self.view.center.x
        label.backgroundColor = .lightGray
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
