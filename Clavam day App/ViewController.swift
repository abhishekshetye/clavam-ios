//
//  ViewController.swift
//  Clavam day App
//
//  Created by abhishek on 3/12/17.
//  Copyright © 2017 abhishek. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseDatabase


class ViewController: UIViewController {

    struct Video {
        var url: String?
        var name: String?
    }
    
    
    @IBOutlet weak var firstButton: UIButton!
    
    @IBOutlet weak var secondButton: UIButton!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    let url = "https://firebasestorage.googleapis.com/v0/b/clavam-day.appspot.com/o/game.mp4?alt=media&token=ef1460f9-564b-4c23-9464-ee95e8095007"
    
    let downloadUrl = "https://firebasestorage.googleapis.com/v0/b/clavam-day.appspot.com/o/B%20R%20Ambedkar.mp4?alt=media&token=c203cf6e-9133-4ca4-aecf-8fcbea5add85";
    
    override func viewDidAppear(_ animated: Bool) {
        print("Appeared")
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "FN") == nil {
            firstButton.titleLabel?.text = "No video"
        } else {
            firstButton.setTitle(preferences.string(forKey: "FN"), for: UIControlState.normal)
        }
        
        if preferences.object(forKey: "SN") == nil {
            secondButton.titleLabel?.text = "No video"
        } else {
            secondButton.setTitle(preferences.string(forKey: "SN"), for: UIControlState.normal)
        }

        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    var currentLevel: Int = 1
    var ref: FIRDatabaseReference!
    
    var videos = [Video]()
    
    //shared prefs keys
    let FP = "firstpath" //urls
    let SP = "secondPath"
    let FN = "firstNameadfa"
    let SN = "secondNamehfga"
    var size: Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let preferences = UserDefaults.standard
        print("loaded")
        firstButton.titleLabel?.textAlignment = NSTextAlignment.center
        secondButton.titleLabel?.textAlignment = NSTextAlignment.center
        downloadButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        if preferences.object(forKey: "SIZE") == nil {
            size = 0
        } else {
            size = preferences.integer(forKey: "SIZE")
        }
//        if preferences.object(forKey: "FN") == nil {
//            firstButton.titleLabel?.text = "No video"
//        } else {
//           firstButton.titleLabel?.text  = preferences.string(forKey: "FN")
//        }
//        
//        if preferences.object(forKey: "SN") == nil {
//            secondButton.titleLabel?.text = "No video"
//        } else {
//            secondButton.titleLabel?.text  = preferences.string(forKey: "SN")
//        }
        
        if(size <= 1){
            secondButton.isHidden = true
        }
        
        downloadButton.isHidden = true;
    
    
        
        ref = FIRDatabase.database().reference().child("videos")
        let refHandle = ref.observe(FIRDataEventType.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let dict = rest.value as? [String: AnyObject]
                
                print(dict?["name"] as! String )
                
                self.videos.append(Video(url: dict?["url"] as? String, name: dict?["name"] as? String))
            }
            print("Something changed")
            
            if(self.videos.count > self.size){
                self.downloadButton.isHidden = false
            }
            
            self.firstButton.setTitle(self.videos[self.videos.count-1].name!, for: UIControlState.normal)
            print("Name changed to " + self.videos[self.videos.count-1].name!)
            if(self.videos.count<2){
                self.secondButton.isHidden = true;
            }else{
                self.secondButton.isHidden = false
                self.secondButton.setTitle(self.videos[self.videos.count-2].name!, for: UIControlState.normal)
                preferences.set(self.videos[self.videos.count-2].name, forKey:"SN" )
                preferences.set(self.videos[self.videos.count-2].url, forKey:"SP" )
            }
            
            preferences.set(self.videos[self.videos.count-1].name, forKey:"FN" )
            preferences.set(self.videos[self.videos.count-1].url, forKey:"FP" )
            preferences.set(self.videos.count, forKey:"SIZE" )
            
                    //  Save to disk
            let didSave = preferences.synchronize()
            
            if !didSave {
                //  Couldn't save (I've never seen this happen in real world testing)
                print("Couldnt save..")
            }
        
