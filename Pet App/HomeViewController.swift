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
    var pageCount = 7
    var color: [UIColor] = [.red, .yellow, .green, .blue, .purple, .systemIndigo, .cyan ]
    
    var playerController = AVPlayerViewController()
    var player = AVPlayer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.layoutCollection()
        self.moviePlayer()
    }
    
    func layoutCollection() {
        let layout = AnimatedCollectionViewLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        layout.animator = RotateInOutAttributesAnimator()
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
        cell.backgroundColor = color[fixedIndex]
        return cell
    }
    
    func moviePlayer() {
        /// Audio sessionを動画再生向けのものに設定し、activeにします
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.playback, mode: .moviePlayback)
                        
                } catch {
                    print("Setting category to AVAudioSessionCategoryPlayback failed.")
                }

                do {
                    try audioSession.setActive(true)
                    print("Audio session set active !!")
                } catch {
                    
                }
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



