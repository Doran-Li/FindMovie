//
//  MovieTableViewController.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-09.
//

import UIKit
import CoreData

class MovieTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<MovieStore>?
    let PHOTO_HEIGHT = CGFloat(150.0)
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = PHOTO_HEIGHT
        registerFetchedResult();
    }
    
    private func registerFetchedResult() {
        let request: NSFetchRequest<MovieStore> = MovieStore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: "trackName",
            ascending: true,
            selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
        )]
        fetchedResultsController = NSFetchedResultsController<MovieStore>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getAllMovies() -> [MovieStore]? {
        let request: NSFetchRequest<MovieStore> = MovieStore.fetchRequest()
        return try? context.fetch(request)
    }
    
    func insertMovies(movies: [Movie]) {
        //container.performBackgroundTask { [weak self] context in
        context.perform { [self] in
            for movie in movies {
                let newMovie = MovieStore(context: context)
                newMovie.kind = movie.kind
                newMovie.artistName = movie.artistName
                newMovie.trackName = movie.trackName
                newMovie.trackViewUrl = movie.trackViewUrl
                newMovie.previewUrl = movie.previewUrl
                newMovie.artworkUrl30 = movie.artworkUrl30
                newMovie.artworkUrl60 = movie.artworkUrl60
                newMovie.artworkUrl100 = movie.artworkUrl100
                newMovie.trackPrice = movie.trackPrice ?? 0
                newMovie.trackRentalPrice = movie.trackRentalPrice ?? 0
                newMovie.releaseDate = movie.releaseDate
                newMovie.country = movie.country
                newMovie.primaryGenreName = movie.primaryGenreName
                newMovie.longDescription = movie.longDescription
                try? context.save()
            }
        }
    }
    
    func deleteMovie(item: MovieStore) {
        context.delete(item)
        try? context.save()
    }
    
    func deleteAllMovie() {
        context.perform {
            if let items = self.getAllMovies() {
                for item in items {
                    self.deleteMovie(item: item)
                }
            }
        }
        try? context.save()
    }
    
    private func printDatabaseStatistics() {
        context.perform {
            if Thread.isMainThread {
                print("on main thread")
            } else {
                print("off main thread")
            }
            
            if let movieCount = try? self.context.count(for: MovieStore.fetchRequest()) {
                print("\(movieCount) movies")
            }
            
            if let items = self.getAllMovies() {
                for item in items {
                    print("fetched name: \(String(describing: item.artistName))")
                    print("fetched description: \(String(describing: item.longDescription))")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects!.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {action, view, completionHandler in
            self.deleteMovie(item: (self.fetchedResultsController?.object(at: indexPath))!)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        if let item = fetchedResultsController?.object(at: indexPath) {
            cell.trackName.text = item.trackName
            cell.artistName.text = item.artistName
            cell.movieImage.image = #imageLiteral(resourceName: "gray")

            if let link = item.artworkUrl100 {
                URLSession.shared.dataTask(with: link) { data, response, error in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            cell.movieImage.image = UIImage(data: imageData)
                        }
                    }
                }.resume()
            }
            
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchData()
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
                    self.deleteAllMovie()
                    self.insertMovies(movies: items)
                } else {
                    print("Unable to load data.")
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMovie" {
            if let destination = segue.destination as? DetailTableViewController {
                destination.movie = fetchedResultsController?.object(at: tableView.indexPathForSelectedRow!)
            }
        }
    }
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            @unknown default:
                    fatalError("FetchedResultsTableViewController -- unknown case found")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
