import UIKit

typealias TimeLineContainerBlock = () -> Void

class TimelineContainer: UIScrollView, ReusableView {

  var timeline: TimelineView!

    public var timeLineContainerRefreshCompletion: TimeLineContainerBlock?

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
            self.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
    }
    
    func refreshAction() {
         if let completion = self.timeLineContainerRefreshCompletion {
            completion()
         }
    }

  override func layoutSubviews() {
    timeline.frame = CGRect(x: 0, y: 0, width: frame.width, height: timeline.fullHeight)
  }

  func prepareForReuse() {
    timeline.prepareForReuse()
  }

  func scrollToFirstEvent() {
    let yToScroll = timeline.firstEventYPosition ?? 0
    setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll), animated: true)
  }
  
  func scrollTo(hour24: Float) {
    let percentToScroll = CGFloat(hour24 / 24)
    let yToScroll = contentSize.height * percentToScroll
    let padding: CGFloat = 8
    setContentOffset(CGPoint(x: contentOffset.x, y: yToScroll - padding), animated: true)
  }
    
}
