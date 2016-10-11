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
 * Delegate protocol to implement by MNMBottomPullToRefreshManager observers to track and manage pull-to-refresh view behavior.
 */
protocol MNMBottomPullToRefreshManagerClient: class {
  /**
   * This is the same delegate method of UIScrollViewDelegate but required in MNMBottomPullToRefreshManagerClient protocol
   * to warn about its implementation.
   *
   * In the implementacion call [MNMBottomPullToRefreshManager tableViewScrolled] to indicate that the table is scrolling.
   *
   * @param scrollView The scroll-view object in which the scrolling occurred.
   */
  func scrollViewDidScroll(_ scrollView: UIScrollView)
  /**
   * This is the same delegate method of UIScrollViewDelegate but required in MNMBottomPullToRefreshClient protocol
   * to warn about its implementation.
   *
   * In the implementacion call [MNMBottomPullToRefreshManager tableViewReleased] to indicate that the table has been released.
   *
   * @param scrollView The scroll-view object that finished scrolling the content view.
   * @param decelerate YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
   */
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  /**
   * Tells client that refresh has been triggered.
   *
   * After reload is completed call [MNMBottomPullToRefreshManager tableViewReloadFinished] to get back the view to Idle state
   *
   * @param manager The pull to refresh manager.
   */
  
  func bottomPull(toRefreshTriggered manager: MNMBottomPullToRefreshManager)
}
// MARK: -
/**
 * Manager that plays Mediator role and manages relationship between pull-to-refresh view and its associated table.
 */
class MNMBottomPullToRefreshManager: NSObject {
  
  /*
   * Pull-to-refresh view
   */
  var pullToRefreshView: MNMBottomPullToRefreshView!
  /*
   * Table view which p-t-r view will be added
   */
  weak var table: UITableView!
  /*
   * Client object that observes changes
   */
  weak var client: MNMBottomPullToRefreshManagerClient!
  
  /**
   * Initializes the manager object with the information to link the view and the table.
   *
   * @param height The height that the pull-to-refresh view will have.
   * @param table Table view to link pull-to-refresh view to.
   * @param client The client that will observe behavior.
   */
  
  override init() {
    
  }
  
  init(pullToRefreshViewHeight height: CGFloat, tableView table: UITableView, with client: MNMBottomPullToRefreshManagerClient) {
    super.init()
    
    self.client = client
    self.table = table
    pullToRefreshView = MNMBottomPullToRefreshView(frame: CGRect(x: 0.0, y: 0.0, width: table.frame.width, height: height))
    
  }
  /**
   * Relocate pull-to-refresh view at the bottom of the table taking into account the frame and the content offset.
   */
  
  func relocatePullToRefreshView() {
    var yOrigin: CGFloat = 0.0
    if table.contentSize.height >= table.frame.height {
      yOrigin = table.contentSize.height
    }
    else {
      yOrigin = table.frame.height
    }
    var frame = pullToRefreshView.frame
    frame.origin.y = yOrigin
    pullToRefreshView.frame = frame
    table.addSubview(pullToRefreshView)
  }
  /**
   * Sets the pull-to-refresh view visible or not. Visible by default.
   *
   * @param visible YES to make visible.
   */
  
  func setPullToRefreshViewVisible(_ visible: Bool) {
    pullToRefreshView.isHidden = !visible
  }
  /**
   * Has to be called when the table is being scrolled. Checks the state of control depending on the offset of the table.
   */
  
  func tableViewScrolled() {
    if !pullToRefreshView.isHidden && !pullToRefreshView.isLoading {
      let offset: CGFloat = self.tableScrollOffset()
      if offset >= 0.0 {
        pullToRefreshView.changeStateOfControl(.idle, offset: offset)
      }
      else if offset <= 0.0 && offset >= -pullToRefreshView.fixedHeight {
        pullToRefreshView.changeStateOfControl(.pull, offset: offset)
      }
      else {
        pullToRefreshView.changeStateOfControl(.release, offset: offset)
      }
    }
  }
  /**
   * Has to be called when table dragging ends. Checks the triggering of the refresh.
   */
  
  func tableViewReleased() {
    if !pullToRefreshView.isHidden && !pullToRefreshView.isLoading {
      let offset: CGFloat = self.tableScrollOffset()
      let height: CGFloat = -pullToRefreshView.fixedHeight
      if offset <= 0.0 && offset < height {
        client.bottomPull(toRefreshTriggered: self)
        pullToRefreshView.changeStateOfControl(.loading, offset: offset)
        UIView.animate(withDuration: TimeInterval(kAnimationDuration), animations: {() -> Void in
          if self.table.contentSize.height >= self.table.frame.height {
            self.table.contentInset = UIEdgeInsetsMake(0.0, 0.0, -height, 0.0)
          }
          else {
            self.table.contentInset = UIEdgeInsetsMake(height, 0.0, 0.0, 0.0)
          }
        })
      }
    }
  }
  /**
   * Indicates that the reload of the table is completed. Resets the state of the view to Idle.
   */
  
  func tableViewReloadFinished() {
    table.contentInset = .zero
    self.relocatePullToRefreshView()
    pullToRefreshView.changeStateOfControl(.idle, offset: CGFloat.greatestFiniteMagnitude)
  }
  
  // MARK: -
  // MARK: Instance initialization
  /*
   * Initializes the manager object with the information to link view and table
   */
  // MARK: -
  // MARK: Visuals
  /*
   * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
   */
  
  func tableScrollOffset() -> CGFloat {
    var offset: CGFloat = 0.0
    if table.contentSize.height < table.frame.height {
      offset = -table.contentOffset.y
    }
    else {
      offset = (table.contentSize.height - table.contentOffset.y) - table.frame.height
    }
    return offset
  }
  /*
   * Relocate pull-to-refresh view
   */
  /*
   * Sets the pull-to-refresh view visible or not. Visible by default
   */
  // MARK: -
  // MARK: Table view scroll management
  /*
   * Checks state of control depending on tableView scroll offset
   */
  /*
   * Checks releasing of the tableView
   */
  /*
   * The reload of the table is completed
   */
  
 
}

let kAnimationDuration: CGFloat = 0.2
