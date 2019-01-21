//
//  MoovieService.swift
//  Movies
//
//  Created by Sarika on 20/01/19.
//  Copyright © 2019 Sarika. All rights reserved.
//

import Foundation
import CoreData

class MoovieService{
    //we dont need to create "MoovieService" instance to call function so we are using static keyword here.
    
    private var context : NSManagedObjectContext
    init(context : NSManagedObjectContext) {
        self.context = context
    }
    
    func getMoovie() -> NSFetchedResultsController<Movie>{
        let fetchedResultsController : NSFetchedResultsController<Movie>
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let formatSortDescriptor = NSSortDescriptor(key:"format", ascending : true)
        let titleSortDescriptor = NSSortDescriptor(key:"title", ascending : true)
        request.sortDescriptors = [formatSortDescriptor,titleSortDescriptor]
        
        //group by "format" field
        //if you dealing with large dataset then cacheName will improve performance of your App.
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "format" , cacheName: "movieLibrary") //there will be cache created for us with name "movieLibrary" so on subsequent call when you load the app its going to load from "movieLibrary" cache.when you dealing with big dataSet , loading time will be from second to millisecond
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error in fetching records")
        }
        return fetchedResultsController
    }
    
    func updateRating(moovie : Movie, newRating : Int) {
        moovie.userRating = Int16(newRating)
        
        do {
            try context.save()
        } catch  {
            print("Error updating moovie rating")
        }
    }
    
    func resetAllSetting(completion: (Bool) -> Void){
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Movie")
        batchUpdateRequest.propertiesToUpdate = ["userRating" : 0]
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        do {
            if let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult{
                if let objectIds = result.result as? [NSManagedObjectID]{
                    
                    for objectId in objectIds{
                        let obj = context.object(with: objectId)
                        
                        if !obj.isFault{
                            context.stalenessInterval = 0
                            context.refresh(obj, mergeChanges: true)
                        }
                    }
                    completion(true)
                }
            }
        } catch  {
            completion(false)
        }
    }
}
