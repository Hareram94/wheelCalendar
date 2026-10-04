//
//  AttributedText.swift
//  WheelDob
//
//  Created by Hareram on 04/10/26.
//

import Foundation
import UIKit

protocol AttributedStringComponent {
    var text: String { get }
    func getAttributes() -> [NSAttributedString.Key: Any]?
}

// MARK: String extensions

extension String: AttributedStringComponent {
    var text: String { self }
    func getAttributes() -> [NSAttributedString.Key: Any]? { return nil }
}

extension String {
    func toAttributed(with attributes: [NSAttributedString.Key: Any]?) -> NSAttributedString {
        .init(string: self, attributes: attributes)
    }
    
    func strikeThrough(with font: UIFont, color: UIColor) -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        // Add strikethrough style
           attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
           
           // Add font
           attributeString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributeString.length))
        
        // Add text color
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attributeString.length))

        
        return attributeString
    }
    
    //MARK: -----------------MAKE IT LABEL TEXT GRADIENT
    func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = UIFont.systemFont(ofSize: 20.0, weight: .medium)) -> NSAttributedString {
       
        let attStr = txtStr.attributedStringWithGradient([UIColor.white, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
}

// MARK: NSAttributedString extensions

extension NSAttributedString: AttributedStringComponent {
    var text: String { string }

    func getAttributes() -> [Key: Any]? {
        if string.isEmpty { return nil }
        var range = NSRange(location: 0, length: string.count)
        return attributes(at: 0, effectiveRange: &range)
    }
    
}

extension NSAttributedString {

    convenience init?(from attributedStringComponents: [AttributedStringComponent],
                      defaultAttributes: [NSAttributedString.Key: Any],
                      joinedSeparator: String = " ") {
        switch attributedStringComponents.count {
        case 0: return nil
        default:
            var joinedString = ""
            typealias SttributedStringComponentDescriptor = ([NSAttributedString.Key: Any], NSRange)
            let sttributedStringComponents = attributedStringComponents.enumerated().flatMap { (index, component) -> [SttributedStringComponentDescriptor] in
                var components = [SttributedStringComponentDescriptor]()
                if index != 0 {
                    components.append((defaultAttributes,
                                       NSRange(location: joinedString.count, length: joinedSeparator.count)))
                    joinedString += joinedSeparator
                }
                components.append((component.getAttributes() ?? defaultAttributes,
                                   NSRange(location: joinedString.count, length: component.text.count)))
                joinedString += component.text
                return components
            }

            let attributedString = NSMutableAttributedString(string: joinedString)
            sttributedStringComponents.forEach { attributedString.addAttributes($0, range: $1) }
            self.init(attributedString: attributedString)
        }
    }
}


extension String {
    
        func attributedStringWithGradient(
            _ gradientColors: [UIColor],
            frame: CGRect,
            font: UIFont,
            //Add startPoint and endPoint as parameters with default values for a vertical gradient
            startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), // Default: Top-center
            endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)    // Default: Bottom-center
        ) -> NSAttributedString {

            // 1. Create a gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.colors = gradientColors.map { $0.cgColor }

            // Set the start and end points for the linear gradient direction
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            // gradientLayer.type = .axial // This is the default, so explicitly setting it is optional for linear

            // 2. Create a pattern from the gradient layer
            UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0) // Use gradientLayer.bounds.size
            if let context = UIGraphicsGetCurrentContext() {
                gradientLayer.render(in: context)
                guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                    UIGraphicsEndImageContext()
                    // Return a basic attributed string in case of image creation failure
                    return NSAttributedString(string: self, attributes: [.font: font])
                }
                UIGraphicsEndImageContext()
                let patternColor = UIColor(patternImage: image)

                // 3. Create an attributed string
                let attributedString = NSMutableAttributedString(string: self)
                let fullRange = NSRange(location: 0, length: self.count)

                // Set the gradient color and font
                attributedString.addAttribute(.foregroundColor, value: patternColor, range: fullRange)
                attributedString.addAttribute(.font, value: font, range: fullRange)

                return attributedString
            } else {
                UIGraphicsEndImageContext() // Ensure context is ended even if UIGraphicsGetCurrentContext returns nil
                // Return a basic attributed string in case of context failure
                return NSAttributedString(string: self, attributes: [.font: font])
            }
        }
}
