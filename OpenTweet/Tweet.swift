//
//  Tweet.swift
//  OpenTweet
//
//  Created by Andre White on 5/17/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit
/**
 Main data model
 
 A tweet has at the minimum:
 
 * An id
 * An author
 * A content (e.g. the actual tweet)
 * A date (text format, in the standard ISO-8601 format)
 
 Additionally, a tweet may have:
 
 * A reference to the tweet ID it's replying to
 * A URL to the user's avatar
 * A list of image URLs
 */
struct Tweet:Decodable, Equatable{
    var id:String
    var author:String
    var content:String
    var date:String
    var inReplyTo:String?
    var avatar:String?
    var imageUrls:[String]?
}
/**
 Protocol for an object that can display a Tweet
 
 */
protocol TweetDisplayable{
    var authorLabel:UILabel!{get}
    var contentLabel:UILabel!{get}
    var dateLabel:UILabel!{get}
    var avatarImageView:UIImageView!{get}
}
extension TweetDisplayable{
    static var DisplayDateFormatter:DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }
    /**
     Displays a tweet
     - Parameter tweet : Tweet to display.
     */
    func display(tweet:Tweet){
        authorLabel?.text = tweet.author
        contentLabel?.text = tweet.content
        contentLabel?.attributedText = tweet.content.mentionColoredText
        contentLabel?.translatesAutoresizingMaskIntoConstraints = false
        if let date = ISO8601DateFormatter().date(from: tweet.date){
            dateLabel?.text = Self.DisplayDateFormatter.string(from: date)
        }
    }
}

public extension String{
    ///Returns an array of the NSRange matching a mention
    func mentionRanges() ->[NSRange]{
        do {
            let regex = try NSRegularExpression.init(pattern: "@[a-z]+[0-9]*[_]*[a-z]*[0-9]*", options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.count)
            let some = regex.matches(in: self, options: .init(), range: range)
            return some.map({$0.range})
        }catch{
            return []
        }
    }
    ///Returns an attributed string with each mention colored red.
    var mentionColoredText:NSAttributedString{
        let string = NSMutableAttributedString.init(string: self)
        for range in self.mentionRanges(){
            string.addAttribute(.foregroundColor, value: UIColor.red, range: range)
        }
        return string
    }
}
