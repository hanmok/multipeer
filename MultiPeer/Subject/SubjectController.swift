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


class SubjectController: UIViewController {

    var subjects: [Subject] = []
    
    let inspector: Inspector
    
    var selectedSubject: Subject?
    
    init(inspector: Inspector) {
        self.inspector = inspector
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear called")
    }
    
    // TODO: 선택적으로 가져오기.
    private func fetchAndReloadSubjects() {
        // 여기에서 에러 발생..
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate, ", file: #function)}
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")

        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            subjects = []
            guard let fetchedSubjects = result as? [Subject] else {
                fatalError("faled to case result to [Subject] ")
                 }
            
            for subject in fetchedSubjects {

                guard let parentInspector = subject.inspector else {
                    Subject.deleteSelf(subject)
                    return
                }
                
                if parentInspector.name == inspector.name {
                    subjects.append(subject)
                }
            }
        } catch {
            fatalError("failed to fetch Subjects!")
        }
        
        DispatchQueue.main.async {
            
            self.subjectTableView.reloadData()
        }
    }
    
    private let subjectListLabel = UILabel().then {
        $0.text = "수검자 리스트"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
    }
    
    
    private let addSubjectBtn = UIButton().then {
        let someImage = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {

        let addingController = AddingSubjectController(inspector: inspector)
        addingController.delegate = self
        self.navigationController?.pushViewController(addingController, animated: true)
    }
    
    private let subjectTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        print("subjectcontroller viewdidload called")
        fetchAndReloadSubjects() // 여기서 에러 발생.

        registerTableView()
        
        setupLayout()
        setupAddTargets()
    }
    
    private func setupAddTargets() {
        addSubjectBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
    }
    
    private func registerTableView() {
        subjectTableView.register(SubjectTableCell.self, forCellReuseIdentifier: SubjectTableCell.identifier)
        subjectTableView.delegate = self
        subjectTableView.dataSource = self
        subjectTableView.rowHeight = 80
    }
    
    private func setupLayout() {
        view.addSubview(subjectListLabel)
        subjectListLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(subjectTableView)
        subjectTableView.snp.makeConstraints { make in
            make.top.equalTo(subjectListLabel.snp.bottom).offset(20)
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


extension SubjectController: AddingInspectorDelegate {
    func updateAfterAdded() {
        print("updateAfterAdded called")
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.async {
            self.fetchAndReloadSubjects()

            self.subjectTableView.reloadData()
        }
    }
}


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
        selectedSubject = subjects[indexPath.row]

        let subjectInfoVC = SubjectDetailController(subject: selectedSubject!)
    
        self.navigationController?.pushViewController(subjectInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            let subjectToDelete = self.subjects[indexPath.row]
            
            Subject.deleteSelf(subjectToDelete)
            
            self.subjects.remove(at: indexPath.row)

            self.fetchAndReloadSubjects()

            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
                
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }
}

