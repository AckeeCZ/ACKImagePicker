import UIKit

/// Progress view that is in the shape of a circle
///
/// It draws itself within specified rect.
/// The size is derived from the size of the rect where the smaller dimension (width / height) is used.
/// The view itself is drawn in the middle of the rect.
/// As a primary color is used `tintColor` of the view.
public final class CircularProgressView: UIView {
    
    /// Current progress
    ///
    /// This value should be in the range between 0 and 1.
    /// If the value is out of the range its automatically adjusted.
    public var progress: CGFloat = 0 {
        didSet {
            // Update the current value if it's not within range 0...1
            progress = max(0, min(1, progress))
            
            // Update the progress
            progressLayer?.isHidden = false
            progressLayer?.strokeEnd = progress
        }
    }
    
    /// Line width of the circular progress view
    public var lineWidth: CGFloat = 2
    
    /// Color applied on the background circle
    public var secondaryTintColor = UIColor(white: 230/255, alpha: 1)
    
    /// Layer that shows the current progress
    private var progressLayer: CAShapeLayer!
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2),
            radius: min(rect.size.width, rect.size.height) / 2,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = secondaryTintColor.cgColor
        layer.addSublayer(backgroundLayer)
        
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeColor = tintColor.cgColor
        progressLayer.isHidden = true
        layer.addSublayer(progressLayer)
        self.progressLayer = progressLayer
    }
}
