//
//  SoundTestViewController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/09.
//

import UIKit
import AVFoundation
import SnapKit

class SoundTestViewController: UIViewController {

    let btn = UIButton().then { $0.setTitle("btn", for: .normal)
        $0.setTitleColor(.magenta, for: .normal)
        $0.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
    }
    
    let upButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.addTarget(self, action: #selector(countUp), for: .touchUpInside)
    }
    
    let downButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.addTarget(self, action: #selector(countDown), for: .touchUpInside)
    }
    
    let soundCodeLabel = UILabel().then {
        $0.textColor = .magenta
        $0.textAlignment = .center
        $0.text = "1000"
    }
    
    @objc func btnTapped(_ sender: UIButton) {
//        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    @objc func countUp(_ sender: UIButton) {
        soundCode += 1
        systemSoundID = soundCode
        updateLabel()
    }
    
    @objc func countDown(_ sender: UIButton) {
        soundCode -= 1
        systemSoundID = soundCode
       updateLabel()
    }
    
    private func updateLabel() {
        soundCodeLabel.text = String(soundCode)
    }
    
    var soundCode: UInt32 = 1000
    
    var player: AVAudioPlayer?
    
    var systemSoundID: SystemSoundID = 1016
    
    override func viewDidLoad() {
        super.viewDidLoad()
        systemSoundID = soundCode
        let stackView = UIStackView(arrangedSubviews: [downButton, btn, upButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
        }
        
        view.addSubview(soundCodeLabel)
        soundCodeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
//        soundCodeLabel.
        
        
        

        
        // Do any additional setup after loading the view.
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


//import AVFoundation
//
//var player: AVAudioPlayer?
//
//func playSound() {
//    guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else { return }
//
//    do {
//        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//        try AVAudioSession.sharedInstance().setActive(true)
//
//        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//        /* iOS 10 and earlier require the following line:
//        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//
//        guard let player = player else { return }
//
//        player.play()
//
//    } catch let error {
//        print(error.localizedDescription)
//    }
//}
