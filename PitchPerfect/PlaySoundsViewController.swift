//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Abdul-Wasai Wasim on 1/21/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseResumeButton: UIButton!
    @IBOutlet var stopPauseStackView: UIStackView!
    
    private var audioPlayer = AVAudioPlayer()
    private var audioEngine:AVAudioEngine!
    private var audioPlayerNode:AVAudioPlayerNode!
    private var audioFile: AVAudioFile!
    private var isPlaying = false
    private var audioEngineOn = false
    var receivedData:RecordedAudio?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        audioEngine = AVAudioEngine()
        do {
        audioFile = try AVAudioFile(forReading: receivedData!.filePathURL!)
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        stopPauseStackView.alpha = 0.0
            do {
                try
                audioPlayer = AVAudioPlayer(contentsOfURL: receivedData!.filePathURL!)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.enableRate = true
            }catch {
                print("ERROR IN PLAYING FILE")
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func playAudio (rate: Float) {
        resetAudio()
        audioPlayer.rate = rate
        audioPlayer.play()
        stopPauseStackView.alpha = 1.0
        isPlaying = true
    }
    
    func changePitch(p: Float,reverb: Bool,echo: Bool) {
        resetAudio()
        stopPauseStackView.alpha = 1.0
        isPlaying = true
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var node = AVAudioUnit()
        //CHIPMUNK & VADER
        if (p != 0) {
        let pitch = AVAudioUnitTimePitch()
        pitch.pitch = p
        node = pitch
        }else if reverb == true{
        //REVERB 
            
//        CITE: http://stackoverflow.com/questions/29619087/what-does-detachnode-do-in-avaudioengine-class-in-swift 
            //HELPED IN UNDERSTANDING WHAT NODE WAS NEEDED FOR ECHO AND REVERB EFFECTS
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Plate)
        reverb.wetDryMix = 55
        node = reverb
        }else if echo == true {
        //ECHO 
        let echo = AVAudioUnitDelay()
        echo.delayTime = 0.3
        node = echo
        }
        
        audioEngine.attachNode(node)
        audioEngine.connect(audioPlayerNode, to: node, format: nil)
        audioEngine.connect(node, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
            audioEngineOn = true
            audioPlayerNode.play()
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func resetAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0.0
        audioEngineOn = false
        pauseResumeButton.setImage(UIImage(named: "pause"), forState: .Normal)
    }
    
    @IBAction func slowAudio(sender: UIButton) {
        playAudio(0.5)
    }
  
    @IBAction func speedUpAudio(sender: UIButton) {
        playAudio(2.0)
    }
    
    @IBAction func chipMunk(sender: UIButton) {
        changePitch(1000,reverb: false,echo: false)
        
    }
    
    @IBAction func dark(sender: UIButton) {
        changePitch(-1000,reverb: false,echo: false)
    }
    
    @IBAction func reverb(sender: UIButton) {
        changePitch(0, reverb: true, echo: false)
    }
    
    @IBAction func echo(sender: UIButton) {
        changePitch(0, reverb: false, echo: true)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        resetAudio()
        audioPlayer.currentTime = 0.0
        stopPauseStackView.alpha = 0.0
    }
    
    @IBAction func pauseResumeAudio(sender: UIButton) {
        if (isPlaying) {
            pauseResumeButton.setImage(UIImage(named: "resume"), forState: .Normal)
            if (audioEngineOn) {
            audioPlayerNode.pause()
            }else{
            audioPlayer.stop()
            }
            isPlaying = false
        }else{
            pauseResumeButton.setImage(UIImage(named: "pause"), forState: .Normal)
            if (audioEngineOn){
            audioPlayerNode.play()
            }else{
            audioPlayer.play()
            }
            isPlaying = true
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        resetAudio()
        stopPauseStackView.alpha = 0.0
    }

}
