//
//  CircularProgressView.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {

    var shapeLayer: CAShapeLayer!
    var lineWidth: CGFloat
    let lineBackgroundColor: UIColor
    init(lineWidth: CGFloat, lineBackgroundColor: UIColor = PhoneroColor.progressColor) {
        self.lineWidth = lineWidth
        self.lineBackgroundColor = lineBackgroundColor
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        self.lineWidth = 10
        self.lineBackgroundColor = UIColor.white
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.superview?.layoutIfNeeded()
        createdShapes()
    }

    private func createdShapes() {
        let width = self.frame.width

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: width/2, y: width/2),
                                        radius: width/2 - (lineWidth/2), startAngle: -CGFloat.pi / 2,
                                        endAngle: 2 * CGFloat.pi,
                                        clockwise: true)

        let trackLayer = circularShapeWith(path: circularPath)
        trackLayer.strokeColor = lineBackgroundColor.cgColor

        shapeLayer = circularShapeWith(path: circularPath)
        shapeLayer.strokeColor = PhoneroColor.primaryColor.cgColor
        shapeLayer.strokeEnd = 0

        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(shapeLayer)
    }

    func circularShapeWith(path: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        return shapeLayer
    }

    func update(progress: Double, animated: Bool = true) {
        if animated {
            CATransaction.begin()
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.fromValue = shapeLayer.strokeEnd
            basicAnimation.toValue = progress
            print(progress)
            basicAnimation.duration = progress * 3
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.isRemovedOnCompletion = false
            CATransaction.setCompletionBlock {
                self.shapeLayer.strokeEnd = CGFloat(progress)
            }
            shapeLayer.add(basicAnimation, forKey: "strokeEndAnimation")
            CATransaction.commit()
        } else {
            shapeLayer.strokeEnd = CGFloat(progress)
        }
    }

}
