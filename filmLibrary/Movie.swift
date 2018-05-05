//
//  Film.swift
//  filmLibrary
//
//  Created by Alyona Hulak on 4/29/18.
//  Copyright © 2018 Alyona Hulak. All rights reserved.
//

import UIKit
import os.log

class Movie: NSObject, NSCoding {
    
    var title: String
    var genre: String
    var yearOfProduction: String
    var descr: String
    var poster: UIImage?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("movies")
    
    struct PropertyKey {
        static let title = "title"
        static let genre = "genre"
        static let yearOfProduction = "year"
        static let poster = "poster"
        static let descr = "description"
    }
    
    init?(title: String, genre: String, yearOfProduction: String?, poster: UIImage?, description: String?) {
        
        guard !title.isEmpty && !genre.isEmpty else {
            return nil
        }
        
        self.title = title
        self.genre = genre
        self.yearOfProduction = yearOfProduction!
        self.poster = poster
        self.descr = description!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(genre, forKey: PropertyKey.genre)
        aCoder.encode(yearOfProduction, forKey: PropertyKey.yearOfProduction)
        aCoder.encode(poster, forKey: PropertyKey.poster)
        aCoder.encode(descr, forKey: PropertyKey.descr)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
            else {
                os_log("Unable to decode the name for a Movie object.", log: OSLog.default, type: .debug)
                return nil
        }
        guard let genre = aDecoder.decodeObject(forKey: PropertyKey.genre) as? String
            else {
                os_log("Unable to decode the name for a Movie object.", log: OSLog.default, type: .debug)
                return nil
        }
        let poster = aDecoder.decodeObject(forKey: PropertyKey.poster) as? UIImage
        let year = aDecoder.decodeObject(forKey: PropertyKey.yearOfProduction) as? String
        let description = aDecoder.decodeObject(forKey: PropertyKey.descr) as? String
        
        self.init(title: title, genre: genre, yearOfProduction: year, poster: poster, description: description)
        
    }
    

  
}


