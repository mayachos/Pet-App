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
    let storage = Storage.storage()
    let ref = Database.database().reference()
    var snap: DataSnapshot!
    var loadTimer: Timer?
    
    //let userDefaults = UserDefaults.standard
    
    let isInfinity = true //無限スクロール
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userName: UILabel!
    
    var player: AVPlayer?
    
   //let dispatchQueue = DispatchQueue()
    var pageCount = 10
    var contentsArray = [DataSnapshot]()
    var color: [UIColor] = [.red, .yellow, .green, .blue, .purple, .systemIndigo, .cyan ]
    
    //var playerController = AVPlayerLayer()
    //var player = AVPlayer()
    private var observers: (NSObjectProtocol)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //let storageRef = storage.reference(forURL: "gs://pet-app-8ad40.appspot.com")
        self.fetchContentsData()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.layoutCollection()
//        if let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/pet-app-8ad40.appspot.com/o/video.mp4"){
//
//            let asset = AVAsset(url: url)
//            let playerItem = AVPlayerItem(asset: asset)
//            let player = AVPlayer(playerItem: playerItem)
//            player.play()
//        }
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
        pageCount = contentsArray.count
        return pageCount
    }
    //セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if snap != nil {
            let item = contentsArray[indexPath.row]
            let content = item.value as! Dictionary<String, Any>
            
            let url = String(describing: content["videoURL"]!)
            player = AVPlayer(url: URL(fileURLWithPath: url))
            print(url)
            let uName = String(describing: content["author"]!)
            userName.text = uName
            
        } else {
            let fileName = "Dog - 14869"
            let fileExtension = "mp4"
            let sampleUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
            player = AVPlayer(url: sampleUrl)
        }
        
        let moviePlayerLayer = AVPlayerLayer()
        moviePlayerLayer.player = player
        moviePlayerLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
        moviePlayerLayer.videoGravity = .resizeAspectFill
        cell.layer.insertSublayer(moviePlayerLayer, at: 0)
        //cell.backgroundColor = color[fixedIndex]
        
        return cell
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //carouselView.scrollToFirstItem()
        self.collectionView.reloadData()
    }
    
    
    func fetchContentsData() {
        //child以降は新しい順に並べ替え
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            
            ref.child("timeline").observe(.value, with: { (snapShot) in
                //この前で止まる
                dump(snapShot)
                //if snapShot.children.allObjects is DataSnapshot {
                print("snapShots.children...\(snapShot.childrenCount)") //いくつのデータがあるかプリント
                
                print("snapShot...\(snapShot)") //読み込んだデータをプリント
                
                self.snap = snapShot
                //}
                self.reload()
            })
        }
    }
    
    func reload() {
        if snap != nil {
            print(snap)
            self.contentsArray.removeAll()
            for item in snap.children {
                    //if let postData = item.value as? [String:Any] {
//                        let userID = postData["uid"]
//                        let userName = postData["author"] as? String
//                        //let userImage = postData["profileImage"] as? String
//                        let url = postData["videoURL"] as? String
//                        //let transfer = postData["transfer"] as? Bool
//                        var postDate: CLong?
//                        if let postedDate = postData["postDate"] as? CLong {
//                            postDate = postedDate
//                        }
//                        let timeString = self.convertTimeStamp(serverTimeStamp: postDate!)
//                        self.contentsArray.append(Contents(userNameString: userName!, videoURL: url!, postDateString: timeString))
                contentsArray.append(item as! DataSnapshot)
                print(item)
            }
            ref.child("timeline").keepSynced(true)
            //self.collectionView.reloadData()
            //                        self.contentsArray.append(Contents(userNameString: userName!, profileImageString: userImage!, videoString: url!, postDateString: timeStringTransfer: transfer!))
        }
    }
    @IBAction func playButton() {
        player!.play()
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



