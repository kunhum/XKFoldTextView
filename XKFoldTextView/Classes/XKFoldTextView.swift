//
//  XKFoldTextView.swift
//  XKFoldTextView
//
//  Created by kenneth on 2024/2/18.
//

import UIKit

public protocol XKFoldTextViewDelegate: NSObjectProtocol {
    func fold(textView: XKFoldTextView, heightDidChange height: CGFloat)
}
public extension XKFoldTextViewDelegate {
    func fold(textView: XKFoldTextView, heightDidChange height: CGFloat) {}
}

open class XKFoldTextView: UIView {
    
    public weak var delegate: XKFoldTextViewDelegate?
    
    public var text: String? {
        didSet {
            update(text: text, attributedText: nil)
        }
    }
    
    public var attributedText: NSAttributedString? {
        didSet {
            update(text: nil, attributedText: attributedText)
        }
    }
    
    /// 默认3
    public var numberOfLines: Int = 3 {
        didSet {
            textView.textContainer.maximumNumberOfLines = numberOfLines
            updateLayout()
        }
    }
    
    public lazy var moreButton: UIButton = {
        let moreButton = UIButton(type: .custom)
        moreButton.titleLabel?.font = .systemFont(ofSize: 13)
        moreButton.setTitle("更多", for: .normal)
        moreButton.setTitle("收起", for: .selected)
        moreButton.setTitleColor(.blue, for: .normal)
        moreButton.addTarget(self, action: #selector(onPressedMore), for: .touchUpInside)
        moreButton.sizeToFit()
        return moreButton
    }()
    
    public lazy var textView: UITextView = {
        let textView: UITextView
        if #available(iOS 16.0, *) {
            // If usingTextLayoutManager is true, UITextView uses TextKit 2. If it is false, TextKit 1 will be used
            textView = UITextView(usingTextLayoutManager: false)
        } else {
            textView = UITextView(frame: .zero)
        }
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 13)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textAlignment = .justified
        textView.isUserInteractionEnabled = false
        textView.textContainer.maximumNumberOfLines = numberOfLines
        return textView
    }()
    
    /// 折叠状态
    var isFolded = true
    
    private lazy var setTextClosure = { [weak self] (text: String?, attributedText: NSAttributedString?) in
        if attributedText == nil {
            self?.textView.text = text
        } else {
            self?.textView.attributedText = attributedText
        }
    }
    
    public init() {
       super.init(frame: .zero)
       setupUI()
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupUI() {
        addSubview(textView)
        addSubview(moreButton)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        textView.frame = bounds
        let buttonTitle = moreButton.currentTitle ?? ""
        let buttonSize = (buttonTitle as NSString).size(withAttributes: [.font: moreButton.titleLabel?.font ?? .systemFont(ofSize: 13)])
        let buttonHeight = buttonSize.height
        let buttonWidth = buttonSize.width
        moreButton.frame = CGRect(x: bounds.width-buttonWidth,
                                  y: bounds.height-buttonHeight,
                                  width: buttonWidth,
                                  height: buttonHeight)
    }
    
}

extension XKFoldTextView {
    
    func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func update(height: CGFloat) {
        frame.size.height = height
        delegate?.fold(textView: self, heightDidChange: height)
    }
    
    func calculateHeight() -> CGFloat {
        
        let size = CGSize(width: bounds.width, height: 0.0)
        
        let buttonTitle = moreButton.title(for: .selected) ?? ""
        
        if let attributedText = self.attributedText, attributedText.length > 0 {
            
            let mutAttText = NSMutableAttributedString(attributedString: attributedText)
            
            if isFolded == false {
                let buttonFont = moreButton.titleLabel?.font ?? .systemFont(ofSize: 13)
                let buttonAttText = NSAttributedString(string: buttonTitle, attributes: [.font: buttonFont])
                mutAttText.append(buttonAttText)
            }
            let height = mutAttText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).height
            return height
        }
        
        let textViewFont = textView.font ?? .systemFont(ofSize: 13)
        var text = (self.text ?? "")
        if isFolded == false {
            text += buttonTitle
        }
        let nsText = text as NSString
        let height = nsText.boundingRect(
            with: CGSize(width: bounds.width, height: 0.0),
            options: .usesLineFragmentOrigin,
            attributes: [.font: textViewFont],
            context: nil).height
        return height
    }
    
    func update(text: String?, attributedText: NSAttributedString?) {
        
        if bounds.width == 0.0 { updateLayout() }
        
        let textHeight = calculateHeight()
        let foldedHeight = ceil(textView.font?.lineHeight ?? 0) * Double(numberOfLines)
        let canFold = textHeight > foldedHeight
        moreButton.isHidden = canFold == false
        
        resetTextView()
        guard canFold else {
            update(height: calculateHeight())
            updateLayout()
            updateExclusionPaths()
            setTextClosure(text, attributedText)
            return
        }
        
        moreButton.isSelected = !isFolded
        update(height: isFolded ? foldedHeight : textHeight)
        updateLayout()
        updateExclusionPaths()
        setTextClosure(text, attributedText)
    }
    
    func resetTextView() {
        textView.textContainer.exclusionPaths.removeAll()
        let _ = textView.layoutManager.textContainer(forGlyphAt: 0, effectiveRange: nil)
    }
    
    func update(numberOfLines: Int) {
        textView.textContainer.maximumNumberOfLines = numberOfLines
        textView.invalidateIntrinsicContentSize()
        guard numberOfLines == 0 else { return }
        resetTextView()
    }
    
    func updateExclusionPaths() {
        
        // 处理路径
        guard moreButton.isHidden == false else { return }
        let path = UIBezierPath(rect: moreButton.frame)
        textView.textContainer.exclusionPaths.append(path)
    }
    
    @objc func onPressedMore() {
        isFolded = !isFolded
        update(numberOfLines: isFolded ? numberOfLines : 0)
        update(text: text, attributedText: attributedText)
    }
}

public extension XKFoldTextView {
    
}
