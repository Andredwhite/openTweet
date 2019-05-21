//
//  OpenTweetTests.swift
//  OpenTweetTests
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import XCTest
@testable import OpenTweet

class OpenTweetTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testCanDisplayTweet(){
        let tweet = createTestTweet(id: "1", author: "@Tester1", replying: nil)
        let displayer = TestDisplay(empty: false)
        displayer.display(tweet: tweet)
        XCTAssertTrue(displayer.authorLabel.text == tweet.author)
        XCTAssertTrue(displayer.contentLabel.text == tweet.content)
        let date = ISO8601DateFormatter().date(from: tweet.date)!
        XCTAssertTrue(displayer.dateLabel.text == TestDisplay.DisplayDateFormatter.string(from: date))
    }
    func testTimeLineLoadNotEmpty(){
        let timeline = TimeLine.MasterTimeLine
        XCTAssertTrue(timeline.tweets.count > 0)
    }
    func testRepliesToTweetNotEmptyOrNil(){
        let tweet = createTestTweet(id: "1", author: "@Tester", replying: nil)
        let reply = createTestTweet(id: "2", author: "@OtherTester", replying: "1")
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [tweet,reply])
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        let replies = displayer.repliesToTweet(at: IndexPath.FirstInFirst)
        XCTAssertNotNil(replies)
        XCTAssertTrue(replies?.count != 0)
        XCTAssertTrue(replies?.contains(reply) ?? false)
        XCTAssertTrue(replies?.contains(tweet) ?? false)
    }
    func testRepliesContainsAll(){
        let tweet = createTestTweet(id: "1", author: "@Tester", replying: nil)
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [tweet])
        let testReplies = buildReplies()
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        let replies = displayer.repliesToTweet(at: IndexPath.FirstInFirst)
        for reply in testReplies{
            XCTAssertTrue(replies?.contains(reply) ?? false)
        }
    }
    func testRepliesAreAscending(){
        let tweet = createTestTweet(id: "1", author: "@Tester", replying: nil)
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [tweet])
        let _ = buildReplies()
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        let replies = displayer.repliesToTweet(at: IndexPath.FirstInFirst)!
        var index = replies.indices.last!
        while (index != 0){
            XCTAssertGreaterThanOrEqual(replies[index].date, replies[index - 1].date)
            index -= 1
        }
    }
    func testTweetAtIsNil(){
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [])
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        XCTAssertNil(displayer.tweet(at: IndexPath.FirstInFirst))
    }
    func testTweetAtNotNil(){
        let tweet = createTestTweet(id: "1", author: "@Tester", replying: nil)
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [tweet])
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        XCTAssertNotNil(displayer.tweet(at: IndexPath.FirstInFirst))
    }
    func testDisplayAt(){
        let tweet = createTestTweet(id: "1", author: "@Tester", replying: nil)
        TimeLine.MasterTimeLine = TimeLine.init(tweets: [tweet])
        let displayer = TimeLineDisplay.init(timeLine: TimeLine.MasterTimeLine)
        let display = TestDisplay(empty: false)
        displayer.displayTweet(at: IndexPath.FirstInFirst, in: display)
        XCTAssertTrue(display.authorLabel.text == tweet.author)
        XCTAssertTrue(display.contentLabel.text == tweet.content)
        let date = ISO8601DateFormatter().date(from: tweet.date)!
        XCTAssertTrue(display.dateLabel.text == TestDisplay.DisplayDateFormatter.string(from: date))
    }
    func testOneMentions(){
        let tweet = "This is a tweet with a mention @tester"
        let ranges =  tweet.mentionRanges()
    XCTAssertTrue(ranges.contains(NSRange.init(tweet.range(of: "@tester")!, in:tweet)))
        
        XCTAssertTrue(ranges.count == 1)
    }
    func testNoMentions(){
        let tweet = "Test no mentions"
        let ranges = tweet.mentionRanges()
        XCTAssertTrue(ranges.count == 0)
    }
    
    func testNoMentionsEmpty(){
        let tweet = ""
        let ranges = tweet.mentionRanges()
        XCTAssertTrue(ranges.count == 0)
    }
    
    func testManyMentions(){
        let tweet = "@Test saw @Test3 at the @test7 with @Test9 and @"
        let ranges = tweet.mentionRanges()
        XCTAssertTrue(ranges.contains(NSRange.init(tweet.range(of: "@Test")!, in:tweet)))
        XCTAssertTrue(ranges.contains(NSRange.init(tweet.range(of: "@Test3")!, in:tweet)))
        XCTAssertTrue(ranges.contains(NSRange.init(tweet.range(of: "@test7")!, in:tweet)))
        XCTAssertTrue(ranges.contains(NSRange.init(tweet.range(of: "@Test9")!, in:tweet)))
        XCTAssertTrue(ranges.count==4)
    }
}
/**
 Helper Objects and Functions
 */
extension IndexPath{
    static var FirstInFirst:IndexPath{
        return IndexPath.init(row: 0, section: 0)
    }
}
extension OpenTweetTests{
    struct TestDisplay:TweetDisplayable{
        var contentLabel: UILabel!
        var authorLabel: UILabel!
        var dateLabel: UILabel!
        var avatarImageView: UIImageView!
        init(empty:Bool){
            if !empty{
                authorLabel = UILabel()
                contentLabel = UILabel()
                dateLabel = UILabel()
                avatarImageView = UIImageView()
            }
        }
    }
    struct TimeLineDisplay:TimeLineDisplayable{
        var parentTweet: Tweet? {
            return nil
        }
        var timeLine: TimeLine
    }
    func createTestTweet(id:String, author:String, replying to:String?)->Tweet{
        return Tweet.init(id: id, author: author, content: "Some Test Tweet", date: ISO8601DateFormatter().string(from: Date.init(timeIntervalSinceNow: 0)), inReplyTo: to, avatar: nil, imageUrls: nil)
    }
    func buildReplies()->[Tweet]{
        var testReplies:[Tweet] = []
        var num = 2
        while(num <= 10){
            let numString = String(num)
            let reply = createTestTweet(id: numString, author: "@Tester"+numString, replying: "1")
            TimeLine.MasterTimeLine.tweets.append(reply)
            testReplies.append(reply)
            num += 1
        }
        return testReplies
    }
}
