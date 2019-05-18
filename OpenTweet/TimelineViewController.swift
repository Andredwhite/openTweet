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
    func repliesFromSender(sender:Any?)->[Tweet]?{
        guard let cell = sender as? UITableViewCell else {return nil}
        guard let path = self.tableView.indexPath(for: cell) else {return nil}
        return source.repliesToTweet(at: path)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? TimelineViewController else {return}
        guard let replies = repliesFromSender(sender: sender) else {return}
        dest.source = TimelineDataSource.init(tweets: replies)
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard source.timeLine.tweets.count > 1 else {return false}
        guard repliesFromSender(sender: sender)?.count ?? 0 > 1 else {return false}
        return true
    }
}

class TweetCell:UITableViewCell,TweetDisplayable{
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var contentTextView: UITextView!
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
