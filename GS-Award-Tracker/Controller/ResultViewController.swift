
import MessageUI
import SafariServices
import UIKit
import CoreData


class DMLcell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var logLabel: UILabel!
    
}

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,MFMailComposeViewControllerDelegate {
   
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var hoursCompletedLabel: UILabel!
    
    //refrence to managed object context
    let dmlContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //data for the table
    var items : [DML] = []
    var dml = DML()
    var totalTime : Int = 0
    func formatStartTime(date : Date) -> String {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        // get items from core data
        fetchDML()
        
        
    }
    
    
    func fetchDML() {
 
        do {
            let request = DML.fetchRequest()

            let records = try! dmlContext.fetch(request)
            let sum = records.reduce(0) { $0 + ($1.value(forKey: "minutes") as? Int64 ?? 0) }
            let totalMinutesCompleted = sum%60
            let totalHoursCompleted = (sum-totalMinutesCompleted)/60
            hoursCompletedLabel.text = "Hours Completed = \(totalHoursCompleted) hours and \(totalMinutesCompleted) minutes"
            
            //Set the sorting on request
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            self.items = try dmlContext.fetch(request)
            
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        catch {
            
        }
    }
    
    private func numberOfSEctions(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DMLcell", for: indexPath) as! DMLcell
        
        cell.dateLabel.text  = formatStartTime(date: items[indexPath.row].date ?? Date())
        let indivisualMinutes = items[indexPath.row].minutes
        cell.minLabel.text = "\(indivisualMinutes )"
        cell.logLabel.text = items[indexPath.row].log
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let swipeDelete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
        
        // What DML to remove
            let dmlToRemove = self.items[indexPath.row]
        
        // Remove the DML
            self.dmlContext.delete(dmlToRemove)
            
        // Save the data
            do {
                try self.dmlContext.save()
            } catch {
                
            }
            
        // Re-fetch the Data
            self.fetchDML()
        }
        
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
    

    func writeCoreObjectsToCSV(objects: [NSManagedObject]) -> NSMutableString
    {
        // Make sure we have some data to export
        guard objects.count > 0 else
        {

            return ""
        }

        let mailString = NSMutableString()


        mailString.append("Date, Minutes, Work Log")

        for object in objects
        {
            let rawDate = formatStartTime(date: object.value(forKey: "date")! as! Date)
            // Put "\n" at the beginning so you don't have an extra row at the end
            mailString.append("\n\(rawDate),\(object.value(forKey: "minutes")!), \(object.value(forKey: "log")!)")
        }
        return mailString
    }
    
    @IBAction func emaliButtonPressed(_ sender: UIButton) {
        
        var CoreDataResultsList = [NSManagedObject]()
        CoreDataResultsList = items as [NSManagedObject]
        
        let csvString = writeCoreObjectsToCSV(objects: CoreDataResultsList)
        let data = csvString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        
        if MFMailComposeViewController.canSendMail() {
            let request = DML.fetchRequest()
            let records = try! dmlContext.fetch(request)
            let sum = records.reduce(0) { $0 + ($1.value(forKey: "minutes") as? Int64 ?? 0) }
            let totalMinutesCompleted = sum%60
            let totalHoursCompleted = (sum-totalMinutesCompleted)/60
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setSubject("Girl Scouts Award Project Log")
            vc.setMessageBody("Check Attachment for Project Log. Total Hours Completed = \(totalHoursCompleted) hours and \(totalMinutesCompleted) minutes", isHTML: true)
            vc.addAttachmentData(data!, mimeType: "text/csv", fileName: "Girl Scouts Award Log.csv")
            present(vc,animated: true)
          
        } else {
            
      //      guard case let URL(string: "https://mail.google.com/mail/u/0/#inbox")
      //      let vc = SFSafariViewController(url: url)
        }
        
        
    }

    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    

}
