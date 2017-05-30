import UIKit
import DateToolsSwift
import DynamicColor

open class Event: EventDescriptor {
    public var allDay = false
  public var datePeriod = TimePeriod()
  public var text = ""
  public var color = UIColor.blue {
    didSet {
      textColor = color.darkened(amount: 0.3)
      //backgroundColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0.3)
      backgroundColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1.0)
    }
  }
  public var backgroundColor = UIColor()
  public var textColor = UIColor()
  public var frame = CGRect.zero
    public var userInfo: Any?
    public var rightCornerIcon: String?
  public init() {}
}
