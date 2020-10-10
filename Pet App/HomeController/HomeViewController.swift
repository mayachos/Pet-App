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
import NVActivityIndicatorView

class HomeViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource {
    let ref = Database.database().reference()
    var snap: DataSnapshot!
    var loadTimer: Timer?
    var activityIndicatorView: NVActivityIndicatorView!
    let user = Auth.auth().currentUser
    let userDefaults = UserDefaults.standard
    
    //let userDefaults = UserDefaults.standard
    
    let isInfinity = true //無限スクロール
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var profileImageButton: UIButton!
    @IBOutlet var userName: UILabel!
    @IBOutlet var goodButton: UIButton!
    
    var player: AVPlayer?
    let moviePlayerLayer = AVPlayerLayer()
    var adopt = false
    var userId: String!
    var key: String!
    var good: Int = 0
    var goodJudge: Bool = false
    var uName: String!
    var url: String!
    var goodArray: [String] = [""]
    
    var pageCount = 10
    var contentsArray = [DataSnapshot]()
    var color: [UIColor] = [.red, .yellow, .green, .blue, .purple, .systemIndigo, .cyan ]

    private var observers: (NSObjectProtocol)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImageView()
        activityIndicatorView.startAnimating()
        self.fetchContentsData()
        collectionView.delegate = self
        collectionView.dataSource = self
        goodArray = userDefaults.array(forKey: "good") as? [String] ?? [""]
        self.view.addSubview(activityIndicatorView)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.layoutCollection()
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
            if pageCount-indexPath.row-1 != 0 {
                let preitem = contentsArray[pageCount-indexPath.row-2]
                let precontent = preitem.value as! Dictionary<String, Any>
                let preurl = String(describing: precontent["videoURL"]!)
                player?.pause()
                player = nil
                print(URL(string: preurl)!)
            }
            let item = contentsArray[pageCount-indexPath.row-1]
            let content = item.value as! Dictionary<String, Any>

            url = String(describing: content["videoURL"]!)
            player = AVPlayer(url: URL(string: url)!)
            print(URL(string: url)!)
            uName = String(describing: content["author"]!)
            userName.text = uName
            if content["adopt"] != nil {
                adopt = content["adopt"] as! Bool
            }
            userId = content["uid"] as? String
            key = content["key"] as? String
            good = content["good"] as? Int ?? 0
        } else {
            let fileName = "Dog - 14869"
            let fileExtension = "mp4"
            let sampleUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
            player = AVPlayer(url: sampleUrl)
        }
        activityIndicatorView.stopAnimating()
        moviePlayerLayer.player = player
        self.playerLayer()
        cell.layer.insertSublayer(moviePlayerLayer, at: 0)
        //cell.backgroundColor = color[indexPath.row]
        player!.play()
        
        let ans = goodArray.filter{$0 == String(describing: key!)}
        if ans == [] {
            goodJudge = false
        } else {
            goodJudge = true
        }
        
        if goodJudge {
            if adopt {
                goodButton.setImage(UIImage(named: "yellow_heart.png"), for: .normal)
            } else {
                goodButton.setImage(UIImage(named: "pink_heart.png"), for: .normal)
            }
        } else {
            //いいねを外す
            goodButton.setImage(UIImage(named: "empty_heart.png"), for: .normal)
        }
        return cell
    }
    
    func playerLayer() {
        moviePlayerLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
        moviePlayerLayer.videoGravity = .resizeAspectFill
        if moviePlayerLayer.position != CGPoint(x: 0, y: 0) {
            player?.pause()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let storyboard: UIStoryboard = self.storyboard!
            let nextVC = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
            self.present(nextVC, animated: true, completion: nil)
        }
        //carouselView.scrollToFirstItem()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    func fetchContentsData() {
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            //child以降は新しい順に並べ替え
            ref.child("timeline").queryLimited(toLast: 100).queryOrdered(byChild: "postDate").observe(.value, with: { (snapShot) in
                
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
            print(snap!)
            self.contentsArray.removeAll()
            for item in snap.children {
                contentsArray.append(item as! DataSnapshot)
                print(item)
            }
            ref.child("timeline").keepSynced(true)
        }
        self.collectionView.reloadData()
    }
    
    func loadImageView(){
        let type = NVActivityIndicatorType.ballRotateChase
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.view.bounds.width/2-50, y: self.view.bounds.height/2-50, width: 100, height: 100), type: type, color: UIColor(hex: "2673B8"))
    }
    
    func convertTimeStamp(serverTimeStamp: CLong) -> String {
        let x = serverTimeStamp / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(x))
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date)
    }

    @IBAction func goodTapButton() {
        if goodJudge {
            //いいねを外す
            good -= 1
            goodJudge = false
            goodButton.setImage(UIImage(named: "empty_heart.png"), for: .normal)
            goodArray.remove(String(describing: key!))
        } else {
            good += 1
            goodJudge = true
            if adopt {
                goodButton.setImage(UIImage(named: "yellow_heart.png"), for: .normal)
            } else {
                goodButton.setImage(UIImage(named: "pink_heart.png"), for: .normal)
            }
            goodArray.append(String(describing: key!))
        }
        let post = ["good" : good] as [String : Any]
        ref.child("timeline").child(String(describing: key!)).updateChildValues(post)
        ref.child("user").child(String(describing: userId!)).child("video").child(String(describing: key!)).updateChildValues(post)
//        let uPost = ["goodVideo" : String(describing: key!)] as [String : Any]
//        ref.child("user").child(user!.uid).child("goodVideo").updateChildValues(uPost)
       userDefaults.set(goodArray, forKey: "good")
    }
    
    
    @IBAction func userProfileView() {
        let storyboard: UIStoryboard = self.storyboard!
        let nextVC = storyboard.instantiateViewController(withIdentifier: "OtherUserViewController") as! OtherUserViewController
        nextVC.userId = self.userId
        self.present(nextVC, animated: true, completion: nil)
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



