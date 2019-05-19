//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    var source: TimeLineDisplayable! = TimelineDataSource.init()
	override func viewDidLoad() {
		super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.dataSource = source as? UITableViewDataSource
    }
    /**
     Returns a tuple with the tweet corresponding to the cell that was selected as well as the replies to that tweet, or nil if either are nil
     - Parameter sender: UITableViewCell that initated the segue.
    */
    func repliesFromSender(sender:Any?)->(Tweet,[Tweet])?{
        guard let cell = sender as? UITableViewCell else {return nil}
        guard let path = self.tableView.indexPath(for: cell) else {return nil}
        guard let tweet = source.tweet(at: path) else {return nil}
        guard let tweets = source.repliesToTweet(at: path) else {return nil}
        return (tweet, tweets)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? TimelineViewController else {return}
        guard let replies = repliesFromSender(sender: sender) else {return}
        dest.source = TimelineDataSource.init(tweets: replies.1, parent: replies.0)
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard source.timeLine.tweets.count > 1 else {return false}
        let tuple = repliesFromSender(sender: sender)
        guard tuple?.1.count ?? 0 > 1 else {return false}
        return tuple?.0 ?? nil != source.parentTweet
    }
}

class TweetCell:UITableViewCell,TweetDisplayable{
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
}
extension TimelineDataSource:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath) as! TweetCell
        self.displayTweet(at: indexPath, in: cell)
        return cell
    }
}
