//
//  ViewController.swift
//  XKFoldTextView
//
//  Created by xk on 02/19/2024.
//  Copyright (c) 2024 xk. All rights reserved.
//

import UIKit
import SnapKit
import XKFoldTextView

class ViewController: UIViewController {

    lazy var textView = XKFoldTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.backgroundColor = .clear
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
            make.left.equalTo(16)
            make.height.equalTo(10.0)
        }
        
        textView.text = "艾弗森大佛去诶我就哦气温就发烧了的GV路上看到过为荣切勿骗人阿道夫才能去哦i为发哈师傅VBIDv八十多阿飞请我喝考清华ROI温柔爱上对方看v莫IS而非奥飞却我安静的说法吗请问飘柔，多少分，啊道歉就而发七百瑞安生点话费啊都是浪费空气我IE如爱的色放就欧气减肥"
        
    }
    
}


extension ViewController: XKFoldTextViewDelegate {
    func fold(textView: XKFoldTextView, heightDidChange height: CGFloat) {
        self.textView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}

