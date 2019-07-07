//
//  Model.swift
//  OpenTweet
//
//  Created by Andre White on 7/6/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

struct User:Hashable {
    let identifier = UUID()
    let userName:String
    let aviUrl:String?
}
struct Tweet:Hashable,Decodable{
    let identifier:String
    let date:Date
    let author:User
    let content:String
    let replyId:String?
    
    enum CodingKeys:String, CodingKey{
        case identifier = "id"
        case author
        case avatar
        case date
        case replyId = "inReplyTo"
        case content
    }
    
    init(from decoder: Decoder) throws {
        let some = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try some.decode(String.self, forKey: .identifier)
        let dateString = try some.decode(String.self, forKey: .date)
        date = ISO8601DateFormatter().date(from: dateString)!
        let authorName = try some.decode(String.self, forKey: .author)
        let avi = try? some.decode(String.self, forKey: .avatar)
        author = User.init(userName: authorName, aviUrl: avi)
        content = try some.decode(String.self, forKey: .content)
        replyId = try? some.decode(String.self, forKey: .replyId)
    }
}
struct TimeLine:Decodable{
    var timeline:[Tweet]
}
struct TimeLineCollectionViewConfiguration{
    enum Section{
        case main
    }
    struct CellConfiguration{
        let identifier:String = "Tweet"
        var configureCell:(UICollectionViewCell)->Void {
            return { cell in
                (cell as? TweetDisplayable)?.display(tweet: self.tweet)
            }
        }
        var tweet:Tweet
    }
    var dataSource:UICollectionViewDiffableDataSource<Section,Tweet>! = nil
    let layout:UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        let layout = UICollectionViewCompositionalLayout.init(section: section)
        return layout
    }()
    init(collectionView:UICollectionView){
        collectionView.setCollectionViewLayout(layout, animated: true)
        self.dataSource = UICollectionViewDiffableDataSource<Section,Tweet>(collectionView: collectionView, cellProvider: { (view, path, tweet) -> UICollectionViewCell? in
            let config = CellConfiguration.init(tweet: tweet)
            let cell = view.dequeueReusableCell(withReuseIdentifier: config.identifier, for: path)
            config.configureCell(cell)
            return cell
        })
        let snapshot = NSDiffableDataSourceSnapshot<Section, Tweet>()
        snapshot.appendSections([.main])
        let pathString = Bundle.main.path(forResource: "timeline", ofType: "json")!
        let path = URL.init(fileURLWithPath: pathString)
        let json = try! Data.init(contentsOf: path, options: Data.ReadingOptions.mappedIfSafe)
        let timeline = try! JSONDecoder().decode(TimeLine.self, from: json)
        snapshot.appendItems(timeline.timeline)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}
protocol UserDisplayable{
    var aviImageview:UIImageView! {get}
    var userNameLabel:UILabel! {get}
}
protocol TweetDisplayable:UserDisplayable{
    var contentTextView:UITextView! {get}
    var dateLabel:UILabel! {get}
}
extension UserDisplayable{
    func display(user:User){
        userNameLabel?.text = user.userName
    }
}
extension TweetDisplayable{
    func display(tweet:Tweet){
        self.display(user: tweet.author)
        self.contentTextView.text = tweet.content
        self.dateLabel.text = tweet.date.Display
    }
}
extension Date{
    var Display:String{
        let format = DateFormatter()
        format.dateFormat = "EEE MM/dd/yyyy HH:mm a"
        return format.string(from: self)
    }
}
class TweetCell:UICollectionViewCell,TweetDisplayable{
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var aviImageview: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
}
class TimeViewController:UICollectionViewController{
    var config:TimeLineCollectionViewConfiguration!
    override func viewDidLoad() {
        self.config = TimeLineCollectionViewConfiguration.init(collectionView: self.collectionView)
    }
}
