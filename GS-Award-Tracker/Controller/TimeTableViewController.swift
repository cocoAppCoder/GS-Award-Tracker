

import UIKit


class TimeTableViewController : UIViewController {
    
    @IBOutlet weak var workDateEntered: UITextField!
    @IBOutlet weak var invalidDateLabel: UILabel!
    @IBOutlet weak var minutesEntry: UITextField!
    @IBOutlet weak var invalidTimeLabel: UILabel!
    @IBOutlet weak var workDescription: UITextView!
    @IBOutlet weak var invalidDescpritionLabel: UILabel!
    
    
    var dml = DML()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func initializeHideKeyboard() {
        //decloration of tap gesture recognizer -> dissmiss key board function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //add tap gesture to parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        // dismiss the keyboard
        view.endEditing(true)
    }
    
    
    @IBAction func addEntryPressed(_ sender: UIButton) {
        
        //values of the text fields before refresh
                let workDateEnteredText = workDateEntered.text ?? "\(Date())"
                let minutesEntryText = minutesEntry.text ?? "0"
                let workDescriptionText = workDescription.text ?? ""
                
                //format string -> date
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "MMM d, yyyy"
                let workDateTextFormat = dateFormatter.date(from : workDateEnteredText)// ?? Date()
                
        
        // Display invalid entry message if the total minutes > a day (or)
        // Date is in the future (or)
        // Description is empty
        if ( (Int64(minutesEntryText) ?? 0 >= 1440) ) {
            invalidTimeLabel.isHidden = false
        }
        else if ( Int64(minutesEntryText) == nil ) {
            invalidTimeLabel.isHidden = false
        }
        else
        {
            invalidTimeLabel.isHidden = true
        }
        if (workDateTextFormat ?? Date() > Date()) {
            invalidDateLabel.isHidden = false
        }
        else {
            invalidDateLabel.isHidden = true
        }
        if (workDescriptionText.trimmingCharacters(in: .whitespaces ) == "") {
            invalidDescpritionLabel.isHidden = false
        }
        else {
            invalidDescpritionLabel.isHidden = true
        }
        
        if(invalidTimeLabel.isHidden && invalidDateLabel.isHidden  && invalidDescpritionLabel.isHidden){
            
            //create a DML object
            let newDML = DML(context: self.context)
            newDML.date = workDateTextFormat
            newDML.minutes = Int64(minutesEntryText) ?? 0
            newDML.log = String(workDescriptionText)
            
            dml.addTime(plusTime: Int(newDML.minutes))
            
                //save data
                do {
                    try self.context.save()
                }
                catch {
                    //TODO:  Display an error
                }
            
            //refresh
            let workLogDate = Date()
            workDateEntered.text = formatStartTime(date: workLogDate )
            minutesEntry.text = ""
            workDescription.text = ""
           
        }
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeHideKeyboard()
        
        workDescription.layer.borderWidth = 1.0
        workDescription.layer.borderColor = UIColor.lightGray.cgColor
        minutesEntry.layer.borderWidth = 1.0
        minutesEntry.layer.borderColor = UIColor.lightGray.cgColor
        workDateEntered.layer.borderWidth=1.0
        workDateEntered.layer.borderColor = UIColor.lightGray.cgColor
        
        let startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .date//AndTime
        startTimePicker.addTarget(self, action: #selector(startTimeChange(startTimePicker:)), for: UIControl.Event.valueChanged)
        startTimePicker.frame.size = CGSize(width: 0, height: 300)
        startTimePicker.preferredDatePickerStyle = .wheels
        if (workDateEntered != nil){
        workDateEntered.inputView =  startTimePicker
      
        
        workDateEntered.text = formatStartTime(date: Date())
        }
    }
    
    @ objc func startTimeChange(startTimePicker: UIDatePicker) {
        
        workDateEntered.text = formatStartTime(date: startTimePicker.date)
    }
    
    func formatStartTime(date : Date) -> String {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)

    }
    
    
    @IBAction func checkProgressPressed(_ sender: Any) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResult" {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.totalTime = Int(dml.resultTime())
            
        }
    }
   
}


