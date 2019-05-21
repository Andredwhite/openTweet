//
//  Tweet.swift
//  OpenTweet
//
//  Created by Andre White on 5/17/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
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
    var contentTextView:UITextView!{get}
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
        contentTextView?.text = tweet.content
        contentTextView?.attributedText = tweet.content.mentionColoredText
        contentTextView?.translatesAutoresizingMaskIntoConstraints = false
        if let date = ISO8601DateFormatter().date(from: tweet.date){
            dateLabel?.text = Self.DisplayDateFormatter.string(from: date)
        }
        if let avatar = tweet.avatar, let url = URL.init(string: avatar){
            avatarImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false) { (response) in
                (self as? UITableViewCell)?.setNeedsLayout()
                self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
            }
        }else{
            avatarImageView.image = nil
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
        let font = UIFont.systemFont(ofSize: 17)
        string.addAttribute(.font, value: font, range: NSRange.init(location: 0, length: self.count))
        return string
    }
}
