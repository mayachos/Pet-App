//
//  GoodViewController.swift
//  Pet App
//
//  Created by maya on 2020/10/10.
//

import UIKit
import AVKit
import Firebase
import NVActivityIndicatorView

class GoodViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let user = Auth.auth().currentUser
    let ref = Database.database().reference()
    var snap: DataSnapshot!
    var activityIndicatorView: NVActivityIndicatorView!
    let userDefaults = UserDefaults.standard
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segment: UISegmentedControl!
    
    var setUrl: String!
    var goodArray: [String]!
    var content: Dictionary<String, Any>!
    let semaphore = DispatchSemaphore(value: 0)
    
    var contentsGoodArray = [DataSnapshot]()
    var contentsUploadArray = [DataSnapshot]()
    var contentsAdoptArray = [DataSnapshot]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        goodArray = userDefaults.array(forKey: "good") as? [String] ?? [""]
        collectionView.delegate = self
        collectionView.dataSource = self
        segment.selectedSegmentIndex = 0
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segment.selectedSegmentIndex {
        case 0:
            return contentsGoodArray.count
        case 1:
            return contentsAdoptArray.count
        case 2:
            return contentsUploadArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        switch segment.selectedSegmentIndex {
        case 0:
            let item = contentsGoodArray[indexPath.row]
            content = item.value as? Dictionary<String, Any> ?? ["videoURL":""]
            setUrl = String(describing: content["videoURL"])
            let url = URL(string: setUrl)
            if url != nil {
                cell.videoImage.image = self.thumnailImageForFileUrl(fileUrl: url!)
            }
        case 1:
            let item = contentsAdoptArray[indexPath.row]
            content = item.value as? Dictionary<String, Any> ?? ["videoURL":""]
            setUrl = String(describing: content["videoURL"])
            let url = URL(string: setUrl)
            if url != nil {
                cell.videoImage.image = self.thumnailImageForFileUrl(fileUrl: url!)
            }
        case 2:
            let item = contentsGoodArray[indexPath.row]
            content = item.value as? Dictionary<String, Any> ?? ["videoURL":""]
            setUrl = String(describing: content["videoURL"])
            let url = URL(string: setUrl)
            if url != nil {
                cell.videoImage.image = self.thumnailImageForFileUrl(fileUrl: url!)
            }
        default: break
        }

        return cell
    }
    
    func loadData() {
        DispatchQueue.global(qos: .userInitiated).sync {
            
            for i in 1..<self.goodArray.count {
                self.goodContentsData(key: self.goodArray[i])
            }
            self.apendAdoptArray()
            self.userContentsData()
        }
    }
    
    func userContentsData() {
            //child以降は新しい順に並べ替え
        ref.child("user").child(user!.uid).child("video").observe(.value, with: { (snapShot) in
            
            dump(snapShot)
            if snapShot.children.allObjects is [DataSnapshot] {
                print("snapShots.children...\(snapShot.childrenCount)") //いくつのデータがあるかプリント
                
                print("snapShot...\(snapShot)") //読み込んだデータをプリント
                
                self.snap = snapShot
            }
            self.reload(select: 2)
        })
    }
    
    func goodContentsData(key: String) {
            //child以降は新しい順に並べ替え
            ref.child("timeline").child(key).observe(.value, with: { (snapShot) in
                
                dump(snapShot)
                if snapShot.children.allObjects is [DataSnapshot] {
                print("snapShots.children...\(snapShot.childrenCount)") //いくつのデータがあるかプリント
                
                print("snapShot...\(snapShot)") //読み込んだデータをプリント
                
                self.snap = snapShot
                }
                self.reload(select: 1)
            })
    }
    
    func reload(select: Int) {
        if snap != nil {
            if select == 1 {
                print(snap!)
                for item in snap.children {
                    contentsGoodArray.append(item as! DataSnapshot)
                    print(item)
                }
                ref.child("timeline").keepSynced(true)
            } else if select == 2 {
                print(snap!)
                for item in snap.children {
                    contentsUploadArray.append(item as! DataSnapshot)
                    print(item)
                }
                ref.child("user").child(user!.uid).child("video").keepSynced(true)
            }
        }
    }
    
    func apendAdoptArray() {
        for i in 0..<contentsGoodArray.count {
            let item = contentsGoodArray[i]
            content = item.value as? Dictionary<String, Any>
            if (content["adopt"] != nil) == true {
                contentsAdoptArray.append(contentsGoodArray[i])
            }
        }
    }

    
    func thumnailImageForFileUrl(fileUrl: URL) -> UIImage? {
            let asset = AVAsset(url: fileUrl)

            let imageGenerator = AVAssetImageGenerator(asset: asset)

            do {
                let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 30), actualTime: nil)
                print("サムネイルの切り取り成功！")
                return UIImage(cgImage: thumnailCGImage, scale: 0, orientation: .right)
            }catch let err{
                print("エラー\(err)")
            }
            return nil
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
