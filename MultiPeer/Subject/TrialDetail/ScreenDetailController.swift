//
//  TrialDetailController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation


//
//  TrialDetailController.swift
//
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import UIKit
import SnapKit
import Then
import CoreData

// show only latest Trial Infos
// 어떤 Screen 이 주어진 상태에서, 그 때의 최신 값을 가져오기.
// This one Need Header !

class ScreenDetailController: UIViewController {
    
    var screen: Screen {
        didSet {
            DispatchQueue.main.async {
                self.trialCollectionView.reloadData()
            }
        }
    }
    
//    var trialCores: [TrialCore] = []
    var trialCores: [[TrialCore]] = [[]]
//    var trialCoresToShow: [[(TrialCore, TrialCore?)]] = [[]]
    // tuple form due to following clearing Test ;;
    var trialCoresToShow: ([[TrialCore]], [[TrialCore]]) = ([[]], [[]])
    
    var trialPainCores: [[TrialCore]] = [[]]
    
    let reuseId = "TrialCellId"
    let headerReuseId = "HeaderId"
    
    private let trialCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let continueBtn = UIButton().then {
        $0.setTitle("Continue", for: .normal)
        $0.setTitleColor(.cyan, for: .normal)
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 5
    }
    
    private func registerCollectionView(customCollectionView: UICollectionView) {
        customCollectionView.register(TrialCell.self, forCellWithReuseIdentifier: reuseId)
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
    
        customCollectionView.register(
            TrialHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerReuseId)
    }
    
    init(screen: Screen) {
        self.screen = screen
        
        print("passed screenId: \(screen.id)")
        print("passed screen's core : \(screen.trialCores.count)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
//        self.trialCores = screen.trialCores.sorted {
//            if $0.tag != $1.tag {
//                return $0.tag < $1.tag
//            } else {
//                return $0.direction.count < $1.direction.count
//            }
//        }
        
//        updateTrialCores(screen: screen)
        updateTrialCores()
        registerCollectionView(customCollectionView: trialCollectionView)
        setupLayout()
        
        continueBtn.addTarget(self, action: #selector(continueBtnTapped), for: .touchUpInside)
    }
    
    @objc func continueBtnTapped(_ sender: UIButton) {
        
        let screenInfo: [AnyHashable: Any] = [
            "screen": screen
        ]
        
        NotificationCenter.default.post(name: .screenSettingKey, object: nil, userInfo: screenInfo)
    }
    
//    private func updateTrialCores(screen: Screen? = nil) {
    private func updateTrialCores() {
        print("screen is nil? \(screen == nil)")
        print("updateTrialCores Called ")
        
        self.trialCores = [[]] // initialize
        
        // screen 유효하면 self.screen 에 넣고 없으면 만들어서 넣기.
        
//            userDefaultSetup.upperIndex += 1
//            self.screen = newScreen
        
        //        let sortedCores = self.screen!.trialCores.sorted {
        // 먼저 운동 순서대로, 같은 운동의 경우 좌우 순서로 넣기.
        
        let sortedCores = screen.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
        
        print("---------- sorted Cores: ----------")
//        sortedCores
        // sortedCores: [Deep Squat, Deep Squat Var, Hurdle Step Left, Hurdle Step Right, ... ]
        
        // trialCores 에 잘 분류해서 넣기 위해 선언한 이전 sortedCore 값
        var prev = sortedCores.first!
        
        // TODO: 이건 또 뭐야 ??
        self.trialCores.append([])
        
        for eachCore in sortedCores {
            if prev.title == eachCore.title {
                self.trialCores[self.trialCores.count - 1].append(eachCore)
            } else {
                self.trialCores.append([eachCore])
            }
            prev = eachCore
        }
        print("--------- sortedCores: ---------")
        for eachCore in sortedCores {
            print("title: \(eachCore.title), direction: \(eachCore.direction)")
        }
        self.trialCores.removeFirst()
        
        // initialize
//        trialCoresToShow = [[]]
        trialCoresToShow = ([[]], [[]])
        
        print("----------------- trialCores: -----------------")
        for eachCoreArray in trialCores {
            for eachCore in eachCoreArray {
                print("title: \(eachCore.title), direction: \(eachCore.direction)")
            }
        }
        
        for (index, eachCoreArr) in trialCores.enumerated() {
            // hanmok, 여기 잘못됨. 애초에, 받는 애가.. 잘못됐음.. ??
            // 음.. deep squat 의 경우, Deep Squat 과 Variation 을 비교해서,
            // Variation 의 trialNo 가 Deep Squat 과 '같을 시' Variation 의 점수 반영해야함.
            
            // basic moves
            if MovementImgsDictionary[eachCoreArr.first!.title] != nil {
                
                // eachCore: [TrialCore]
                // trialCores: [(TrialCore, TrialCore?)]
                
                trialCoresToShow.0.append(eachCoreArr)
                
                if let variationCoreName = movementWithVariation[eachCoreArr.first!.title] {
                    
                    let matchedVariationCore = trialCores[index + 1]
                    if (eachCoreArr.first!.updatedDate < matchedVariationCore.first!.updatedDate) {
                        trialCoresToShow.0[trialCoresToShow.0.count - 1].append(matchedVariationCore.first!)
                    } else {
                        // FIXME: What about else case ? already handled. (added basic)
                    }
                }
            }
        }
        
//        trialCores.forEach {
        for eachCores in trialCores {
//            if $0.first!.title ==
            if let firstTrialCore = eachCores.first,
                 MovementWithPainEnum(rawValue: firstTrialCore.title) != nil {
                trialPainCores.append(eachCores)
            }
        }
        print("trialPainCores: ")
        print("numOfTrialPainCores: \(trialPainCores.count)")
    
//        trialPainCores.forEach {
        for (idx, eachCores) in trialPainCores.enumerated() {
            if eachCores.first != nil {
            print(eachCores.first!.title)
            } else {
                trialCores.remove(at: idx)
            }
        }
        
//        print("trialPainCores")
//        trialPainCores.forEach {
//            print($0.first?.title)
//        }
        
        trialCoresToShow.0.removeFirst()
        
        // Screen 에 따라 Variation 있을수도 없을수도 ..
        print("----------------- trialCoresToShow: -----------------")
        for (index, eachCoreArray) in trialCoresToShow.0.enumerated() {
            print("index: \(index)")
            for eachCore in eachCoreArray {
                print("title: \(eachCore.title), direction: \(eachCore.direction)")
            }
        }
        
        
        print("my result flag")
    bigLoop: for (idx, eachCores) in trialCoresToShow.0.enumerated() {
        
        if let firstElement = eachCores.first {
            print("index : \(idx), title: \(firstElement.title)")
        }
        
            if let first = eachCores.first, let hasPainTitle = MovementsHasPain[first.title] {

            smallLoop: for painCores in trialPainCores {
                    if let painCore = painCores.first {
                        let painTitle = painCore.title
                        if painTitle == hasPainTitle {
                            print("trialCoresToShow index: \(idx), title: \(first.title)")
                            trialCoresToShow.1.append(painCores)
                            break smallLoop
                        }
                    }
                }
            } else {
                print("appending empty to index of \(idx)")
                trialCoresToShow.1.append([])
            }
        }
        
        trialCoresToShow.1.removeFirst()
        
        print("result flag: ")
        for (idx, trialCoreToSho) in trialCoresToShow.1.enumerated() {
            if let first = trialCoreToSho.first {
                print("index: \(idx), title: \(first.title)")
            }
        }
//        trialCoresToShow index: 3, title: Ankle Clearing
//        trialCoresToShow index: 4, title: Shoulder Mobility
//        trialCoresToShow index: 6, title: Trunk Stability Push-up
//        trialCoresToShow index: 7, title: Rotary Stability
        
        print("printingResult")
        for (idx, eachCores) in trialCoresToShow.0.enumerated() {

            if let firstOne = eachCores.first {
                print("BasicTest idx: \(idx)")
                print("first: \(firstOne.title)")
            }
        }
        
        for (idx, eachCores) in trialCoresToShow.1.enumerated() {
            if let second = eachCores.first {
                print("clearingTest idx: \(idx)")
                print("second: \(second.title)")
            }
        }
    }
    
    private func setupLayout() {
        
        view.addSubview(continueBtn)
        continueBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.snp.bottom).offset(-60)
            make.height.equalTo(50)
        }
        
        view.addSubview(trialCollectionView)
        trialCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(continueBtn.snp.top).offset(-15)
        }
    }
}


