//
//  HomeViewController.swift
//  Pet App
//
//  Created by maya on 2020/09/24.
//

import UIKit
import AnimatedCollectionViewLayout
import AVFoundation
import MediaPlayer
import AVKit
import Firebase

class HomeViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource {
    //var ref = Database.database().reference()
    let storage = Storage.storage()
    
    //let userDefaults = UserDefaults.standard
    
    let isInfinity = true //無限スクロール
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userName: UILabel!
    
    var player: AVPlayer?
    
    var pageCount = 10
    var contentsArray = [Contents]()
    var color: [UIColor] = [.red, .yellow, .green, .blue, .purple, .systemIndigo, .cyan ]
    
    //var playerController = AVPlayerLayer()
    //var player = AVPlayer()
    private var observers: (NSObjectProtocol)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let storageRef = storage.reference(forURL: "gs://pet-app-8ad40.appspot.com")
        //ref = Database.database().reference()
        self.fetchContentsData()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.layoutCollection()
        let fileName = "Dog - 14869"
        let fileExtension = "mp4"
        let sampleUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
        //player = AVPlayer(url: sampleUrl)
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            let storyboard: UIStoryboard = self.storyboard!
            let nextVC = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
            self.present(nextVC, animated: true, completion: nil)
        } 
    }
    
    func layoutCollection() {
        let layout = AnimatedCollectionViewLayout()
        layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.width)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        layout.animator = ParallaxAttributesAnimator()
        collectionView.collectionViewLayout = layout
    }
    
    //セクションごとのセル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //実際のセル数の3倍用意
        return isInfinity ? pageCount * 3 : pageCount
    }
    //セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let fixedIndex = isInfinity ? indexPath.row % pageCount : indexPath.row
        //let url = contentsArray[fixedIndex].videoString
       // player = AVPlayer(url: URL(string: url)!)
        
        let moviePlayerLayer = AVPlayerLayer()
        moviePlayerLayer.player = player
        moviePlayerLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
        moviePlayerLayer.videoGravity = .resizeAspectFill
        cell.layer.insertSublayer(moviePlayerLayer, at: 0)
        player?.play()
        //cell.backgroundColor = color[fixedIndex]
        return cell
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //carouselView.scrollToFirstItem()
    }
    
    
    func fetchContentsData() {
        print(DataEventType.value)
        //child以降は新しい順に並べ替え
        let ref = Database.database().reference().child("timeline").queryLimited(toLast: 10).queryOrdered(byChild: "postDate").observe(.value){ (snapShot) in
            //この前で止まる
            self.contentsArray.removeAll()
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let postData = snap.value as? [String:Any] {
                        let userID = postData["uid"]
                        let userName = postData["author"] as? String
                        //let userImage = postData["profileImage"] as? String
                        let url = postData["videoURL"] as? String
                        //let transfer = postData["transfer"] as? Bool
                        var postDate: CLong?
                        if let postedDate = postData["postDate"] as? CLong {
                            postDate = postedDate
                        }
                        let timeString = self.convertTimeStamp(serverTimeStamp: postDate!)
                        self.contentsArray.append(Contents(userNameString: userName!, videoString: url!, postDateString: timeString))
//                        self.contentsArray.append(Contents(userNameString: userName!, profileImageString: userImage!, videoString: url!, postDateString: timeStringTransfer: transfer!))
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }

    func convertTimeStamp(serverTimeStamp: CLong) -> String {
        let x = serverTimeStamp / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(x))
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



