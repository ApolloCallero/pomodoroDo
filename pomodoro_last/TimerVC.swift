//
//  TimerVC.swift
//  pomodoro_last
//
//  Created by Apollo Callero on 4/11/21.
//
//
//  TimerVC.swift
//  Pomodoro
//
//  Created by Apollo Callero on 4/3/21.
//
import Foundation
import UIKit
import KCCircularTimer
import Firebase
import FirebaseFirestore
import FirebaseAuth
class TimerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startOrBreakLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var date = Date()//getDate()
    var secondsElapsed = 0
    var secondsSinceLeft = 0
    @objc func appMovedToBackground() {
        date = Date()
    }
    
    @objc func appCameToForeground() {
        
        // 4 min elapsed, 6 min study, stop with 2 min left -> 8 min studying
        //time left = -2 min
        //study sess = 6 + (4 - 2)
        let elapsedTime = Date().timeIntervalSince(self.date)
        let minutesElapsed = Int(elapsedTime / 60)
        if self.timerOn{
            let timeLeft = secondsLeft - Int(elapsedTime)//
            if timeLeft < 0{
                let tempTime = self.StudySessionTime
                self.StudySessionTime = Int(self.StudySessionTime + minutesElapsed - (secondsLeft / 60))
                stopStudy()
                self.StudySessionTime = tempTime
            }
            else{
                self.secondsLeft = timeLeft
            }
        }
        else if self.breakTimerOn{
            let timeLeft = secondsLeft - Int(elapsedTime)
            if timeLeft < 0{
                let tempTime = self.breakSessionTime
                self.breakSessionTime = Int(self.breakSessionTime + minutesElapsed - (secondsLeft / 60))
                stopBreak()
                self.breakSessionTime = tempTime
            }
            else{
                self.breakSecondsLeft = timeLeft
            }

        }
    }
    override func viewDidLoad() {
        //to handle the user closing the app
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(coolDetected),name: Notification.Name("coolNotification"), object: nil)
        //init pickerviews
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        self.timePicker.selectRow(24, inComponent: 0, animated: true)
        self.rotatePickerView(pickerView: timePicker)
        self.breakPicker.delegate = self
        self.breakPicker.dataSource = self
        self.breakPicker.selectRow(4, inComponent: 0, animated: true)
        self.rotatePickerView2(pickerView: breakPicker)
        //init circleTimerView
        circleTimerView.showNumber = false
        circleTimerView.lineCap = .butt
        circleTimerView.maximumValue = Double(25 * 60)
        cancelButton.isEnabled = false
        pauseButton.isEnabled = false
        
        
        

        
    }
    @objc func coolDetected (notification: Notification) {
        print("Cool!")
    }
    var StudySessionTime = 0
    var breakSessionTime = 0
    let minutes = Array(1...200)
    var breakTimeSelected = 5
    var studyTimeSelected = 25
    var secondsLeft = 0
    var breakSecondsLeft = 0
    var timerOn = false
    var timer:Timer? = nil
    var breakTimerOn = false
    var breakTimer:Timer? = nil
    var paused = false
    var lastAction = "Break"//whether or not the last completed action by userwas a 'Break' or 'Study'
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var breakPicker: UIPickerView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var circleTimerView: KCCircularTimer!
    
    
    @IBAction func startTapped(_ sender: Any) {
        /* this function controls what happens when the start button is pressed
         if start is tapped it will start/resume the timer for both study and break sessions
        */
        //if the user is starting/resuming a study session
        if lastAction == "Break"{
            //resumes/starts study timer
            self.startStudyTime()
            
            //disable/enable appropiate buttons
            startButton.isEnabled = false
            cancelButton.isEnabled = true
            pauseButton.isEnabled = true
        }
        
        //if the user is starting/resuming a break session
        else if lastAction == "Study"{
            //resumes/starts break timer
            self.startBreakTime()
            
            //disable/enable appropiate buttons
            startButton.isEnabled = false
            cancelButton.isEnabled = true
            pauseButton.isEnabled = true
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        /* this function controls what happens when the cancel button is pressed
         if the 'cancel' is tapped the current study/break session ends and then a study/break session waits to be started
        */
        if lastAction == "Break"{
            self.stopStudy()
        }
        else if lastAction == "Study"{
            self.stopBreak()
        }
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        /*
         this function controls what happens when the 'pause' button is tapped
         when pause is tapped whatever study/break session the user is doing will be paused
         */
        self.paused = true
        self.timerOn = false
        //pause study session
        if lastAction == "Break"{
            self.timer?.invalidate()
        }
        //pause break session
        if lastAction == "Study"{
            self.breakTimer?.invalidate()
        }
        
        //enable start buttton and disable pause button
        startButton.isEnabled = true
        pauseButton.isEnabled = false
    }
    
    
    /*
    timer functions
    */
    

    func startStudyTime(){
        /*
         
         
         */
        startOrBreakLabel.text = "Your Studying!"
        if paused{
            //let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            self.timer?.fire()
            self.paused = false
            timerOn = true
        }
        else if timerOn == false{
            timerOn = true
            secondsLeft = studyTimeSelected * 60
            StudySessionTime = studyTimeSelected
        }
        self.scheduleNotification(time: secondsLeft, title: "Study Time Up!",body: "log back in to start break")
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        self.timer = timer
    }
    func startBreakTime(){
        startOrBreakLabel.text = "Taking a break!"
        print("break timer on: ", breakTimerOn)
        
        if paused{
            //let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            self.timer?.fire()
            self.paused = false
            timerOn = true
        }
        if breakTimerOn == false{
            breakTimerOn = true
            breakSecondsLeft = breakTimeSelected * 60
            breakSessionTime = breakTimeSelected
        }
        self.scheduleNotification(time: breakSecondsLeft, title: "Break Time Up!", body: "log back in to start study time")
        let breakTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(fireBreakTimer), userInfo: nil, repeats: true)
        self.breakTimer = breakTimer
    }
    
    func stopBreak(){
        /* This function stops a break session and then saves it to Firebase
           Is called only when a break session is up or the 'cancel' button is pressed during a break session
           TO DO: add logic if the user stops halfway thru a session
        */
        
        //stop timer
        breakTimerOn = false
        self.breakTimer?.invalidate()
        circleTimerView.currentValue = circleTimerView.maximumValue
        
        //record time on break to firebase
        insertBreakSession(Float(self.breakSessionTime))
        
        lastAction = "Break"
        //enable/diable appropiate buttons
        self.startButton.isEnabled = true
        self.pauseButton.isEnabled = false
        self.cancelButton.isEnabled = false
        
        //get ready for a study session
        startOrBreakLabel.text = "Start Timer To Study!"
        timerLabel.text = "00:00:00"
        self.breakSecondsLeft = breakTimeSelected * 60
    }
    func stopStudy(){
        /*This function stops a Study session and then saves it to Firebase
         Is called only when a session session is up or the 'cancel' button is pressed during a study session
         TO DO: add logic if the user stops halfway thru a session
        */
        //stop timer
        timerOn = false
        self.timer?.invalidate()
        circleTimerView.currentValue = circleTimerView.maximumValue
        
        //record time on break to firebase
        insertStudySession(Float(self.StudySessionTime))
        self.startButton.isEnabled = true
        self.pauseButton.isEnabled = false
        self.cancelButton.isEnabled = false
        
        //get ready for a break session
        startOrBreakLabel.text = "Start Timer To take a break!"
        lastAction = "Study"
        timerLabel.text = "00:00:00"
        self.secondsLeft = studyTimeSelected * 60
    }
    @objc func fireTimer() {
        circleTimerView.maximumValue = Double(StudySessionTime * 60)
        if self.secondsLeft <= 0{
            stopStudy()
        }
        else{
            timerLabel.text = String(format:"%02i:%02i:%02i", (self.secondsLeft / 3600), Int((self.secondsLeft % 3600)/60), (self.secondsLeft % 3600) % 60)
            let start = Double(self.secondsLeft) / circleTimerView.maximumValue
            self.secondsLeft = self.secondsLeft - 1
            let end = Double(self.secondsLeft) / circleTimerView.maximumValue
            circleTimerView.animate(from: start * 60 * Double(studyTimeSelected), to: end * 60 * Double(studyTimeSelected))
        }
    }
    
    @objc func fireBreakTimer() {
        circleTimerView.maximumValue = Double(breakSessionTime * 60)
        if self.breakSecondsLeft <= 0{
            stopBreak()
        }
        else{
            timerLabel.text = String(format:"%02i:%02i:%02i", (self.breakSecondsLeft / 3600), Int((self.breakSecondsLeft % 3600)/60), (self.breakSecondsLeft % 3600) % 60)
            let start = Double(self.breakSecondsLeft) / circleTimerView.maximumValue
            self.breakSecondsLeft = self.breakSecondsLeft - 1
            let end = Double(self.breakSecondsLeft) / circleTimerView.maximumValue
            circleTimerView.animate(from: start * 60 * Double(breakTimeSelected), to: end * 60 * Double(breakTimeSelected))

        }
    }

    func scheduleNotification(time: Int,title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo["message"] = "Yo!"
        // Configure trigger for time seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(time),repeats: false)
        // Create request
        let request = UNNotificationRequest(identifier: "NowPlusFive",content: content, trigger: trigger)
        // Schedule request
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let err = error {print(err.localizedDescription)
            }
        })
    }
    

    func handleNotification(_ response: UNNotificationResponse) {

    }
    
    func notificationAppOpen(){

    }
    
    /*
     Picker View Functions
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0{
            circleTimerView.maximumValue = Double(minutes[row] * 60)
            breakTimeSelected = minutes[row]
            print(breakTimeSelected)
        }
        else{
            circleTimerView.maximumValue = Double(minutes[row] * 60)
            studyTimeSelected = minutes[row]
            print("study: ", studyTimeSelected)
        }
     }
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) ->Int {
        return 1
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.minutes.count
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "a\(self.minutes[row])"
    }
    
    
    func rotatePickerView(pickerView : UIPickerView) {
        /*
         utility function to rotate picker view
         */
        var y = pickerView.frame.origin.y
        var x = pickerView.frame.origin.x
        let rotationAngle = -90 * (3.141526 / 180 )
        pickerView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        pickerView.frame = CGRect(x: x, y: y, width: pickerView.frame.height , height: pickerView.frame.width)
    }
    func rotatePickerView2(pickerView : UIPickerView) {
        /*
         utility function to rotate picker view
         */
        var y = pickerView.frame.origin.y
        var x = pickerView.frame.origin.x
        let rotationAngle = -90 * (3.141526 / 180 )
        pickerView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        pickerView.frame = CGRect(x: x, y: y, width: pickerView.frame.height , height: pickerView.frame.width)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        /*
         display a picker view of numers
         */
        let label = UILabel()
            label.font = UIFont(name: "Helvetica", size: 15)
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
            label.textColor = UIColor.black
            label.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180 ))
            //Put your values in an array like Minutes,Temperature etc.
            label.text = String(self.minutes[row])
            return label
    }

    func insertBreakSession(_ BreakSession: Float ) {
        /*
         parameters:
         BreakSession: float of how many minutes the user took a break for
         adds a break session into firebase
        */
        let user = Auth.auth().currentUser
        let collection = Firestore.firestore().collection(user!.email!).document("BreakSessions").collection("BreakDocuments")
        var ref: DocumentReference?
        //add break document
        ref = collection.addDocument(data: ["Time":BreakSession,"date":getDate()]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    func insertStudySession(_ StudySession: Float ) {
        /*
         parameters:
         StudySession: float of how many minutes the user was studying for
         adds a study session into firebase
        */
        let user = Auth.auth().currentUser
        let collection = Firestore.firestore().collection(user!.email!).document("StudySessions").collection("StudyDocuments")
        var ref: DocumentReference?
        //add break document
        ref = collection.addDocument(data: ["Time":StudySession,"date":getDate()]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
            }
        }
}

