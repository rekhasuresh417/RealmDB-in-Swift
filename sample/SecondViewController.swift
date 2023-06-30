//
//  SecondViewController.swift
//  sample
//
//  Created by PQC India iMac-2 on 30/06/23.
//

import UIKit
import RealmSwift

class SecondViewController: UIViewController , UINavigationControllerDelegate {
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chooseButton: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var idTxtField: UITextField!
    
    weak var activeField: UITextField?
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var name, avatar, email, id : String?
  
    override func viewDidLoad() {
        super.viewDidLoad()
   
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI(){
        firstNameTxtField.delegate = self
        lastNameTxtField.delegate = self
        emailTxtField.delegate = self
        idTxtField.delegate = self
    }
    
    // MARK - Keyboard notification
    @objc func keyboardDidShow(notification: Notification) {
        let verticalPadding: CGFloat = 20.0 // Padding between the bottom of the view and the top of the keyboard
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        guard let activeField = activeField, let keyboardHeight = keyboardSize?.height else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + verticalPadding, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        let activeRect = activeField.convert(activeField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(activeRect, animated: true)
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
  
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        if self.imageView.image == nil {
            String().alert(view: self, title: "Knila Info", message: "Please select profile image")
        }else if self.firstNameTxtField.text == "" {
            String().alert(view: self, title: "Knila Info", message: "Enter first name")
        }else if self.lastNameTxtField.text == "" {
            String().alert(view: self, title: "Knila Info", message: "Enter last name")
        }else if self.emailTxtField.text == "" {
            String().alert(view: self, title: "Knila Info", message: "Enter email id")
        }else if self.idTxtField.text == "" {
            String().alert(view: self, title: "Knila Info", message: "Enter user id")
        }else {
            String().alert(view: self, title: "Knila Info", message: "Registration successfully")
            
            // Step 1: Convert the image to a Data object
            guard let imageData = imageView.image?.pngData() else {
                // Handle error if the image data cannot be generated
                return
            }

            
            self.saveIntoCoreData(id: idTxtField.text!, avatar: imageData, email: emailTxtField.text!, firstName: firstNameTxtField.text!, lastName: lastNameTxtField.text!)
        }
    }
    
    func saveIntoCoreData(id: String, avatar: Data, email: String, firstName: String, lastName: String)  {
       let person = PersonDetails()
        person.avatar = avatar
        person.firstName = firstName
        person.lastName = lastName
        person.email = email
        person.userId = id
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(person)
                print("saved into DB")
                
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ThirdViewController") as? ThirdViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }catch {
            print("error for saving to DB", error.localizedDescription)
        }
    }
    
    @IBAction func btnClicked() {
        selectImageFrom(.photoLibrary)
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Saving Image here
    @IBAction func save(_ sender: AnyObject) {
        guard let selectedImage = imageView.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
   
}

//MARK: - Add image to Library
extension SecondViewController: UIImagePickerControllerDelegate{
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageView.image = selectedImage
    }
    
    
}
// MARK: UITextFieldDelegate methods
extension SecondViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
