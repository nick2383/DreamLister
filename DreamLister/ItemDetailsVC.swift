//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Nick Birch on 2017-03-31.
//  Copyright © 2017 Nick Birch. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var priceField: CustomTextField!
    @IBOutlet weak var detailsField: CustomTextField!
    @IBOutlet weak var thumbImg: UIImageView!

    var stores = [Store]()
    var types = [ItemType]()
    var itemToEdit: Item?
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }

        storePicker.delegate = self
        storePicker.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
//        // create Store entities and edit name
//        let store1 = Store(context: context)
//        store1.name = "Best Buy"
//        let store2 = Store(context: context)
//        store2.name = "Tesla Dealer"
//        let store3 = Store(context: context)
//        store3.name = "Frys"
//        let store4 = Store(context: context)
//        store4.name = "Target"
//        let store5 = Store(context: context)
//        store5.name = "Amazon"
//        let store6 = Store(context: context)
//        store6.name = "K-Mart"
//        
//        // create ItemType entities and edit name
//        let type1 = ItemType(context: context)
//        type1.type = "Electronics"
//        let type2 = ItemType(context: context)
//        type2.type = "Vehicle"
//        let type3 = ItemType(context: context)
//        type3.type = "Clothing"
//        
//        // save data to database
//        ad.saveContext()
        
        // get store and itemtype data
        getStores()
        getItemTypes()
        
        if itemToEdit != nil {
            
            loadItemData()
        }
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 1 {
            
            let itemType = types[row]
            return itemType.type
            
        } else {
           
            let store = stores[row]
            return store.name
            
        }
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 1 {
        
            return types.count
            
        } else {
            
            return stores.count
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //update when selected
    }
    
    func getStores(){
        
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        
        do {
            
            self.stores = try context.fetch(fetchRequest)
            self.storePicker.reloadAllComponents()
            
        } catch {
            
            // handle errore
            
        }
    }
    
    func getItemTypes(){
        
        let fetchRequest: NSFetchRequest<ItemType> = ItemType.fetchRequest()
        
        do {
            
            self.types = try context.fetch(fetchRequest)
            self.storePicker.reloadAllComponents()
            
        } catch {
            
            // handle errore
            
        }
    }
    
    
    @IBAction func savedPressed(_ sender: UIButton) {
        
        var item: Item!
        let picture = Image(context: context)
        picture.image = thumbImg.image
        
        
        if itemToEdit == nil {
            
            item = Item(context: context)
            
        } else {
            
            item = itemToEdit
            
        }
        
        item.toImage = picture
        
        if let title = titleField.text {
            
            item.title = title
        }
        
        if let price = priceField.text{
            
            item.price = (price as NSString).doubleValue
        }
        
        if let details = detailsField.text {
            
            item.details = details
        }
        
        item.toStore = stores[storePicker.selectedRow(inComponent: 0)]
        item.toItemType = types[storePicker.selectedRow(inComponent: 1)]
        
        ad.saveContext()
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func loadItemData() {
        
        if let item = itemToEdit {
            
            titleField.text = item.title
            priceField.text = "\(item.price)"
            detailsField.text = item.details
            
            thumbImg.image = item.toImage?.image as? UIImage
            
            if let store = item.toStore {
                
                var index = 0
                repeat {
                    
                    let s = stores[index]
                    if s.name == store.name {
                        
                        storePicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    
                    index += 1
                    
                } while (index < stores.count)
            }
            
            if let type = item.toItemType {
                
                var index = 0
                repeat {
                    
                    let s = types[index]
                    if s.type == type.type {
                        
                        storePicker.selectRow(index, inComponent: 1, animated: false)
                        break
                    }
                    
                    index += 1
                    
                } while (index < types.count)
            }
        }
        
    }
    
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        
        if itemToEdit !=  nil {
            
            context.delete(itemToEdit!)
            ad.saveContext()
        }
        
       _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func addImage(_ sender: UIButton) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            thumbImg.image = img
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    
    
    
    
}
