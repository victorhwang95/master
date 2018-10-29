import UIKit

public protocol AnimatedTextInputStyle {
    var activeColor: UIColor { get }
    var inactiveColor: UIColor { get }
    var lineInactiveColor: UIColor { get }
    var errorColor: UIColor { get }
    var textInputFont: UIFont { get }
    var textInputFontColor: UIColor { get }
    var placeholderMinFontSize: CGFloat { get }
    var counterLabelFont: UIFont? { get }
    var leftMargin: CGFloat { get }
    var topMargin: CGFloat { get }
    var rightMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var yHintPositionOffset: CGFloat { get }
    var yPlaceholderPositionOffset: CGFloat { get }
    var textAttributes: [String: Any]? { get }
}

public struct AnimatedTextInputStyleBlue: AnimatedTextInputStyle {

    public let activeColor = UIColor.init(hex: "30B3FF")
    public let inactiveColor = UIColor(hex: "FF8000")
    public let lineInactiveColor = UIColor.gray
    public let errorColor = UIColor.red
    public let textInputFont = UIFont.systemFont(ofSize: 14)
    public let textInputFontColor = UIColor.black
    public let placeholderMinFontSize: CGFloat = 9
    public let counterLabelFont: UIFont? = UIFont.systemFont(ofSize: 9)
    public let leftMargin: CGFloat = 0
    public let topMargin: CGFloat = 0
    public let rightMargin: CGFloat = 0
    public let bottomMargin: CGFloat = 0
    public let yHintPositionOffset: CGFloat = 0
    public let yPlaceholderPositionOffset: CGFloat = 0
    //Text attributes will override properties like textInputFont, textInputFontColor...
    public let textAttributes: [String: Any]? = nil

    public init() { }
}

public struct AnimatedTextInputStyleBlack: AnimatedTextInputStyle {
    
    public let activeColor = UIColor.init(hex: "30B3FF")
    public let inactiveColor = UIColor.black;
    public let lineInactiveColor = UIColor.gray
    public let errorColor = UIColor.red
    public let textInputFont = UIFont.systemFont(ofSize: 14)
    public let textInputFontColor = UIColor.black
    public let placeholderMinFontSize: CGFloat = 9
    public let counterLabelFont: UIFont? = UIFont.systemFont(ofSize: 9)
    public let leftMargin: CGFloat = 0
    public let topMargin: CGFloat = 0
    public let rightMargin: CGFloat = 0
    public let bottomMargin: CGFloat = 0
    public let yHintPositionOffset: CGFloat = 0
    public let yPlaceholderPositionOffset: CGFloat = 0
    //Text attributes will override properties like textInputFont, textInputFontColor...
    public let textAttributes: [String: Any]? = nil
    
    public init() { }
}