            // ...
        })
        
        self.view.layoutIfNeeded()
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playit(_ sender: Any) { //second one
        
        let alert = UIAlertController(title: "Downloading", message: "The video is downloading.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let preferences = UserDefaults.standard
        var url: String?
        if preferences.object(forKey: "SP") == nil {
            url = ""
            return;
        } else {
            url = preferences.string(forKey: "SP")
        }
        
        let myUrl = URL(string: url!)
        let filename = myUrl?.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let downloadDir = paths[0]
        let videoDataPath = downloadDir + "/" + filename!
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: videoDataPath) {
            print("FILE AVAILABLE")
            play(url: myUrl!)
        } else {
            print("FILE NOT AVAILABLE")
            //DOWNLOAD IT
            let downloadsPath = try! FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            let fileURL = downloadsPath?.appendingPathComponent((myUrl?.lastPathComponent)!)
            print(myUrl?.lastPathComponent ?? "default" )
            
            if let URL = NSURL(string: url!) {
                Downloader.load(url: URL as URL, to: fileURL!, completion: {
                    //code here
                })
            }
            return
        }
        
    }
    
    @IBAction func redDownloadButtonClick(_ sender: Any) { //first one
        
        let alert = UIAlertController(title: "Downloading", message: "The video is downloading.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let preferences = UserDefaults.standard
        var url: String?
        if preferences.object(forKey: "FP") == nil {
            url = ""
            return;
        } else {
            url = preferences.string(forKey: "FP")
        }
        
        let myUrl = URL(string: url!)
        let filename = myUrl?.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let downloadDir = paths[0]
        let videoDataPath = downloadDir + "/" + filename!
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: videoDataPath) {
            print("FILE AVAILABLE")
            play(url: myUrl!)
        } else {
            print("FILE NOT AVAILABLE")
            //DOWNLOAD IT
            let downloadsPath = try! FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            let fileURL = downloadsPath?.appendingPathComponent((myUrl?.lastPathComponent)!)
            print(myUrl?.lastPathComponent ?? "default" )
            
            if let URL = NSURL(string: url!) {
                Downloader.load(url: URL as URL, to: fileURL!, completion: {
                    //code here
                })
            }
            return
        }
    }
    
    
    
    @IBAction func downloadClick(_ sender: Any) { //first one
        
        let alert = UIAlertController(title: "Downloading", message: "The video is downloading.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let preferences = UserDefaults.standard
        var url: String?
        if preferences.object(forKey: "FP") == nil {
            url = ""
            return;
        } else {
            url = preferences.string(forKey: "FP")
        }
        
        let myUrl = URL(string: url!)
        let filename = myUrl?.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let downloadDir = paths[0]
        let videoDataPath = downloadDir + "/" + filename!
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: videoDataPath) {
            print("FILE AVAILABLE")
            play(url: myUrl!)
        } else {
            print("FILE NOT AVAILABLE")
            //DOWNLOAD IT
            
            let downloadsPath = try! FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            let fileURL = downloadsPath?.appendingPathComponent((myUrl?.lastPathComponent)!)
            print(myUrl?.lastPathComponent ?? "default" )
            
            if let URL = NSURL(string: url!) {
                Downloader.load(url: URL as URL, to: fileURL!, completion: {
                    //code here
                })
            }
            return
        }
    }
    
    var videoData = ""
    
    func play (url: URL){
        
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let downloadDir = paths[0]
        
        let filename = url.lastPathComponent
        
        let videoDataPath = downloadDir + "/" + videoData + filename
        
        let filePathURL = URL(fileURLWithPath: videoDataPath)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: videoDataPath) {
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
            return
        }
        
        let player = AVPlayer(url: filePathURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
            
        }
    }
    
    class Downloader {
        class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = try! URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
                    }
                    
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                        
                        completion()
                    } catch (let writeError) {
                        print("error writing file \(localUrl) : \(writeError)")
                    }
                    
                } else {
                    print("Failure: %@", error?.localizedDescription);
                    
                }
            }
            task.resume()
        }
    }


}
