//
//  RoundProgressView.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 28/08/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import UIKit

/// Progress view that is in the shape of a circle
public class CircularProgressView: UIView {
    
    /// Current progress
    ///
    /// This value should be in the range between 0 and 1.
    /// If the value is out of the range its automatically adjusted.
    var progress: CGFloat = 0 {
        didSet {
            // Update the progress if the value is out of the range
            progress = max(0, min(1, progress))
            
            // Perform animation from the old to the new state
            animateFrom(oldValue, to: progress)
        }
    }
    
    /// Line width of the circular progress view
    var lineWidth: CGFloat = 2
    
    // Layer on which the progress animation is performed
    private var progressLayer: CAShapeLayer!
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0),
            radius: min(rect.size.width, rect.size.height),
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        let backgroundLayer = circleLayer(path: circularPath, strokeColor: .lightGray)
        layer.addSublayer(backgroundLayer)
        
        let progressLayer = circleLayer(path: circularPath, strokeColor: .red)
        progressLayer.isHidden = true
        layer.addSublayer(progressLayer)
        self.progressLayer = progressLayer
    }
    
    // MARK: - Helpers
    
    /// Factory for creating circle layers
    ///
    /// Both background and foreground layers have some same properties
    ///
    /// - Parameters
    ///   - `path`: Circular path that specifies the final shape
    ///   - `strokeColor`: Color of the circle
    ///   - `lineWidth`: Width of the circle
    /// - Returns: Final circular shape layer with applied parameters
    private func circleLayer(path: UIBezierPath, strokeColor: UIColor) -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = lineWidth
        circleLayer.strokeColor = strokeColor.cgColor
        
        return circleLayer
    }
    
    /// Animates the progress from the old value to the new value
    ///
    /// - Parameters
    ///   - `oldProgress`: The old value
    ///   - `newProgress`: The new value
    private func animateFrom(_ oldProgress: CGFloat, to newProgress: CGFloat) {
        progressLayer.isHidden = false
        
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = 0.3
        circularProgressAnimation.fromValue = oldProgress
        circularProgressAnimation.toValue = newProgress
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
