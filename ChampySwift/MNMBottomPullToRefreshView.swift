
/*
 * Copyright (c) 2012 Mario Negro Martín
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
import Foundation
/**
 * Enumerates control state
 */
enum MNMBottomPullToRefreshViewState : Int {
  case idle = 0
  //<! The control is invisible right after being created or after a reloading was completed
  case pull
  //<! The control is becoming visible and shows "pull to refresh" message
  case release
  //<! The control is whole visible and shows "release to load" message
  case loading
}

/**
 * Pull to refresh view. Its state is managed by an instance of MNMBottomPullToRefreshManager.
 */
class MNMBottomPullToRefreshView: UIView {
  /**
   * Returns YES if view is in Loading state.
   */
  var containerView: UIView!
  /*
   * Image with the icon that changes with states
   */
  var iconImageView: UIImageView!
  /*
   * Activiry indicator to show while loading
   */
  var loadingActivityIndicator: UIActivityIndicatorView!
  /*
   * Label to set state message
   */
  var messageLabel: UILabel!
  /*
   * Current state of the control
   */
  var state:MNMBottomPullToRefreshViewState!
  /*
   * YES to apply rotation to the icon while view is in MNMBottomPullToRefreshViewStatePull state
   */
  var rotateIconWhileBecomingVisible = false
  
  var isLoading: Bool {
    return loadingActivityIndicator.isAnimating
  }
  
  
  /**
   * Fixed height of the view. This value is used to trigger the refreshing.
   */
  private(set) var fixedHeight: CGFloat = 0.0
  /**
   * Changes the state of the control depending on state value.
   *
   * Values of *MNMBottomPullToRefreshViewState*:
   *
   * - `MNMBottomPullToRefreshViewStateIdle` The control is invisible right after being created or after a reloading was completed.
   * - `MNMBottomPullToRefreshViewStatePull` The control is becoming visible and shows "pull to refresh" message.
   * - `MNMBottomPullToRefreshViewStateRelease` The control is whole visible and shows "release to load" message.
   * - `MNMBottomPullToRefreshViewStateLoading` The control is loading and shows activity indicator.
   *
   * @param state The state to set.
   * @param offset The offset of the table scroll.
   */
  
  func changeStateOfControl(_ state: MNMBottomPullToRefreshViewState, offset: CGFloat) {
    self.state = state
    var height: CGFloat = fixedHeight
    switch state {
    case .idle:
      
      iconImageView.isHidden = false
      loadingActivityIndicator.stopAnimating()
      messageLabel.text = MNM_BOTTOM_PTR_PULL_TEXT_KEY
      
    case .pull:
      if rotateIconWhileBecomingVisible {
      }
      else {
//        iconImageView.transform = CGAffineTransformIdentity
      }
      messageLabel.text = MNM_BOTTOM_PTR_PULL_TEXT_KEY
      
    case .release:
      iconImageView.transform = CGAffineTransform(rotationAngle: .pi)
      messageLabel.text = MNM_BOTTOM_PTR_RELEASE_TEXT_KEY
      height = fixedHeight + fabs(offset)
      
    case .loading:
      iconImageView.isHidden = true
      loadingActivityIndicator.startAnimating()
      messageLabel.text = MNM_BOTTOM_PTR_LOADING_TEXT_KEY
      height = fixedHeight + fabs(offset)
      
    default:
      break
    }
    
    var frame = self.frame
    frame.size.height = height
    self.frame = frame
    self.setNeedsLayout()
  }
  
  // MARK: -
  // MARK: Initialization
  /*
   * Initializes and returns a newly allocated view object with the specified frame rectangle.
   *
   * @param aRect: The frame rectangle for the view, measured in points.
   * @return An initialized view object or nil if the object couldn't be created.
   */
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
    self.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
    containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
    containerView.backgroundColor = UIColor.clear
    containerView.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    self.addSubview(containerView)
    let iconImage = UIImage(named: MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE)!
    iconImageView = UIImageView(frame: CGRect(x: 30.0, y: round(frame.height / 2.0) - round(iconImage.size.height / 2.0), width: iconImage.size.width, height: iconImage.size.height))
    iconImageView.contentMode = .center
    iconImageView.image = iconImage
    iconImageView.autoresizingMask = .flexibleRightMargin
    containerView.addSubview(iconImageView)
    loadingActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    loadingActivityIndicator.center = iconImageView.center
    loadingActivityIndicator.hidesWhenStopped = true
    loadingActivityIndicator.autoresizingMask = .flexibleRightMargin
    containerView.addSubview(loadingActivityIndicator)
    let topMargin: CGFloat = 10.0
    let gap: CGFloat = 20.0
    messageLabel = UILabel(frame: CGRect(x: iconImageView.frame.maxX + gap, y: topMargin, width: frame.size.width - iconImageView.frame.maxX - gap * 2.0, height: frame.height - topMargin * 2.0))
    messageLabel.backgroundColor = UIColor.clear
    messageLabel.textColor = UIColor.white
    messageLabel.autoresizingMask = .flexibleRightMargin
    containerView.addSubview(messageLabel)
    fixedHeight = frame.height
    rotateIconWhileBecomingVisible = true
    self.changeStateOfControl(.idle, offset: CGFloat.greatestFiniteMagnitude)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: -
  // MARK: Visuals
  /*
   * Lays out subviews.
   */
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    var frame = messageLabel.frame
    frame.size.width = messageLabel.frame.size.width
    messageLabel.frame = frame
    frame = containerView.frame
    frame.size.width = messageLabel.frame.maxX
    containerView.frame = frame
  }
}


let MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE = "MNMBottomPullToRefresh"
/*
 * Texts to show in different states
 */
let MNM_BOTTOM_PTR_PULL_TEXT_KEY = "Pull to get more..."
let MNM_BOTTOM_PTR_RELEASE_TEXT_KEY = "Release now!"
let MNM_BOTTOM_PTR_LOADING_TEXT_KEY = "Loading..."
/*
 * Defines icon image
 */
let MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE = "MNMBottomPullToRefreshArrow.png"
