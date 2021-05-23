//
//  SaveTableViewController.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-13.
//

import UIKit
import CoreData

class SaveTableViewController: UITableViewController {
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var director: UITextField!
    @IBOutlet weak var published: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var save: UIBarButtonItem!
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonStatus()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromSave" {        
            saveNewMovie()
        }
    }
    
    fileprivate func saveNewMovie() {
        let newMovie = MovieStore(context: context)
        newMovie.artistName = self.director.text ?? ""
        newMovie.trackName = self.name.text ?? ""
        newMovie.releaseDate = self.published.text ?? ""
        newMovie.longDescription = self.about.text ?? ""
        newMovie.country = self.country.text ?? ""
        try? context.save()
    }
    
    func updateSaveButtonStatus() {
        let name = self.name.text
        let director = self.director.text
        let published = self.published.text
        let country = self.country.text
        save.isEnabled = !name!.isEmpty && !director!.isEmpty && !published!.isEmpty && !country!.isEmpty
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        updateSaveButtonStatus()
    }
    @IBAction func returnAction(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
