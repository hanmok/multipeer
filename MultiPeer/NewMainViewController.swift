//
//  NewMainViewController.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/27.
//

import UIKit
import SnapKit
import Then

class NewMainViewController: UIViewController {
    
    
    
    private let positionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        //        layout.scrollDirection = .horizontal
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255 , blue: 249 / 255, alpha: 1)
        return collectionView
    }()
    
    var screen: Screen? {
        didSet {
            //            updateTrialCores()
        }
    }
    

    var trialCores: [[TrialCore]] = [[]]
    // 여기에서, Clearing 이 아닌 것들을 골라내야함.
    var trialsToShow: [[TrialCore]] = [[]]
    
    private func updateTrialCores(screen: Screen? = nil) {
        self.trialCores = [[]] // initialize
        
        if screen != nil { self.screen = screen! } else {
            self.screen = Screen.save() // default Screen
        }
        
        let sortedCores = self.screen!.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
        
        var prev = sortedCores.first!
        
        self.trialCores.append([])
        
        for eachCore in sortedCores {
            if prev.title == eachCore.title {
                self.trialCores[self.trialCores.count - 1].append(eachCore)
            } else {
                self.trialCores.append([eachCore])
            }
            prev = eachCore
        }
        self.trialCores.removeFirst()
        // TODO: Filter ! using PositionImgsDictionary
        
        for eachCore in trialCores {
            if PositionImgsDictionary[eachCore.first!.title] != nil {
                trialsToShow.append(eachCore)
                print("added core title : \(eachCore.first!.title)")
            }
        }
        
        trialsToShow.removeFirst()
        for eachCoreArray in trialsToShow {
            for eachCore in eachCoreArray {
                print("core title flaggg: \(eachCore.title) ")
            }
        }
    }
    
    private let connectBtn = UIButton().then {
//        $0.setTitle("Connect", for: .normal)
        let attributedTitle = NSMutableAttributedString(string: "Connect", attributes: [.font: UIFont.systemFont(ofSize: 20)])
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTrialCores()
        registerCollectionView()
        
        setupLayout()
    }
    
    private let completeBtn = UIButton().then {
        $0.setTitle("Complete Screen", for: .normal)
        $0.setTitleColor(UIColor(red: 187 / 255 , green: 187 / 255, blue: 187 / 255, alpha: 1), for: .normal)
        $0.backgroundColor = UIColor(red: 237 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let finishBtn = UIButton().then {
        $0.setTitle("Finish Later", for: .normal)
        $0.setTitleColor(UIColor(red: 187 / 255 , green: 187 / 255, blue: 187 / 255, alpha: 1), for: .normal)
        $0.backgroundColor = UIColor(red: 237 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255, blue: 249 / 255, alpha: 1)
    }
    
    private func setupLayout() {
        
        
        view.addSubview(connectBtn)
        connectBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        self.view.addSubview(positionCollectionView)
        positionCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
//            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.snp.bottom).offset(-120)
        }
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        self.view.addSubview(completeBtn)
        self.view.addSubview(finishBtn)
        

        completeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(32)
            make.width.equalTo(screenWidth / 2 - 20 - 8)
            make.height.equalTo(48)
        }
        
        finishBtn.snp.makeConstraints { make in
            make.leading.equalTo(completeBtn.snp.trailing).offset(16)
            make.bottom.equalToSuperview().inset(32)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(48)
        }
        
        
        view.backgroundColor = UIColor(red: 248 / 255, green: 247 / 255, blue: 249 / 255, alpha: 1)
    }
    
//    private let
    private func registerCollectionView() {
        positionCollectionView.register(PositionCollectionCell.self, forCellWithReuseIdentifier: PositionCollectionCell.cellId)
        positionCollectionView.delegate = self
        positionCollectionView.dataSource = self
    }
}

extension NewMainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        print("numOfTrialCores: \(trialCores.count)")
        //        print("trialCores: \(trialCores)")
        return trialsToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell index: \(indexPath.row)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PositionCollectionCell.cellId, for: indexPath) as! PositionCollectionCell
        //        print("")
        print("trialsToShow: \(trialsToShow[indexPath.row].count)")
        cell.viewModel = PositionViewModel(trialCores: trialsToShow[indexPath.row])
        print("cell : \(cell.viewModel?.title)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = screenWidth / 2 - 28

        return CGSize(width: width, height: width)
    }
}
