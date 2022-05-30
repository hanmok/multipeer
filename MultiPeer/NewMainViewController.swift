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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
        private let positionCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
    
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            return collectionView
        }()
    
        private func registerCollectionView() {
            positionCollectionView.register(SubjectCollectionCell.self, forCellWithReuseIdentifier: reuseId)
            positionCollectionView.delegate = self
            positionCollectionView.dataSource = self
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

extension NewMainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PositionCollectionCell.cellId, for: indexPath) as! PositionCollectionCell
        
        return cell
    }
    
    
}



class PositionCollectionCell: UICollectionViewCell {
    static let cellId = "cellId"
}
