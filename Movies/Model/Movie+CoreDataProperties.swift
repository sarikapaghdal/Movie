//
//  Movie+CoreDataProperties.swift
//  Movies
//
//  Created by Sarika on 19/01/19.
//  Copyright © 2019 Sarika. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var format: String?
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var userRating: Int16

}
