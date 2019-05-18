//
//  TimeLine.swift
//  OpenTweet
//
//  Created by Andre White on 5/18/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit
/**
 Container for Tweets. Decoded from the timeline.json file.
 */
struct TimeLine:Decodable{
    /**
     Master TimeLine object lazily loaded from the json file. If the GetTweets function returns nil, this will have an empty timeline. (timeline with no tweets)
     
     */
    static var MasterTimeLine:TimeLine = {
        return GetTweets() ?? TimeLine.init(tweets:[])
    }()
    /**
     Loads TimeLine from timeline.json file or nil if the load fails.
     
     */
    private static func GetTweets()->TimeLine?{
        guard let pathString = Bundle.main.path(forResource: "timeline", ofType: "json")else {return nil}
        let path = URL.init(fileURLWithPath: pathString)
        guard let json = try? Data.init(contentsOf: path, options: Data.ReadingOptions.mappedIfSafe) else {return nil}
        guard let timeline = try? JSONDecoder().decode(TimeLine.self, from: json) else {return nil}
        return timeline
    }
    /**
     Returns an array of tweets from the MasterTimeLine, where the first tweet is the object queried and every subsequent tweet is a reply sorted by date, ascending.
     - Parameter tweet : Tweet to find replies for.
     */
    static func RepliesTo(tweet:Tweet)->[Tweet]{
        var tweets = [tweet]
        let replies = TimeLine.MasterTimeLine.tweets.filter({$0.inReplyTo == tweet.id}).sorted(by: {$0.date < $1.date})
        tweets.append(contentsOf: replies)
        return tweets
    }
    var tweets:[Tweet]
    /**
     Custom Coding Key for readability
     */
    enum CodingKeys:String,CodingKey{
        case tweets = "timeline"
    }
}
/**
 Protocol for an object that can display a Timeline.
 
 */
protocol TimeLineDisplayable{
    var timeLine:TimeLine{get}
    var tweetCount:Int {get}
    func tweet(at indexPath:IndexPath)->Tweet?
    func displayTweet(at indexPath:IndexPath, in displayable:TweetDisplayable)
}
extension TimeLineDisplayable{
    var tweetCount:Int{
        return timeLine.tweets.count
    }
    func displayTweet(at indexPath:IndexPath, in displayable:TweetDisplayable){
        guard let tweet = tweet(at: indexPath) else {return}
        displayable.display(tweet: tweet)
    }
    func tweet(at indexPath:IndexPath)->Tweet?{
        guard indexPath.section == 0 else {return nil}
        guard indexPath.row < timeLine.tweets.count  else {return nil}
        return timeLine.tweets[indexPath.row]
    }
    func repliesToTweet(at indexPath:IndexPath)->[Tweet]?{
        guard let tweet = tweet(at: indexPath) else {return nil}
        return TimeLine.RepliesTo(tweet: tweet)
    }
}
/**
 ViewModel for timeline. Conforms to TimeLineDisplayable to display a TimeLine as well as UITableViewDataSource to display in a UITableView.
 */
class TimelineDataSource:NSObject,TimeLineDisplayable{
    var timeLine:TimeLine
    init(timeLine:TimeLine){
        self.timeLine = timeLine
        super.init()
    }
    convenience init(tweets:[Tweet]){
        self.init(timeLine: TimeLine.init(tweets: tweets))
    }
    convenience override init() {
        self.init(timeLine: TimeLine.MasterTimeLine)
    }
}


