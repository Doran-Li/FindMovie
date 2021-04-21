//
//  SaveTableViewController.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-13.
//

import UIKit

class SaveTableViewController: UITableViewController {
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
            let name = self.name.text ?? ""
            let director = self.director.text ?? ""
            let published = self.published.text ?? ""
            let country = self.country.text ?? ""
            let about = self.about.text ?? ""
            movie = Movie(kind: "", artistName: director, trackName: name, trackViewUrl: nil, previewUrl: nil, artworkUrl30: nil, artworkUrl60: nil, artworkUrl100: nil, trackPrice: nil, trackRentalPrice: nil, releaseDate: published, country: country, primaryGenreName: nil, shortDescription: nil, longDescription: about)
        }
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
