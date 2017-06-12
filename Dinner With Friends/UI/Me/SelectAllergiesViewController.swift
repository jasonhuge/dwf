//
//  SelectAllergiesViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/11/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class SelectAllergiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    var userProfile:UserProfile?
    var isForUser = true
    
    let allergies = FirebaseDatabaseService.sharedInstance.allergies

    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.setupTableView()
 
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAllergiesListUpdated), name:Notification.Name(FirebaseDatabaseNotifications.allergiesListHasUpdated), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableView() {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.allowsSelection = false
    }
    
    @IBAction func onCloseButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onAllergiesListUpdated() {
        self.tableView.reloadData()
    }

}

//MARK: TableView Delegate + Datasource
extension SelectAllergiesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseDatabaseService.sharedInstance.allergies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAllergyTableViewCell")
        
        if let cell = cell as? SelectAllergyTableViewCell {
            let allergy = FirebaseDatabaseService.sharedInstance.allergies[indexPath.row]
            
            var selected = false
            
            if let unwrappedUserProfile = self.userProfile {
                selected = unwrappedUserProfile.hasAllergyFor(allergyID: allergy.id)
            }
            
            cell.delegate = self
            cell.updateWith(allergy:allergy, selected:selected)
        }
        
        return cell!
    }

}

//MARK: SelectAllergyTableViewCellDelegate
extension SelectAllergiesViewController: SelectAllergyTableViewCellDelegate {
    func tableView(cell: SelectAllergyTableViewCell, selected: Bool) {
        
        if let unwrappedUserProfile = self.userProfile, let allergyID = cell.id {
            
            var personType = PersonType.user
            
            if !self.isForUser {
                personType = .family
            }
            
            if selected {
                unwrappedUserProfile.add(allergy:FirebaseDatabaseService.sharedInstance.allergyFor(id: allergyID)!)
                
                FirebaseDatabaseService.sharedInstance.addAllergyFor(personeType: personType, uid: unwrappedUserProfile.uid, allergyid: allergyID, sensitivity: .sensative)
            } else {
                unwrappedUserProfile.remove(allergy:FirebaseDatabaseService.sharedInstance.allergyFor(id: allergyID)!)
                
                FirebaseDatabaseService.sharedInstance.removeAllergyFor(personeType: personType, uid: unwrappedUserProfile.uid, allergyid: allergyID)
            }
        }
    }
}
