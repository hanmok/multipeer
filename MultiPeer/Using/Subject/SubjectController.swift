//
//  SubjectController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit
import SnapKit
import Then
import CoreData

let reuseId = "SubjectId"

protocol SubjectControllerDelegate: AnyObject {
    func updateCurrentScreen(from subject: Subject, with screen: Screen, closure: () -> Void)
}

class SubjectController: UIViewController {
// TODO: import CoreData
//    let persistenceController = PersistenceController.shared
    var subjects: [Subject] = []
    
    weak var basicDelegate: SubjectControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear called")
    }
    
    private func fetchAndReloadSubjects() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate, ", file: #function)}
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)

            subjects = []
            guard let fetchedSubjects = result as? [Subject] else {
                fatalError("failed to cast result to [Subject] ")
                 }
            
            for subject in fetchedSubjects {
                print("fail flag 33")
                print(subject.value(forKey: "name_") as! String)
                subjects.append(subject)
            }
        } catch {
            fatalError("failed to fetch Subjects!")
        }
        
        DispatchQueue.main.async {
            self.subjectTableView.reloadData()
        }
    }
    
    // MARK: - Properties
    private let searchTF = UITextField().then { $0.placeholder = "Subject Name"}
    
    private let searchBtn = UIButton().then {
        let glassImage = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        glassImage.tintColor = .white
        
        $0.addSubview(glassImage)
        glassImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    private let searchBox = UIView().then {
        $0.layer.borderColor = UIColor.yellow.cgColor
        $0.layer.borderWidth = 2
    }
    
    private let addSubjectBtn = UIButton().then {
        let someImage = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        $0.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        let addingController = AddingSubjectController()
        addingController.delegate = self
        self.navigationController?.pushViewController(addingController, animated: true)
    }
    
//    private let subjectCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return collectionView
//    }()
    
    private let subjectTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("subjectcontroller viewdidload called")
        print("flag 0")
        fetchAndReloadSubjects() // 여기서 에러 발생.
        print("flag 1 ")
//        registerCollectionView()
        registerTableView()
        
        print("flag 2")
        setupLayout()
        print("flag 3")
        // Do any additional setup after loading the view.
    }
    
//    private func registerCollectionView() {
//        subjectCollectionView.register(SubjectCollectionCell.self, forCellWithReuseIdentifier: reuseId)
//        subjectCollectionView.delegate = self
//        subjectCollectionView.dataSource = self
//    }
    
    private func registerTableView() {
        subjectTableView.register(SubjectTableCell.self, forCellReuseIdentifier: SubjectTableCell.identifier)
        subjectTableView.delegate = self
        subjectTableView.dataSource = self
        subjectTableView.rowHeight = 80
    }
    
    private func setupLayout() {
        view.addSubview(searchBox)
        [searchTF, searchBtn].forEach { searchBox.addSubview($0) }
        
        searchBox.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.height.equalTo(35)
        }
        
        searchBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(25)
        }
        
        searchTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(searchBtn.snp.leading).offset(-10)
        }
        
//        view.addSubview(subjectCollectionView)
        
//        subjectCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(searchBox.snp.bottom).offset(20)
//            make.leading.trailing.equalToSuperview().inset(20)
//            make.bottom.equalToSuperview()
//        }
        
        
        view.addSubview(subjectTableView)
        subjectTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBox.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(addSubjectBtn)
        addSubjectBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.height.equalTo(60)
        }
    }
}


extension SubjectController: SubjectDetailDelegate {
    // Detail 이 명령하면
    func sendback(_ subject: Subject, with screen: Screen) {
//       SubController 의 delegate 을 받는 PositionController 에게
//       update  명령, 그 후 pop
        
        basicDelegate?.updateCurrentScreen(from: subject, with: screen) {
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


extension SubjectController: AddingSubjectDelegate {
    func updateAfterAdded() {
        print("updateAfterAdded called")
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.async {
            self.fetchAndReloadSubjects()

//            self.subjectCollectionView.reloadData()
            self.subjectTableView.reloadData()
        }
    }
}

// MARK: - CollectionView Delegate

/*
extension SubjectController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("flaggga numOfSubjects: \(subjects.count)")
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! SubjectCollectionCell
        
        cell.viewModel = SubjectViewModel(subject: subjects[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subjectInfoVC = SubjectDetailController(subject: subjects[indexPath.row])
        subjectInfoVC.detailDelegate = self
        self.navigationController?.pushViewController(subjectInfoVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        Subject.deleteSelf(subjects[indexPath.row])
        
        fetchAndReloadSubjects()
        DispatchQueue.main.async {
            self.subjectCollectionView.reloadData()
        }
    }
}

*/

// MARK: - TableView Delegate

extension SubjectController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableCell.identifier, for: indexPath) as! SubjectTableCell
        
        cell.viewModel = SubjectViewModel(subject: subjects[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subjectInfoVC = SubjectDetailController(subject: subjects[indexPath.row])
        subjectInfoVC.detailDelegate = self
        self.navigationController?.pushViewController(subjectInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            
            
            //            tableView.deleteRows(at: [indexPath], with: .fade)
//            let screenToDelete = self.screens[indexPath.row]
            let subjectToDelete = self.subjects[indexPath.row]
            //            Screen.deleteSelf(self.screens[indexPath.row])
//            Screen.deleteSelf(screenToDelete)
            Subject.deleteSelf(subjectToDelete)
            //            self.screens.remove(at: indexPath.row)
//            self.subject.screens.remove(screenToDelete)
//            self.subjects.remove(at: <#T##Int#>)
            self.subjects.remove(at: indexPath.row)
//            self.fetchAndReloadScreens()
            self.fetchAndReloadSubjects()
            //            tableView.reloadData()
            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }

}




