//
//  RecordViewController.swift
//  Pet App
//
//  Created by maya on 2020/09/27.
//

import UIKit
import AVFoundation
import Photos
import SnapKit

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    let fileOutput = AVCaptureMovieFileOutput()
    
    var recordButton: UIButton!
    var isRecording = false
    var videoTimer: Timer?
    var loadTimer: Timer?
    var sendUrl: URL!
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
    }
    
    func setUp() {
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do {
            if videoDevice == nil || audioDevice == nil {
                throw NSError(domain: "device error", code: -1, userInfo: nil)
            }
            let captureSession = AVCaptureSession()
            //video inputをcapture sessionに追加
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)
            //audio inputをcapture sessionに追加
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)
            
            //録画時間の制限
            fileOutput.maxRecordedDuration = CMTimeMake(value: 30, timescale: 1)
            
            //出力をsessionに追加
            captureSession.addOutput(fileOutput)
            
            //プレビュー
            let videoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.frame = CGRect(x: 0, y: (self.view.bounds.height - self.view.bounds.width) / 2, width: self.view.bounds.width, height: self.view.bounds.width)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(videoLayer)
            
            captureSession.startRunning()
            
            setUpButton()
        } catch {
            //エラー処理
        }
    }
    func setUpButton() {
        recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        recordButton.backgroundColor = UIColor.gray
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("録画開始", for: UIControl.State.normal)
        recordButton.layer.cornerRadius = 50.0
        recordButton.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-200)
        recordButton.addTarget(self, action: #selector(RecordViewController.onClickRecordButton(sender:)), for: .touchUpInside)
        
        self.view.addSubview(recordButton)
    }
    @objc func onClickRecordButton(sender: UIButton) {
        if !isRecording {
            //録画開始
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath: String? = "\(documentsDirectory)/temp.mp4"
            let fileURL: NSURL = NSURL(fileURLWithPath: filePath!)
            fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
            
            isRecording = true
            recordButton.backgroundColor = UIColor.red
            recordButton.setTitle("録画中", for: .normal)
            self.videoTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.stopVideo(_:)), userInfo: nil, repeats: false)
        } else {
            stopVideo(sender)
        }
        
    }
    
    @objc func stopVideo(_ sender: Any) {
        //録画終了
        fileOutput.stopRecording()
        
        isRecording = false
        recordButton.backgroundColor = UIColor.gray
        recordButton.setTitle("録画開始", for: .normal)
        
        videoTimer?.invalidate()
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let croppedMovieFileURL: URL = outputFileURL
        
            saveMovie(outputFileURL: outputFileURL, croppedMovieFileURL: croppedMovieFileURL)
        
            toUploadView(self)
    }
    func saveMovie(outputFileURL: URL, croppedMovieFileURL: URL) {
        //録画した動画を正方形にクロッピング
        MovieCropper.exportSquareMovie(sourceURL: outputFileURL, destinationURL: croppedMovieFileURL, fileType: .mov, completion: {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                //ライブラリへ保存
                PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }) {
                    completed, error in
                    if completed {
                        print("Video is saved!")
                    }
                }
            }
        })
        sendUrl = outputFileURL
    }
    
    func toUploadView(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextVC = storyboard.instantiateViewController(identifier: "upload") as! UploadViewController
        print(sendUrl as Any)
        nextVC.setUrl = sendUrl
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
