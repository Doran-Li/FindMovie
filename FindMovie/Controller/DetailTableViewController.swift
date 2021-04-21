//
//  DetailTableViewController.swift
//  FindMovie
//
//  Created by DIANHUA on 2021-04-10.
//

import UIKit
import SafariServices

class DetailTableViewController: UITableViewController {
    var movie: Movie?
    var photo: Data?
    let ABOUT_DETAIL_HEIGHT = CGFloat(400.0)
    let PHOTO_IMAGE_HEIGHT = CGFloat(300.0)
    let DEFAULT_ROW_HEIGHT = CGFloat(44.0)
    let STRING_SPLIT_LENGTH = 10
    var photoIndexPath = IndexPath(row: 0, section: 0)
    var iTunePreviewIndexPath = IndexPath(row: 0, section: 1)
    var trackPreviewIndexPath = IndexPath(row: 0, section: 2)
    var checkAboutDetailIndexPath = IndexPath(row: 9, section: 3)
    var isAboutDetailShow = false {
        didSet {
            aboutDetail.isHidden = !isAboutDetailShow
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var director: UILabel!
    @IBOutlet weak var published: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var rentalPrice: UILabel!
    @IBOutlet weak var aboutDetail: UILabel!
    
    override func viewDidLoad() {
        initialize()
    }
    
    func initialize() {
        if photo != nil {
            imageView.image = UIImage(data: photo!)
        }
        name.text = movie?.trackName
        director.text = movie?.artistName
        published.text = String(movie!.releaseDate!.prefix(STRING_SPLIT_LENGTH))
        country.text = movie?.country
        kind.text = movie?.kind
        genre.text = movie?.primaryGenreName
        buyPrice.text = String(movie!.trackPrice ?? 0.0)
        rentalPrice.text = String(movie!.trackRentalPrice ?? 0.0)
        aboutDetail.text = movie?.longDescription
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
            case (checkAboutDetailIndexPath.section, checkAboutDetailIndexPath.row - 1):
                if isAboutDetailShow {
                    isAboutDetailShow = false
                } else {
                    isAboutDetailShow = true
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            case (iTunePreviewIndexPath.section, iTunePreviewIndexPath.row):
                playVideo()
            case (trackPreviewIndexPath.section, trackPreviewIndexPath.row):
                iTunePreview()
            default:
                break
        }
    }
    
    func playVideo() {
        if let url = movie?.previewUrl {
            let safariViewController = SFSafariViewController(url:url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func iTunePreview() {
        if let url = movie?.trackViewUrl {
            let safariViewController = SFSafariViewController(url:url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
            case (checkAboutDetailIndexPath.section, checkAboutDetailIndexPath.row):
                if isAboutDetailShow {
                    return ABOUT_DETAIL_HEIGHT
                } else {
                    return 0.0
                }
            case (photoIndexPath.section, photoIndexPath.row):
                return PHOTO_IMAGE_HEIGHT
            default:
                return DEFAULT_ROW_HEIGHT
        }
    }
    
    @IBAction func shareButtonAction(_ sender: UIBarButtonItem) {
        guard let image = imageView.image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = tableView
        present(activityController, animated: true, completion: nil)
    }
}
