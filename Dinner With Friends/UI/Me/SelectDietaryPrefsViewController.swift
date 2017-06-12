//
//  SelectDietaryPrefsViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/25/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit

class SelectDietaryPrefsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    var userProfile:UserProfile?
    var isForUser = true
    
    let allergies = FirebaseDatabaseService.sharedInstance.allergies
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDietaryPrefsListUpdated), name:Notification.Name(FirebaseDatabaseNotifications.dietaryPreferencesListHasUpdated), object: nil)
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
    
    func onDietaryPrefsListUpdated() {
        self.tableView.reloadData()
    }
    
}

//MARK: TableView Delegate + Datasource
extension SelectDietaryPrefsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseDatabaseService.sharedInstance.dietaryPrefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAllergyTableViewCell")
        
        if let cell = cell as? SelectAllergyTableViewCell {
            let dietaryPref = FirebaseDatabaseService.sharedInstance.dietaryPrefs[indexPath.row]
            
            var selected = false
            
            if let unwrappedUserProfile = self.userProfile {
                selected = unwrappedUserProfile.hasDietaryPrefFor(dietaryPrefID: dietaryPref.id)
            }
            
            cell.delegate = self
            cell.updateWith(dietaryPref: dietaryPref, selected: selected)
        }
        
        return cell!
    }
    
}

//MARK: SelectAllergyTableViewCellDelegate
extension SelectDietaryPrefsViewController: SelectAllergyTableViewCellDelegate {
    func tableView(cell: SelectAllergyTableViewCell, selected: Bool) {
        if self.isForUser {
            if let unwrappedUserProfile = self.userProfile, let prefID = cell.id {
                
                var personType = PersonType.user
                
                if !self.isForUser {
                    personType = .family
                }
                
                if selected {
                    unwrappedUserProfile.add(dietaryPref: FirebaseDatabaseService.sharedInstance.dietaryPrefFor(id: prefID)!)
                    FirebaseDatabaseService.sharedInstance.addDietaryPrefFor(personeType: personType, uid: unwrappedUserProfile.uid, prefid: prefID)
                } else {
                    unwrappedUserProfile.remove(dietaryPref: FirebaseDatabaseService.sharedInstance.dietaryPrefFor(id: prefID)!)
                    FirebaseDatabaseService.sharedInstance.removeDietaryPrefFor(personeType: personType, uid: unwrappedUserProfile.uid, prefid: prefID)
                }
            }
        }
    }
}
