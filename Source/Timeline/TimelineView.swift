import UIKit
import Foundation
import Neon
import DateToolsSwift


protocol TimelineViewDelegate: class {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int)
}

public enum TimeLineInterval: Int {
    case TimeLineInterval1Hour = 1
    case TimeLineInterval30Minutes = 2
    case TimeLineInterval15Minutes = 4
    case TimeLineInterval10Minutes = 6
}

public struct TimeLineHoursPayload {
    public var startHour: Int = 0
    public var endHour: Int = 23
    
    var payload: ClosedRange<Int> {
        get {
            return self.startHour...self.endHour
        }
    }
    
    func checkTime(time: String) -> Bool {
        //FIXME: Make formatter in some global place
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let dateTime = dateFormatter.date(from: time) {
            if self.payload.contains(dateTime.hour) {
                return true
            }
        }
        return false
    }
}

public class TimelineView: UIView, ReusableView {

  weak var delegate: TimelineViewDelegate?

  weak var eventViewDelegate: EventViewDelegate?

  var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
    return Date()
  }

  var eventViews = [EventView]()
  var eventDescriptors = [EventDescriptor]() {
    didSet {
      recalculateEventLayout()
      prepareEventViews()
      setNeedsLayout()
    }
  }
  var pool = ReusePool<EventView>()

  var firstEventYPosition: CGFloat? {
    return eventViews.sorted{$0.frame.origin.y < $1.frame.origin.y}
      .first?.frame.origin.y
  }

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

  var style = TimelineStyle()

  var timeFont: UIFont {
    return UIFont.boldSystemFont(ofSize: fontSize)
  }
    
    var timeLineInterval: TimeLineInterval = TimeLineInterval.TimeLineInterval1Hour
    var timeLineHoursPayload: TimeLineHoursPayload = TimeLineHoursPayload()

  var verticalDiff: CGFloat = 45
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 53

  var horizontalEventInset: CGFloat = 3

  var fullHeight: CGFloat {
    //return verticalInset * 2 + verticalDiff * 24
    //return verticalInset * 2 + verticalDiff * 24 * CGFloat(self.timeLineInterval.rawValue)
    return verticalInset * 2 + verticalDiff * CGFloat(self.timeLineHoursPayload.payload.count) * CGFloat(self.timeLineInterval.rawValue)
  }

  var calendarWidth: CGFloat {
    return bounds.width - leftInset
  }

  var fontSize: CGFloat = 11

  var is24hClock = true {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    //return is24hClock ? _24hTimes : _12hTimes
    return is24hClock ? Generator.timeString24H_MIN(by: self.timeLineInterval) : _12hTimes
  }

  fileprivate lazy var _12hTimes: [String] = Generator.timeStrings12H()
  fileprivate lazy var _24hTimes: [String] = Generator.timeStrings24H()
    
  
  fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

  var isToday: Bool {
    return date.isToday
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    addSubview(nowLine)
    
    // Add long press gesture recognizer
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if (gestureRecognizer.state == .began) {
      // Get timeslot of gesture location
      let pressedLocation = gestureRecognizer.location(in: self)
      let percentOfHeight = (pressedLocation.y - verticalInset) / (bounds.height - (verticalInset * 2))
      let pressedAtHour: Int = Int(24 * percentOfHeight)
      delegate?.timelineView(self, didLongPressAt: pressedAtHour)
    }
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    nowLine.updateStyle(style.timeIndicator)
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)
        self.layoutTimes()
    }

  override public func layoutSubviews() {
    super.layoutSubviews()
    layoutTimes()
    recalculateEventLayout()
    layoutEvents()
    layoutNowLine()
  }

    func layoutTimes() {
        /*
        var hourToRemoveIndex = -1
        
        if isToday {
            let minute = currentTime.minute
            if minute > 39 {
                hourToRemoveIndex = currentTime.hour + 1
            } else if minute < 21 {
                hourToRemoveIndex = currentTime.hour
            }
        }
        */
        
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineBreakMode = .byWordWrapping
        style.alignment = .right
        
        let attributes = [NSParagraphStyleAttributeName: style,
                          NSForegroundColorAttributeName: self.style.timeColor,
                          NSFontAttributeName: timeFont] as [String : Any]
        
        for (i, time) in times.enumerated() {
            if self.timeLineHoursPayload.checkTime(time: time) {
                let iFloat = CGFloat(i)
                let context = UIGraphicsGetCurrentContext()
                //context!.interpolationQuality = .none
                context?.interpolationQuality = .none
                context?.saveGState()
                context?.setStrokeColor(self.style.lineColor.cgColor)
                context?.setLineWidth(onePixel)
                context?.translateBy(x: 0, y: 0.5)
                let x: CGFloat = 53
                //let y = verticalInset + iFloat * verticalDiff
                let y = verticalInset + (iFloat - CGFloat(self.timeLineHoursPayload.startHour * self.timeLineInterval.rawValue)) * verticalDiff
                context?.beginPath()
                context?.move(to: CGPoint(x: x, y: y))
                context?.addLine(to: CGPoint(x: (bounds).width, y: y))
                context?.strokePath()
                context?.restoreGState()
                
                //print("\(i)")
                /*
                if i == hourToRemoveIndex {
                    continue
                }
                */
                
                //let timeRect = CGRect(x: 2, y: iFloat * verticalDiff + verticalInset - 7, width: leftInset - 8, height: fontSize + 2)
                let timeRect = CGRect(x: 2, y: (iFloat - CGFloat(self.timeLineHoursPayload.startHour * self.timeLineInterval.rawValue)) * verticalDiff + verticalInset - 7, width: leftInset - 8, height: fontSize + 2)
                
                let timeString = NSString(string: time)
                
                timeString.draw(in: timeRect, withAttributes: attributes)
            }
        }
    }
    
  public func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
    } else {
      bringSubview(toFront: nowLine)
      nowLine.alpha = 1
      let size = CGSize(width: bounds.size.width, height: 20)
      let rect = CGRect(origin: CGPoint.zero, size: size)
      nowLine.date = currentTime
      nowLine.frame = rect
      nowLine.center.y = dateToY(currentTime)
    }
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}

    for (idx, descriptor) in eventDescriptors.enumerated() {
      let eventView = eventViews[idx]
      eventView.frame = descriptor.frame
      eventView.updateWithDescriptor(event: descriptor)
    }
  }

  func recalculateEventLayout() {
    let day = TimePeriod(beginning: date.dateOnly(),
                         chunk: TimeChunk(seconds: 0,
                                          minutes: 0,
                                          hours: 0,
                                          days: 1,
                                          weeks: 0,
                                          months: 0,
                                          years: 0))

    let validEvents = eventDescriptors.filter {$0.datePeriod.overlaps(with: day)}
      .sorted {$0.datePeriod.beginning!.isEarlier(than: $1.datePeriod.beginning!)}

    var groupsOfEvents = [[EventDescriptor]]()
    var overlappingEvents = [EventDescriptor]()

    for event in validEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }
      if overlappingEvents.last!.datePeriod.overlaps(with: event.datePeriod) {
        overlappingEvents.append(event)
        continue
      } else {
        groupsOfEvents.append(overlappingEvents)
        overlappingEvents.removeAll()
        overlappingEvents.append(event)
      }
    }

    groupsOfEvents.append(overlappingEvents)
    overlappingEvents.removeAll()

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)
      for (index, event) in overlappingEvents.enumerated() {
        let startY = dateToY(event.datePeriod.beginning!)
        let endY = dateToY(event.datePeriod.end!)
        let floatIndex = CGFloat(index)
        let x = leftInset + floatIndex / totalCount * calendarWidth
        let equalWidth = calendarWidth / totalCount
        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
      }
    }
  }

  func prepareEventViews() {
    for _ in 0...eventDescriptors.endIndex {
      let newView = pool.dequeue()
      newView.delegate = eventViewDelegate
      if newView.superview == nil {
        addSubview(newView)
      }
      eventViews.append(newView)
    }
  }

  func prepareForReuse() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    setNeedsDisplay()
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date) -> CGFloat {
    if date.dateOnly() > self.date.dateOnly() {
      // Event ending the next day
      //return 24 * verticalDiff + verticalInset
      //return (24 * CGFloat(self.timeLineInterval.rawValue)) * (verticalDiff * CGFloat(self.timeLineInterval.rawValue)) + verticalInset
      return (CGFloat(self.timeLineHoursPayload.payload.count) * CGFloat(self.timeLineInterval.rawValue)) * (verticalDiff * CGFloat(self.timeLineInterval.rawValue)) + verticalInset
    } else if date.dateOnly() < self.date.dateOnly() {
      // Event starting the previous day
      return verticalInset
    } else {
      //let hourY = CGFloat(date.hour) * verticalDiff + verticalInset
      //let hourY = CGFloat(date.hour) * (verticalDiff * CGFloat(self.timeLineInterval.rawValue)) + verticalInset
      let hourY = CGFloat(date.hour - self.timeLineHoursPayload.startHour) * (verticalDiff * CGFloat(self.timeLineInterval.rawValue)) + verticalInset
      //let minuteY = CGFloat(date.minute) * verticalDiff / 60
      let minuteY = CGFloat(date.minute) * (verticalDiff * CGFloat(self.timeLineInterval.rawValue)) / 60
      return hourY + minuteY
    }
  }
}
