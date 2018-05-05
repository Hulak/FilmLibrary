//
//  MovieCollectionViewController.swift
//  filmLibrary
//
//  Created by Alyona Hulak on 4/30/18.
//  Copyright © 2018 Alyona Hulak. All rights reserved.
//

import UIKit
import os.log

class MovieCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    @IBOutlet var movieCollectionView: UICollectionView!
    var movies = [Movie]()
    var searchBar = UISearchBar()
    var searchController = UISearchController()
    var searchTextGeneral = String()
    
    @IBAction func searchAction(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.text = searchTextGeneral
        self.present(searchController, animated: true, completion: nil)
    }
    var searchResults = [Movie]()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let columnsCount = CGFloat(3)
        let columnSpacing = CGFloat(3)
        let itemSizeWidth = UIScreen.main.bounds.width / columnsCount - columnSpacing
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSizeWidth, height: 225)
        layout.minimumLineSpacing = columnSpacing
        layout.minimumInteritemSpacing = 3
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, at: 0)
        
        movieCollectionView.collectionViewLayout = layout

        if let savedMovies = loadMovies() {
            movies += savedMovies
        } else {
            loadSampleMovies()
        }
    }
    
    //MARK: - SEARCH

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.collectionView?.reloadData()
        navigationItem.title = searchTextGeneral
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.collectionView?.reloadData()
        shouldShowSearchResults = false
        navigationItem.title = "Film Library"
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        navigationItem.title = searchTextGeneral
        searchTextGeneral = searchText
        searchResults = movies.filter({ (movie: Movie) -> Bool in
            let titleMatch = movie.title.lowercased().range(of: searchText.lowercased())
            let genreMatch = movie.genre.lowercased().range(of: searchText.lowercased())
            let descriptionMatch = movie.descr.lowercased().range(of: searchText.lowercased())
            let yearMatch = movie.yearOfProduction.range(of: searchText)
            return titleMatch != nil || genreMatch != nil
                || descriptionMatch != nil || yearMatch != nil
        })
        
        if !searchText.isEmpty {
            shouldShowSearchResults = true
            self.collectionView?.reloadData()
        } else {
            shouldShowSearchResults = false
            navigationItem.title = "Film Library"
            self.collectionView?.reloadData()
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            if !shouldShowSearchResults {
            os_log("Adding a new movie", log: OSLog.default, type: .debug)
            } else {
                shouldShowSearchResults = false
                searchResults = movies
                collectionView?.reloadData()
                navigationItem.title = "Film Library"
            }
        case "ShowDetail":
            guard let movieDetailViewController = segue.destination as? MovieViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedMovieCell = sender as? MovieCollectionViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = collectionView?.indexPath(for: selectedMovieCell) else {
                fatalError("The selected cell is not being displayed by the collection")
            }
            if !shouldShowSearchResults {
                let selectedMovie = movies[indexPath.row]
                movieDetailViewController.movie = selectedMovie
            } else {
                let selectedMovie = searchResults[indexPath.row]
                movieDetailViewController.movie = selectedMovie
               // shouldShowSearchResults = false
                //searchResults = movies
            }
        
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shouldShowSearchResults ? searchResults.count : movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        if shouldShowSearchResults {
            let movie = searchResults[indexPath.row]
            cell.poster.image = movie.poster
            cell.title.text = movie.title
            cell.year.text = movie.yearOfProduction
        } else {
            let movie = movies[indexPath.row]
            cell.poster.image = movie.poster
            cell.title.text = movie.title
            cell.year.text = movie.yearOfProduction
        }
        
        return cell
    }
  
    // MARK: Actions
    @IBAction func unwindToMovieList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MovieViewController, let movie = sourceViewController.movie {
            if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.last {
                
                movies[selectedIndexPath.row] = movie
                collectionView?.reloadItems(at: [selectedIndexPath])
            } else {
                let newIndexPath = IndexPath(row: movies.count, section: 0)
                movies.append(movie)
                collectionView?.insertItems(at: [newIndexPath])
            }
            saveMovies()
        }
    }
    
    private func loadSampleMovies() {
        
        movies.append(Movie.init(title: "Suicide Squad", genre: "Action", yearOfProduction: "2016", poster: #imageLiteral(resourceName: "poster1"), description: "A secret government agency recruits some of the most dangerous incarcerated super-villains to form a defensive task force. Their first mission: save the world from the apocalypse.")!)
       
        movies.append(Movie.init(title: "Dunkirk", genre: "War", yearOfProduction: "2017", poster: #imageLiteral(resourceName: "poster2"), description: "Allied soldiers from Belgium, the British Empire and France are surrounded by the German Army, and evacuated during a fierce battle in World War II.")!)
        
        movies.append(Movie.init(title: "X-Men", genre: "Action", yearOfProduction: "2000", poster: #imageLiteral(resourceName: "poster3"), description: "After the re-emergence of the world's first mutant, world-destroyer Apocalypse, the X-Men must unite to defeat his extinction level plan.")!)
        
        movies.append(Movie.init(title: "Palo Alto", genre: "Drama", yearOfProduction: "2013", poster: #imageLiteral(resourceName: "poster4"), description: "The life and struggles of a group of adolescents living in Palo Alto.")!)
    }
    
    private func saveMovies() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(movies, toFile: Movie.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Movies successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save movies.", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMovies() -> [Movie]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Movie.ArchiveURL.path) as? [Movie]
    }
   
}
