//
//  MoovieTableViewController.swift
//  Movies
//
//  Created by Sarika on 20/01/19.
//  Copyright © 2019 Sarika. All rights reserved.
//

import UIKit
import CoreData

class MoovieTableViewController: UITableViewController {

    private var coreData = CoreDataStack()
    private var fetchResultController : NSFetchedResultsController<Movie>?
    private var moovieService : MoovieService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moovieService = MoovieService(context: coreData.persistentContainer.viewContext)
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let section = fetchResultController?.sections{
            return section.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultController?.sections{
            return sections[section].numberOfObjects
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MoovieTableViewCell
        
        if let moovie = fetchResultController?.object(at: indexPath){
            cell.configureCell(moovie: moovie)
            //whenever user click on new star we want to update user rating
            cell.userRatingHandler = { [weak self] (rating) in
                //moovieService to update rating
                self?.moovieService?.updateRating(moovie: moovie, newRating: rating)
                
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let moovieToDelete = fetchResultController?.object(at: indexPath) else {return}
            let deleteAC = UIAlertController(title: "Delete movie", message: "Are you sure you would like to delete movie \"\(moovieToDelete.title ?? "")\"?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] (action) in
                self?.coreData.persistentContainer.viewContext.delete(moovieToDelete)
                self?.coreData.saveContext()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler : nil)
            deleteAC.addAction(deleteAction)
            deleteAC.addAction(cancelAction)
            present(deleteAC, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchResultController?.sections{
          let currentSection = sections[section]
            return currentSection.name
        }
        return ""
    }
    // MARK : Private
    private func loadData(){
        fetchResultController = moovieService?.getMoovie()
        fetchResultController?.delegate = self
    }
    
    @IBAction func resetRatingTapped(_ sender: UIBarButtonItem) {
        moovieService?.resetAllSetting(completion: { [weak self] (success) in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
}

extension MoovieTableViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let indexPath = indexPath else {return}
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
}
