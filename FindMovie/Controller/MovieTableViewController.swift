//
//  MovieTableViewController.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-09.
//

import UIKit

class MovieTableViewController: UITableViewController, UISearchBarDelegate {
    var movies = [Movie]()
    var photoData: [Data]?
    var loadLocal = false
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if loadLocal == true {
            return .delete
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            movies.remove(at: indexPath.row)
            if photoData != nil {
                photoData!.remove(at: indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removedMovie = movies.remove(at: sourceIndexPath.row)
        movies.insert(removedMovie, at: destinationIndexPath.row)
        let removedPhoto = photoData!.remove(at: sourceIndexPath.row)
        photoData!.insert(removedPhoto, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        let item = movies[indexPath.row]
        
        cell.trackName.text = item.trackName
        cell.artistName.text = item.artistName
        cell.movieImage.image = #imageLiteral(resourceName: "gray")
        
        guard item.artworkUrl100 != nil else {
            self.photoData![indexPath.row] = Data()
            return cell
        }
        
        URLSession.shared.dataTask(with: item.artworkUrl100!) { data, response, error in
            if let imageData = data {
                DispatchQueue.main.async {
                    cell.movieImage.image = UIImage(data: imageData)
                    if indexPath.row < self.photoData!.count {
                        self.photoData![indexPath.row] = imageData
                    }
                }
            }
        }.resume()
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchData()
        loadLocal = false
        searchBar.resignFirstResponder()
    }
    
    func fetchData() {
        let searchTerm = searchBar.text ?? ""
        guard !searchTerm.isEmpty else {
            return
        }
        
        let query = [
            "term": searchTerm,
            "lang": "en_us",
            "media": "movie"
        ]
        
        Utility.fetchItems(matching: query) { items in
            DispatchQueue.main.async {
                if let items = items {
                    self.movies = items
                    self.tableView.reloadData()
                    self.photoData = [Data](repeating: Data(), count: self.movies.count)
                } else {
                    print("Unable to load data.")
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "fromAdd" {
            if loadLocal == true {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMovie" {
            if let destination = segue.destination as? DetailTableViewController {
                destination.movie = movies[tableView.indexPathForSelectedRow!.row]
                if photoData != nil && tableView.indexPathForSelectedRow!.row < photoData!.count {
                    destination.photo = photoData![tableView.indexPathForSelectedRow!.row]
                }
            }
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        Utility.encodeFile(movies: movies)
    }
    
    @IBAction func loadButtonAction(_ sender: UIBarButtonItem) {
        if let decode = Utility.decodeFile() {
            movies = decode
            self.photoData = [Data](repeating: Data(), count: self.movies.count)
            loadLocal = true
            tableView.reloadData()
        }
    }
    
    @IBAction func sortButtonAction(_ sender: UIBarButtonItem) {
        if loadLocal == true {
            movies.sort(by: <)
            tableView.reloadData()
        }
    }
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "fromSave" {
            if let source = unwindSegue.source as? SaveTableViewController {
                if let movie = source.movie {
                    movies.append(movie)
                    photoData!.append(Data())
                    tableView.reloadData()
                }
            }
        }
    }
}
