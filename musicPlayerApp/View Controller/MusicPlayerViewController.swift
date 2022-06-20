//
//  MusicPlayerViewController.swift
//  musicPlayerApp
//
//  Created by 林祐辰 on 2022/6/17.
//

import UIKit
import AVFoundation


class MusicPlayerViewController:UIViewController {
    
    var songPlaying :MusicModel!
    var sendSongs :[MusicModel]!
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playerProgress: UISlider!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var volumeSlider: VolumeSlider!
    @IBOutlet weak var passedTime: UILabel!
    @IBOutlet weak var remainedTime: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    

    let player = MusicPlayerController.shared.player
    var isPlaying = true
    var songLength:Float64?
    var songPlayingURL :URL {
        if songPlaying.previewUrl != nil{
            return songPlaying.getPreviewMusicURL!
        }else {
            return songPlaying.getFileURL()!
        }
    }
    var repeatType = RepeatTypes.NotRepeat
    var randomType = RandomTypes.NotRandom
    var pageSavedSong:[MusicModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = songPlaying.trackName
        artistLabel.text = songPlaying.artistName
        setPlayer(song: songPlaying)
        player.play()
        addPeriodicObserver()
        setMusicEndNotification()
    }
    
    func setPlayer(song:MusicModel){
        nameLabel.text = song.trackName
        artistLabel.text = song.artistName

        let playerItem = AVPlayerItem(url: songPlayingURL)
        player.replaceCurrentItem(with: playerItem)
        songLength = CMTimeGetSeconds(playerItem.asset.duration)
        volumeSlider.value = player.volume
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(songLength!)
        nameLabel.text = songPlaying.trackName
        artistLabel.text = songPlaying.artistName
        
        if let albumArtWorkLink = songPlaying.artworkUrl100,
           let artworkURL = URL(string: albumArtWorkLink){
            getAlbumImage(url: artworkURL) { (image) in
                
                DispatchQueue.main.async {
                    self.albumImageView.image  = image
                }
            }
        }else{
           self.albumImageView.image = UIImage(systemName: "music.note")
        }
    }
    
    
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        switch repeatType {
        case .NotRepeat:
            repeatType = .RepeatAll
            repeatButton.backgroundColor = .systemBlue
            repeatButton.tintColor = .white
        case .RepeatAll:
            repeatType = .RepeatOne
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        case .RepeatOne:
            repeatType = .NotRepeat
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
    }
    
    
    
    @IBAction func lastTrack(_ sender: Any) {
        if let currentSongIndex = sendSongs.firstIndex(of: songPlaying),
           currentSongIndex != 0 {
            songPlaying = sendSongs[currentSongIndex - 1]
            setPlayer(song: songPlaying)
        }else {
            songPlaying = sendSongs[sendSongs.count-1]
            setPlayer(song: songPlaying)
        }
        player.play()
    }
    
    
    
    @IBAction func playButton(_ sender: UIButton) {
        
        if !isPlaying {
            isPlaying = true
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            addPeriodicObserver()
        }else {
            isPlaying = false
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
        }
    }
    
    
    @IBAction func nextTrack(_ sender: Any) {
        
        if let currentSongIndex = sendSongs.firstIndex(of: songPlaying),
           currentSongIndex != sendSongs.count - 1 {
              songPlaying = sendSongs[currentSongIndex+1]
              setPlayer(song: songPlaying)
        }else{
            songPlaying = sendSongs[0]
            setPlayer(song: songPlaying)
        }
        player.play()
    }
    
    
    @IBAction func randomPressed(_ sender: UIButton) {
        
        switch randomType {
        case .NotRandom:
            randomType = .Random
            randomButton.backgroundColor = .systemBlue
            randomButton.tintColor = .white
            pageSavedSong = sendSongs
            sendSongs.shuffle()
        case .Random:
            randomType = .NotRandom
            randomButton.backgroundColor = .white
            randomButton.tintColor = .systemBlue
            sendSongs = pageSavedSong
        }
        
    }
    
    
    @IBAction func controllProgress(_ sender: UISlider) {
        let progressTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1)
        player.seek(to: progressTime)
    }
    
    
    @IBAction func controllVolume(_ sender: VolumeSlider) {
        sender.minimumValue = 0
        sender.maximumValue = 1
        player.volume = sender.value
    }
    
    
    func setMusicEndNotification(){
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            
            switch self.repeatType {
            case .NotRepeat:
                if let index = self.sendSongs.firstIndex(of: self.songPlaying) {
                if index == self.sendSongs.count - 1 {
                    self.nextTrack(self)
                    self.player.pause()
                    self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    self.isPlaying = false
                }else{
                     self.nextTrack(self)
                  }
                }
            case .RepeatOne:
                self.player.seek(to: .zero)
                self.player.play()
            case .RepeatAll:
                self.nextTrack(self)
            }
        }
        
    }
        
    
    func formatedTime(time: Float) -> String{
        let time = Int(time)
        let min = Int (time / 60)
        let sec = Int (time % 60)
        return String(format: "%d:%02d", min, sec)
    }
    
    
    
    func addPeriodicObserver(){
        let timeInterval = CMTime(value: 1, timescale: 1)
        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { (CMTime) in
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            self.passedTime.text = self.formatedTime(time: Float(currentTime))
            self.remainedTime.text =
            " -\( self.formatedTime(time: Float(Double(self.progressSlider.maximumValue) - currentTime)))"
            self.progressSlider.value = Float(currentTime)
    }
}
    
    func getAlbumImage(url:URL,completionHandler:@escaping (UIImage?)->()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data ,
               let readyShowImage = UIImage(data: data){
                  completionHandler(readyShowImage)
            }else{
                  completionHandler(nil)
            }
            
        }.resume()
        
    }
}


