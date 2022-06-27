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
class TrialDetailController: UIViewController {
    
    var screen: Screen {
        didSet {
            DispatchQueue.main.async {
                self.trialCollectionView.reloadData()
            }
        }
    }
    var trialCores: [TrialCore] = []
    
    let reuseId = "TrialCellId"
    let headerReuseId = "HeaderId"
    
    private let trialCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
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
        self.trialCores = screen.trialCores.sorted {
            if $0.tag != $1.tag {
                return $0.tag < $1.tag
            } else {
                return $0.direction.count < $1.direction.count
            }
        }
        
        registerCollectionView(customCollectionView: trialCollectionView)
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(trialCollectionView)
        trialCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension TrialDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numOfTrialCoresFromCollectionView: \(trialCores.count)")
        return trialCores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! TrialCell
        
        cell.viewModel = TrialViewModel(trialCore: trialCores[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 60)
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
        return CGSize(width: screenWidth, height: 60)
    }
}
