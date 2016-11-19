//
//  VoiceNoteListController.swift
//  VoiceNote
//
//  Created by darrenyao on 2016/11/18.
//  Copyright © 2016年 VoiceNote. All rights reserved.
//

import UIKit
import MagicalRecord

class VoiceNoteListController: UITableViewController {
    //Constant
    struct Cell {
        struct Identifier {
            static let VoiceNote = "VoiceNoteCell"
        }
    }
    
    //MARK: Property
    var fetchedResultsController : NSFetchedResultsController<VoiceNoteData>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        
        fetchedResultsController = VoiceNoteData.mr_fetchAllSorted(by: "date", ascending: false, with: nil, groupBy: nil, delegate: self, in:NSManagedObjectContext.mr_default()) as! NSFetchedResultsController<VoiceNoteData>
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension VoiceNoteListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            let ss = fetchedResultsController.sections!.count
            return ss
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.VoiceNote) as! VoiceNoteCell
        
        let voice = self.fetchedResultsController.object(at: indexPath)
        cell.applyData(voice: voice)
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension VoiceNoteListController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! VoiceNoteCell
            let voice = fetchedResultsController.object(at: indexPath!)
            cell.applyData(voice: voice)
        case .move:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .automatic)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

