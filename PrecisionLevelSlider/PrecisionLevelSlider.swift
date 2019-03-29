// PrecisionLevelSlider.swift
//
// Copyright (c) 2016 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class PrecisionLevelSlider: UIControl {
    
    // MARK: - Properties
    
    @objc open var longNotchColor: UIColor = .black {
        didSet {
            update()
        }
    }
    
    @objc open var longNotchSize: CGSize = CGSize(width: 1, height: 14.0) {
        didSet {
            update()
        }
    }
    
    @objc open var longNotchCornerRadius: CGFloat = 0 {
        didSet {
            update()
        }
    }
    
    @objc open var shortNotchColor: UIColor = UIColor(white: 0.2, alpha: 1) {
        didSet {
            update()
        }
    }
    
    @objc open var shortNotchSize: CGSize = CGSize(width: 1.0, height: 8.0) {
        didSet {
            update()
        }
    }
    
    @objc open var shortNotchCornerRadius: CGFloat = 0 {
        didSet {
            update()
        }
    }
    
    @objc open var centerNotchColor: UIColor = UIColor.orange {
        didSet {
            update()
        }
    }
    
    @objc open var centerNotchSize: CGSize = CGSize(width: 1.0, height: 0) {
        didSet {
            update()
        }
    }
    
    @objc open var centerNotchCornerRadius: CGFloat = 0 {
        didSet {
            update()
        }
    }
    
    @objc open var longNotchGroup: Int = 5 {
        didSet {
            update()
        }
    }
    
    /// default 0.0. this value will be pinned to min/max
    @objc open dynamic var value: Float = 0 {
        didSet {
            guard !scrollView.isDecelerating && !scrollView.isDragging else {
                return
            }
            
            let offset = valueToOffset(value: value)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                
                self.scrollView.setContentOffset(offset, animated: false)
                
            }) { (finish) in
            }
        }
    }
    
    /// default 0.0. the current value may change if outside new min value
    @objc open dynamic var minimumValue: Float = 0 {
        didSet {
            let offset = valueToOffset(value: value)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                
                self.scrollView.setContentOffset(offset, animated: false)
                
            }) { (finish) in
            }
        }
    }
    
    /// default 1.0. the current value may change if outside new max value
    @objc open dynamic var maximumValue: Float = 1 {
        didSet {
            let offset = valueToOffset(value: value)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                
                self.scrollView.setContentOffset(offset, animated: false)
                
            }) { (finish) in
            }
        }
    }
    
    @objc open var isContinuous: Bool = true
    
    @objc open var notchCount: Int = 0 {
        didSet {
            addNotchLayers()
            update()
        }
    }
    
    @objc open var notchSpacing: CGFloat = 10.0 {
        didSet {
            update()
        }
    }
    
    @objc open var notchFont: UIFont? {
        didSet {
            update()
        }
    }
    
    @objc open var applyMask: Bool = true
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var notchLayers: [UIView] = []
    private let centerNotchLayer = CALayer()
    
    private let gradientLayer: CAGradientLayer = {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.4, 0.6, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        return gradientLayer
    }()
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Functions
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 50)
    }
    
    func update() {
        if applyMask {
            layer.mask = gradientLayer
        } else {
            layer.mask = nil
        }
        
        let offset = valueToOffset(value: value)
        scrollView.setContentOffset(offset, animated: false)
        
        gradientLayer.frame = bounds
        
        let shortNotchWidth: CGFloat = shortNotchSize.width
        let longNotchWidth: CGFloat = longNotchSize.width
        let centerNotchWidth: CGFloat = centerNotchSize.width
        
        let shortNotchHeight: CGFloat = shortNotchSize.height
        let longNotchHeight: CGFloat = longNotchSize.height
        let centerNotchHeight: CGFloat = centerNotchSize.height == 0 ? bounds.height : centerNotchSize.height
        
        let offsetY = bounds.height / 2
        
        var contentWidth: CGFloat = 0.0
        
        if notchLayers.count > 0 {
            notchLayers.enumerated().forEach { i, v in
                
                let x: CGFloat = CGFloat(i) * notchSpacing
                
                var notchWidth = shortNotchWidth
                if i % longNotchGroup == 0 {
                    notchWidth = longNotchWidth
                    
                    v.backgroundColor = longNotchColor
                    
                    v.frame = CGRect(
                        x: x,
                        y: offsetY - (longNotchHeight / 2),
                        width: notchWidth,
                        height: longNotchHeight)
                    //TODO: Turn this into a var
                    v.layer.cornerRadius = 2
                    
                    if let font = notchFont {
                        for sv in v.subviews {
                            sv.removeFromSuperview()
                        }
                        
                        let label = UILabel()
                        label.text = String(Int(minimumValue) + Int(i/10))
                        label.textColor = .white
                        label.font = font
                        label.frame = CGRect(x: -label.intrinsicContentSize.width/2,
                                             y: longNotchHeight + 25,
                                             width: label.intrinsicContentSize.width,
                                             height: label.intrinsicContentSize.height)
                        v.addSubview(label)
                    }
                } else {
                    for sv in v.subviews {
                        sv.removeFromSuperview()
                    }
                    
                    v.backgroundColor = shortNotchColor
                    v.frame = CGRect(
                        x: x,
                        y: offsetY - (shortNotchHeight / 2),
                        width: notchWidth,
                        height: shortNotchHeight)
                    //TODO: Turn this into a var
                    v.layer.cornerRadius = 1
                }
            }
            
            contentWidth = notchLayers.last!.frame.maxX + centerNotchWidth + shortNotchWidth + longNotchWidth
        }
        
        centerNotchLayer.backgroundColor = centerNotchColor.cgColor
        centerNotchLayer.frame = CGRect(x: bounds.midX, y: bounds.midY - centerNotchHeight / 2, width: centerNotchWidth, height: centerNotchHeight)
        //TODO: Turn this into a var
        centerNotchLayer.cornerRadius = 3
        
        let contentSize = CGSize(
            width: contentWidth,
            height: bounds.height
        )
        
        contentView.frame.size = contentSize
        scrollView.contentSize = contentSize
        
        let inset: CGFloat = scrollView.bounds.width / 2
        scrollView.contentInset = UIEdgeInsets.init(top: 0, left: inset, bottom: 0, right: inset)
        
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        layer.addSublayer(centerNotchLayer)
    }
    
    fileprivate func addNotchLayers() {
        if let sublayers = contentView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        notchLayers = []
        
        for _ in 0..<notchCount {
            let notchLayer = UIView()
            contentView.addSubview(notchLayer)
            
            notchLayers.append(notchLayer)
        }
    }
    
    fileprivate func offsetToValue() -> Float {
        
        let progress = (scrollView.contentOffset.x + scrollView.contentInset.left) / contentView.bounds.size.width
        let actualProgress = Float(min(max(0, progress), 1))
        let value = ((maximumValue - minimumValue) * actualProgress) + minimumValue
        
        return value
    }
    
    fileprivate func valueToOffset(value: Float) -> CGPoint {
        
        let progress = (value - minimumValue) / (maximumValue - minimumValue)
        let x = contentView.bounds.size.width * CGFloat(progress) - scrollView.contentInset.left
        return CGPoint(x: x, y: 0)
    }
    
}

extension PrecisionLevelSlider: UIScrollViewDelegate {
    
    public final func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.bounds.width > 0 else {
            return
        }
        
        guard scrollView.isDecelerating || scrollView.isDragging else {
            return
        }
        
        if isContinuous {
            value = offsetToValue()
            sendActions(for: .valueChanged)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isContinuous == false {
            value = offsetToValue()
            sendActions(for: .valueChanged)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && isContinuous == false {
            value = offsetToValue()
            sendActions(for: .valueChanged)
        }
    }
}
