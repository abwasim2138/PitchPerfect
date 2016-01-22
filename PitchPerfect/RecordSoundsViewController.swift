//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Abdul-Wasai Wasim on 1/21/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController,AVAudioRecorderDelegate {

    
    //TODO: - PAUSE/RESTART, REVERB/ECHO
    
    //MARK: - IBOutlets
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopLabel: UIButton!
    
    //MARK: - Properties
    private var audioRecorder:AVAudioRecorder?
    
    private var recordedAudio:RecordedAudio?
    private let session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        recordingLabel.text = "Tap To Record"
        stopLabel.hidden = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func record(sender: UIButton) {
        recordingLabel.text = "Recording..."
        stopLabel.hidden = false
        recordButton.enabled = false
        
        //RECORD THE USER'S VOICE HERE 
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recording.wav"
        let pathArray = [dirPath,recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        session.requestRecordPermission { (success) -> Void in
            if success {
                do {
                try self.session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
                    do {
                    try self.session.setActive(true)
                        //PREPARE THE RECORDER NEXT
                        let settings = [AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Max.rawValue))]
                        if let filePath = filePath {
                            do {
                                self.audioRecorder = try AVAudioRecorder(URL: filePath, settings: settings)
                                self.audioRecorder!.delegate = self
                                self.audioRecorder!.meteringEnabled = true
                                self.audioRecorder!.prepareToRecord()
                                self.audioRecorder!.record()
                            }catch let error as NSError{
                                print("error in recording audio \(error.localizedDescription)")
                            }
                        }
                    }catch{
                        print("error in settingActive")
                    }
                }catch{
                     print("error in settingSession")
                }
            }
        }
        
    }
    
    @IBAction func stop(sender: UIButton) {
        recordingLabel.text = "Tap To Record"
        stopLabel.hidden = true
        recordButton.enabled = true
        
        audioRecorder!.stop()
        do {
        try session.setActive(false)
        }catch{
           print("error in stopping audio")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
        recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
        performSegueWithIdentifier("showSecondScreen", sender: recordedAudio)
        }else{
            recordingLabel.text = "Recorded!"
            stopLabel.hidden = true
            recordButton.enabled = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSecondScreen"
        {
            if let playSoundsVC = segue.destinationViewController as? PlaySoundsViewController {
            let data = sender as! RecordedAudio
            playSoundsVC.receivedData = data
            }
        }
    }

}

