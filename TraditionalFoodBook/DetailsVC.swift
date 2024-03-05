//
//  DetailsVC.swift
//  TraditionalFoodBook
//
//  Created by Yusuf Köksal on 5.03.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var inventorText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenFood = ""
    var chosenFoodId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenFood != ""{
            // Core Data
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Foods")
            let idString = chosenFoodId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        
                        if let inventor = result.value(forKey: "inventor") as? String{
                            inventorText.text = inventor
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                        
                        
                    }
                }
                
            }catch{
                print("error")
            }
            
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

    @IBAction func saveClickedButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newFood = NSEntityDescription.insertNewObject(forEntityName: "Foods", into: context)
        
        newFood.setValue(nameText.text, forKey: "name")
        newFood.setValue(inventorText.text, forKey: "inventor")
        
        
        if let year = Int(yearText.text!){
            newFood.setValue(year, forKey: "year")
        }
        
        newFood.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newFood.setValue(data, forKey: "image")
        do{
            try context.save()
            print("Saved")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
