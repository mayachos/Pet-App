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

class HomeViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource {
    
    let isInfinity = true //無限スクロール
    @IBOutlet var collectionView: UICollectionView!
    var player: AVPlayer?
    
    var pageCount = 7
    var color: [UIColor] = [.red, .yellow, .green, .blue, .purple, .systemIndigo, .cyan ]
    
    //var playerController = AVPlayerLayer()
    //var player = AVPlayer()
    private var observers: (NSObjectProtocol)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.layoutCollection()
        let fileName = "Dog - 14869"
        let fileExtension = "mp4"
        let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
        player = AVPlayer(url: url)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



