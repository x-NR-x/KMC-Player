//
//  ViewController.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/8/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit
import PlayKit
import KalturaClient

class MediaPlayerViewController: UIViewController {
    
    var player: Player?
    var mediaEntry: MediaEntry?
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var topVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var topVisualEffectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var bottomVisualEffectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var tracksVisualEffectView: UIVisualEffectView!
    let topBottomVisualEffectViewHeight: Float = 50.0
    
    @IBOutlet weak var animatedPlayButton: UIAnimatedPlayButton!
    
    @IBOutlet weak var mediaProgressSlider: UISlider!
    var mediaProgressTimer: Timer?
    
    var audioTracks: [Track]?
    var textTracks: [Track]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(playerViewTapped))
        self.playerView.addGestureRecognizer(gesture)
        
        self.setupPlayer()
        self.showPlayerControllers(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private Methods
    
    private func setupPlayer() {
        
        guard let mediaEntry = self.mediaEntry else {
            return
        }
        
        guard let stringURL = mediaEntry.dataUrl else {
            return
        }
        
        let stringURLArray = stringURL.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
        
        guard stringURLArray.count >= 2 else {
            return
        }
        
        let serverURL = "\(stringURLArray[0])//\(stringURLArray[1])"
        let partnerId = UserManager.shared.partnerIdValue
        let ks = UserManager.shared.ksValue
        
        let sessionProvider = SimpleOVPSessionProvider(serverURL:serverURL, partnerId:Int64(partnerId), ks:ks)
        let mediaProvider: OVPMediaProvider = OVPMediaProvider(sessionProvider)
        mediaProvider.entryId = mediaEntry.id
        mediaProvider.loadMedia { (pkMediaEntry, error) in
            if let mediaEntry = pkMediaEntry, error == nil {
                // Create media config
                let mediaConfig = MediaConfig(mediaEntry: mediaEntry, startTime: 0.0)
                self.mediaProgressSlider.value = 0.0
                
                do {
                    self.player = try PlayKitManager.shared.loadPlayer(pluginConfig: nil)
                    self.registerPlayerEvents()
                    self.player!.prepare(mediaConfig)
                    self.player?.view = self.playerView
                } catch let e {
                    print("Error loading the player: \(e)")
                }
            }
        }
    }
    
    @objc private func mediaProgressTimerFired() {
        guard let player = self.player else {
            print("player is not set")
            return
        }
        self.mediaProgressSlider.value = Float(player.currentTime / player.duration)
    }
    
    private func showPlayerControllers(_ show: Bool) {
        let constantValue: Float = show ? topBottomVisualEffectViewHeight : 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.topVisualEffectViewHeightConstraint.constant = CGFloat(constantValue)
            self.bottomVisualEffectViewHeightConstraint.constant = CGFloat(constantValue)
            self.middleVisualEffectView.alpha = show ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func playerViewTapped() {
        let show = !(self.topVisualEffectViewHeightConstraint.constant == CGFloat(topBottomVisualEffectViewHeight))
        self.showPlayerControllers(show)
    }
    
    // MARK: - Events Registration
    
    func registerPlayerEvents() {
        self.registerPlaybackEvents()
        self.handleTracks()
    }
    
    func registerPlaybackEvents() {
        guard let player = self.player else {
            print("player is not set")
            return
        }
        
        player.addObserver(self, events: [PlayerEvent.stopped, PlayerEvent.ended, PlayerEvent.play, PlayerEvent.pause]) { event in
            if type(of: event) == PlayerEvent.stopped {
                // handle playing event
                print("Stopped Event")
            } else if type(of: event) == PlayerEvent.ended {
                // handle playing event
                print("Ended Event")
            } else if type(of: event) == PlayerEvent.play {
                // handle playing event
                print("Play Event")
            } else if type(of: event) == PlayerEvent.pause {
                // handle playing event
                print("Pause Event")
            }
        }
    }
    
    func handleTracks() {
        guard let player = self.player else {
            print("player is not set")
            return
        }
        
        player.addObserver(self, events: [PlayerEvent.tracksAvailable]) { [weak self] event in
            if type(of: event) == PlayerEvent.tracksAvailable {
                guard let tracks = event.tracks else {
                    print("No Tracks Available")
                    return
                }
                
                self?.audioTracks = tracks.audioTracks
                self?.textTracks = tracks.textTracks
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func trackTouched(_ sender: Any) {
        
        self.showPlayerControllers(false)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.tracksVisualEffectView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func closeTracksTouched(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.tracksVisualEffectView.alpha = 0.0
        }, completion: {(succeded) in
            self.showPlayerControllers(true)
        })
    }
    
    @IBAction func speechTouched(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Speech", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        guard let tracks = self.audioTracks else {
            return
        }
        
        for track in tracks {
            alertController.addAction(UIAlertAction(title: track.title, style: UIAlertActionStyle.default, handler: { (alertAction) in
                self.player?.selectTrack(trackId: track.id)
            }))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func subtitleTouched(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Subtitle", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        guard let tracks = self.textTracks else {
            return
        }
        
        for track in tracks {
            alertController.addAction(UIAlertAction(title: track.title, style: UIAlertActionStyle.default, handler: { (alertAction) in
                self.player?.selectTrack(trackId: track.id)
            }))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeTouched(_ sender: Any) {
        self.player?.destroy()
        performSegue(withIdentifier: "unwindSegueToMediaCollection", sender: self)
    }
    
    @IBAction func mediaProgressSliderValueChanged(_ sender: UISlider) {
        guard let player = self.player else {
            return
        }
        
        let currentValue = Double(sender.value)
        let seekTo = currentValue * player.duration
        player.seek(to: seekTo)
    }
    
    @IBAction func animatedPlayButtonTouched(_ sender: Any) {
        guard let player = self.player else {
            print("player is not set")
            return
        }
        
        if !(player.isPlaying) {
            self.mediaProgressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(mediaProgressTimerFired), userInfo: nil, repeats: true)
            
            player.play()
            self.animatedPlayButton.transformToState(UIAnimatedPlayButtonState.Pause)
            self.showPlayerControllers(false)
        } else {
            self.mediaProgressTimer?.invalidate()
            self.mediaProgressTimer = nil
            player.pause()
            self.animatedPlayButton.transformToState(UIAnimatedPlayButtonState.Play)
        }
    }
}
