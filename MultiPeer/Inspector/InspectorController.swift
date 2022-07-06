//
//  InspectorController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import UIKit
import SnapKit
import Then
import CoreData

//protocol InspectorToMainDelgate: AnyObject {
//    func updateCurrentScreen(inspector: Inspector,subject: Subject, screen: Screen, closure: @escaping () -> Void)
//}

class InspectorController: UIViewController {
    
    // MARK: - Properties
    
    var inspectors: [Inspector] = []
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear called")
    }
    
    private func fetchAndReloadInspectors() {
        // 여기에서 에러 발생..
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("failed to get appDelegate, ", file: #function)}
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: .CoreEntitiesStr.inspector)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            inspectors = []
            
            guard let fetchedInspectors = result as? [Inspector] else {
                fatalError("faled to case result to [Inspector] ")
                 }
            
            for inspector in fetchedInspectors {
                print(inspector.value(forKey: "name_") as! String)
                inspectors.append(inspector)
            }
        } catch {
            fatalError("failed to fetch Inspectors!")
        }
        
        DispatchQueue.main.async {
            self.inspectorTableView.reloadData()
        }
        
    }
    
    // MARK: - Properties
    
    private let inspectorListLabel = UILabel().then {
        $0.text = "검사자 목록"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let addInspectorBtn = UIButton().then {
        let someImage = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        $0.addSubview(someImage)
        someImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        $0.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        let addingController = AddingInspectorController()
        addingController.delegate = self
        self.navigationController?.pushViewController(addingController, animated: true)
    }
    
    
    
    private let inspectorTableView = UITableView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        print("inspectorcontroller viewdidload called")
        fetchAndReloadInspectors() // 여기서 에러 발생.

        registerTableView()
        
        setupLayout()
    }
    
    private func registerTableView() {
        inspectorTableView.register(InspectorTableCell.self, forCellReuseIdentifier: InspectorTableCell.identifier)
        inspectorTableView.delegate = self
        inspectorTableView.dataSource = self
        inspectorTableView.rowHeight = 80
    }
    
    
    // MARK: - Helper functions
    private func setupLayout() {
        
        view.addSubview(inspectorListLabel)
        inspectorListLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(inspectorTableView)
        inspectorTableView.snp.makeConstraints { make in
            make.top.equalTo(inspectorListLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(addInspectorBtn)
        addInspectorBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.height.equalTo(60)
        }
    }
}


extension InspectorController: AddingInspectorDelegate {
    func updateAfterAdded() {
        print("updateAfterAdded called")
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.async {
            self.fetchAndReloadInspectors()

            self.inspectorTableView.reloadData()
        }
    }
}


// MARK: - TableView Delegate

extension InspectorController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inspectors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InspectorTableCell.identifier, for: indexPath) as! InspectorTableCell
        
        cell.viewModel = InspectorViewModel(inspector: inspectors[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inspectorInfoVC = SubjectController(inspector: inspectors[indexPath.row])
        
        self.navigationController?.pushViewController(inspectorInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            let inspectorToDelete = self.inspectors[indexPath.row]
            Inspector.deleteSelf(inspectorToDelete)
            self.inspectors.remove(at: indexPath.row)

            self.fetchAndReloadInspectors()

            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }
}
