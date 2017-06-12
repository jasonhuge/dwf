//
//  BaseUserViewController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 6/4/17.
//  Copyright © 2017 1976. All rights reserved.
//

import UIKit
import AFNetworking
import Firebase

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var hasUpdateProfileImage = false

    //MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUserAvatar()
        
        self.setupTableView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK - Setup
    func setupTableView() {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.register(AllergyTableViewCell.classForCoder(), forCellReuseIdentifier: "AllergyCell")
        
    }
    
    func userAvatarURL() ->String? {
        return nil
    }
    
    func setupUserAvatar() {
        
        if let avatarImageView = self.avatarImageView {
            
            avatarImageView.clipsToBounds = true;
            avatarImageView.contentMode = .scaleAspectFill;
            
            guard let avatarURL = self.userAvatarURL() else {
                print("NO USER URL PRESENTED")
                return
            }
            
            let request = URLRequest.init(url: URL.init(string: avatarURL)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            
            avatarImageView.setImageWith(request, placeholderImage: nil, success: { (request, response, image) in
                avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2;
                avatarImageView.image = image
            }, failure: { (request, response, error) in
                
            })
        }
    }
    
    // MARK - Notifications
    @IBAction func onProfilePhotoButtonTap(_ sender:UIButton) {
        
        var actions = [UIAlertAction]()
        
        let photoActions = UIAlertAction.init(title: "Photos", style: .default, handler: {action in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        actions.append(photoActions)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction.init(title: "Camera", style: .default, handler: {action in
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                
                self.present(imagePicker, animated: true, completion: nil)
            })
            
            actions.append(cameraAction)
            
        }
        
        let alertController = UIAlertController.init(title: "let's add your picture.", message: "choose from your", preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        self.present(alertController, animated: true, completion: nil);
        
    }
    
    // MARK - Allergies
    func addAllergies() {
    
    }
    
    func addDietaryPreferences() {
    
    }
    
    func saveProfileImage(completionBlock: @escaping (Bool, String?) -> Void) {
        
        guard let image = self.avatarImageView.image else {
            print("no image passed to saveProfileImage")
            return
        }
        
        FirebaseStorageService.sharedInstance.upload(image: image, type: .jpeg) { (success, imageURL, error) in
            
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            }
            
            completionBlock(success, imageURL)
            
        }
    }
}

//MARK: UIImagePicker + UINavController Delegate
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let avatarImageView = self.avatarImageView {
            if let avatarImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2;
                avatarImageView.image = avatarImage.cropToSquare(size: CGSize.init(width: 640, height: 640))
                self.hasUpdateProfileImage = true
            }
        } else {
            self.hasUpdateProfileImage = false
        }
        
        dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.hasUpdateProfileImage = false
        dismiss(animated: true, completion: nil)
    }
   
}

//MARK: TableViewDatasource + Delegate
extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = ""
        
        if section == 0 {
            title = "Allergies"
        } else if section == 1 {
            title = "Dietary Preferences"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "MeTableViewHeader")
        
        if let header = header as? MeTableViewHeader {
            header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            if section == 0 {
                header.addButton.addTarget(self, action: #selector(self.addAllergies), for: .touchUpInside)
            } else if section == 1 {
                header.addButton.addTarget(self, action: #selector(self.addDietaryPreferences), for: .touchUpInside)
            }
            
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meTableViewCell")
        
        if indexPath.section == 0 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(allergy: FirebaseDatabaseService.sharedInstance.userProfile.allergies[indexPath.row])
            }
        } else if indexPath.section == 1 {
            if let cell = cell as? AllergyTableViewCell {
                cell.updateWith(dietaryPref: FirebaseDatabaseService.sharedInstance.userProfile.dietaryPrefs[indexPath.row])
            }
        }
        
        return cell!
    }
}