extension ScreenDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numOfTrialCoresFromCollectionView: \(trialCores.count)")
    
        return trialCoresToShow.0.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! TrialCell
        print("cell : ")
        
        
//        for (idx, trialCoresToShowSmall) in trialCoresToShow.0.enumerated() {
//            print("index: \(idx), \(trialCores.first)")
//        }
        
        
        cell.viewModel = TrialViewModel(trialCoresToShow: (trialCoresToShow.0[indexPath.row], trialCoresToShow.1[indexPath.row]))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50) // prev: 60
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseId, for: indexPath) as! TrialHeader
            return header
        } else {
            assert(false, "Unexpected element kind")
        }
        
    }
    // spacing between items
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 50
//    }
    
    // spacing between Header and collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 50) // prev: 60
    }
}






/*
 
 
 ScreenDetailController

 print("----------------- trialCoresToShow: -----------------")

 index: 0
 title: Deep Squat, direction: Neutral
 index: 1
 title: Hurdle Step, direction: Left
 title: Hurdle Step, direction: Right
 index: 2
 title: Inline Lunge, direction: Left
 title: Inline Lunge, direction: Right
 index: 3
 title: Ankle Clearing, direction: Left
 title: Ankle Clearing, direction: Right
 index: 4
 title: Shoulder Mobility, direction: Left
 title: Shoulder Mobility, direction: Right
 index: 5
 title: Active Straight-LegRaise, direction: Left
 title: Active Straight-LegRaise, direction: Right
 index: 6
 title: Trunk Stability Push-up, direction: Neutral
 index: 7
 title: Rotary Stability, direction: Left
 title: Rotary Stability, direction: Right





 index: 0
 title: Deep Squat, direction: Neutral
 title: Deep Squat Var, direction: Neutral
 index: 1
 title: Hurdle Step, direction: Left
 title: Hurdle Step, direction: Right
 index: 2
 title: Inline Lunge, direction: Left
 title: Inline Lunge, direction: Right
 index: 3
 title: Ankle Clearing, direction: Left
 title: Ankle Clearing, direction: Right
 index: 4
 title: Shoulder Mobility, direction: Left
 title: Shoulder Mobility, direction: Right
 index: 5
 title: Active Straight-LegRaise, direction: Left
 title: Active Straight-LegRaise, direction: Right
 index: 6
 title: Trunk Stability Push-up, direction: Neutral
 title: Trunk Stability Push-up Var, direction: Neutral
 index: 7
 title: Rotary Stability, direction: Left
 title: Rotary Stability, direction: Right

 
 */
