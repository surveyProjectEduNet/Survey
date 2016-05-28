//
//  ViewController.swift
//  AppSurveyCouchDB
//
//  Created by admin on 5/7/16.
//  Copyright © 2016 baoTranIOS. All rights reserved.
//

import UIKit


//SSRadioButtonControllerDelegate là 1 cái class dùng để tạo ra những cái nút dạng ô radio button

class ViewController: UIViewController, SSRadioButtonControllerDelegate {

    //MARK: IBOutlet
    
    @IBOutlet weak var tvInformation: UITextView!
    
    @IBOutlet weak var txtQuestion: UITextField!
    
    @IBOutlet weak var txtAnswer: UITextField!
    
    @IBOutlet weak var lblQuestion: UILabel!
    
    @IBOutlet weak var txtTypeQestion: UITextField!
    
    @IBOutlet weak var btnAnswer: UIButton!
    
    @IBOutlet weak var txtAnswer02: UITextField!
    
    @IBOutlet weak var txtAnswer03: UITextField!
    
    @IBOutlet weak var txtAnswer04: UITextField!
    
    @IBOutlet weak var lblTest: UILabel!
    //MARK: Biến Database
    
    var database: CBLDatabase!
    
    //MARK: Biến toàn cục
    
    //Khai báo biến là NSMutableDictionary để lưu nhiều câu trả lời
    var arrayMultiAnswer: NSMutableDictionary?
    
    //Khai báo biến là radio button
     var radioButtonController: SSRadioButtonsController?
    
    //Khai báo biến cho 3 mảng
    var mutableArray: NSMutableArray = [] //Mảng này để lưu dữ liệu kéo xuống từ server, bao gồm cả Answer và Question
    
    var answerArray: NSMutableArray = [] //Mảng này dùng để đưa câu trả lời vào
    
    var multiAnswerArray: NSMutableDictionary = [:] //Mảng này dùng để đưa nhiều câu trả lời vào (dành cho câu hỏi có nhiều câu trả lời)
    
    var questionArray: NSMutableArray = [] //Mảng này dùng để đưa câu hỏi vào
    
    var stringQuestion: NSString = "" //Chuỗi này em dùng để test câu hỏi xuất ra
    var stringAnswer: NSString = "" //Chuỗi này em dùng để test câu trả lời
    
    //Khai báo con trỏ chạy câu hỏi và câu trả lời
    var indexAnswerQuestion = 0
    
    var timer : Int = Int()
    //Hàm này dùng để truy xuất đến Database
    func useDatabase(database: CBLDatabase!) -> Bool {
        guard database != nil else {return false} //Kiểm tra nếu rỗng tức database bị xoá thì thoát ứng dụng
        
        self.database = database //gán biến database vào cho biến database toàn cục
        
        // Define a view with a map function that indexes to-do items by creation date: Đoạn này dùng để tạo View, em chưa đụng đến nó, chỉ viết để sẵn
        database.viewNamed("byDate").setMapBlock("2") {
            (doc, emit) in
            if let date = doc["created_at"] as? String {
                emit(date, doc)
            }
        }
        //Hàm này cũng là View, anh Cường không cần xem hàm này đâu :D
        // ...and a validation function requiring parseable dates:
        database.setValidationNamed("created_at") {
            (newRevision, context) in
            if !newRevision.isDeletion,
                let date = newRevision.properties?["created_at"] as? String
                where NSDate.withJSONObject(date) == nil {
                context.rejectWithMessage("invalid date \(date)")
            }
        }
        return true
    }
    
    //Lúc chạy thì em cho cái nút btnAnswer thành 1 cái radio button
    override func viewWillAppear(animated: Bool) {
        radioButtonController = SSRadioButtonsController(buttons: btnAnswer)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        
        print("You just click on timer \(self.timer)")
        
        
        
    }
    
    func message(){
        //print("ABC")
        let alert = UIAlertController(title: "Time'up", message: "We ran out of time", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Database-related initialization:
        if useDatabase(appDelegate.database) { //Em gọi hàm useDatabase để sử dụng
            // Create a query sorted by descending date, i.e. newest items first:
            //let query = database.viewNamed("byDate").createQuery().asLiveQuery()
            //query.descending = true
            self.tvInformation?.text = String(self.answerArray.count) + String(self.questionArray.count) + String(self.mutableArray.count)
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loadDataFromCouchbase() //Hàm này load data từ database Couchbase
        
        
        let  answer = answerArray[indexAnswerQuestion] //Lấy answer đầu tiên ra, indexAnswerQuestion ban đầu = 0
        let question = questionArray[indexAnswerQuestion] //Lấy question đầu tiên ra, indexAnswerQuestion ban đầu = 0
        
        self.lblQuestion.text = String("Câu \(indexAnswerQuestion + 1) \(question)") //Xuất câu hỏi lên label
        self.btnAnswer.setTitle(String("\(answer)"), forState: .Normal) //Xuất câu trả lời lên nút, này làm nhiều nút em chưa làm, chỉ mới test 1 nút answer
        
        let messageTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.timer), target: self, selector: #selector(self.message), userInfo: nil, repeats: false)
    }

    //Hàm này để ẩn keyboard sau khi nhập liệu xong
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Nút thêm data vào database
    @IBAction func btnCreateData(sender: AnyObject) {
        
        var answerArrayJSON = ["answer01": (self.txtAnswer?.text)!, "answer02": (self.txtAnswer02?.text)!, "answer03": (self.txtAnswer03?.text)!, "answer04": (self.txtAnswer04?.text)!] //Tạo mảng JSON để lưu những câu trả lời từ textField
        
        let properties : [String : AnyObject] = //Mảng JSON để đẩy dữ liệu lên Server
            [
                "tableNameBAO": "Survey", //Key là tableNameBAO, Value là Survey
                "key_question_EDUNET": (self.txtQuestion?.text)!, //Key là key_question_EDUNET, Value là câu hỏi từ ô textField questions
                "type": (self.txtTypeQestion?.text)!, //Key là type, Value là kiểu type quetsion: Single hoặc Multi
                "key_answer_EDUNET": answerArrayJSON, //Key là key_answer_EDUNET, Value là mảng answerArrayJSON
                "male_EDUNET": 0, //Key là male_EDUNET, Value là 0, nghĩa là câu hỏi này chưa có người giới tính nam nào trả lời câu hỏi này
                "female_EDUNET": 0, //Key là female_EDUNET, Value là 0, nghĩa là câu hỏi này chưa có người giới tính nữ nào trả lời câu hỏi này
                "created_at_EDUNET": 2016 //Key là created_at_EDUNET, Value là 2016, chỗ này em để tĩnh, anh có thể đưa vào NSDate là ngày hiện tại
        ]
        
        //Lưu dữ liệu
        do {
            let document = self.database.createDocument() //Create 1 cái documents ra
            try document.putProperties(properties) //Đẩy dữ liệu lên Server
        } catch let error as NSError {
            self.appDelegate.showAlert("Couldn't save new item", forError: error) //Xuất lỗi nếu không đưa dữ liệu vào Database được
        }
    }
    
    @IBAction func btnRetrieveData(sender: AnyObject) {
    }
    
    func loadDataFromCouchbase() { //lấy dữ liệu ra từ server
        do {
            let query = self.database.createAllDocumentsQuery() //Tạo 1 cái query
            query.allDocsMode = CBLAllDocsMode.AllDocs //Lấy toàn bộ Documents là dữ liệu đang có trên server xuống
            let result = try query.run() //Result là kết quả trả về sau khi query
            while let row = result.nextRow() { //Lấy từng dòng dữ liệu bao gồm key và value đưa vào mảng mutableArray
                self.mutableArray.addObject(row.documentID!)
            }
            //self.tvInformation?.text = String(self.mutableArray.count)
            for i in 0 ..< self.mutableArray.count  { //Lấy dữ liệu từ mảng mutableArray để đưa vào từng mảng riêng
                let document = self.database.documentWithID(mutableArray[i] as! String) //Lấy từng ID dữ liệu ra
                if let answer = document!["key_answer_EDUNET"] as? String { //Nếu là key_answer_EDUNET thì đưa vào mảng answerArray
                    self.answerArray.addObject(answer) //Đưa dữ liệu vào mảng
                }
                if let answer = document!["key_answer_EDUNET"] as? [String: AnyObject] { //Lấy câu hỏi nào có nhiều câu trả lời
                    if let answer01 = answer["answer01"] as? String {
                        self.multiAnswerArray[0] = answer01 //đưa vào câu 01
                    }
                    if let answer01 = answer["answer01"] as? String {
                        self.multiAnswerArray[0] = answer01 //đưa vào câu 02
                    }
                    if let answer01 = answer["answer01"] as? String {
                        self.multiAnswerArray[0] = answer01 //đưa vào câu 03
                    }
                    if let answer01 = answer["answer01"] as? String { //đưa vào câu 04
                        self.multiAnswerArray[0] = answer01
                    }
                }
                if let question = document!["key_question_EDUNET"] as? String { //đưa vào những dòng có key_question_EDUNET vào mảng question

                    self.questionArray.addObject(question)
                }
                //                if let question = document!["key_question_BAO"] as? String {
                //                    self.questionArray.addObject(question)
                
            }
            //self.tvInformation?.text = String(self.answerArray.count)
            print(self.answerArray.count) //Đoạn này em chỉ test anh Cường không cần xem đâu :D
            for i in 0 ..< self.answerArray.count  {
                let url = self.answerArray[i]
                self.stringAnswer = (self.stringAnswer as String) + String(url)
            }
            self.tvInformation?.text = String(self.stringAnswer) + String(self.answerArray.count)
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func btnPre(sender: AnyObject) { //Nút pre để back qua lại giữa câu hỏi và câu trả lời
        if(0 < indexAnswerQuestion) { //Nếu chưa phải là câu đầu tiên thì giảm xuống câu trước
            indexAnswerQuestion -= 1
        } else {
            indexAnswerQuestion = answerArray.count - 1
        }
        let  answer = answerArray[indexAnswerQuestion]
        let question = questionArray[indexAnswerQuestion]
        self.btnAnswer.setTitle(String("\(answer)"), forState: .Normal)
        self.lblQuestion.text = String(question)
    }
    
    @IBAction func btnNext(sender: AnyObject) { //Nút next để back qua lại giữa câu hỏi và câu trả lời
        if(indexAnswerQuestion < (answerArray.count - 1)) { //Nếu chưa phải là câu cuối cùng thì tăng xuống câu trước
            indexAnswerQuestion += 1
        } else {
            indexAnswerQuestion = 0
        }
        let  answer = answerArray[indexAnswerQuestion]
        let question = questionArray[indexAnswerQuestion]
        self.btnAnswer.setTitle(String("\(answer)"), forState: .Normal)
        self.lblQuestion.text = String("Câu \(indexAnswerQuestion + 1) \(question)")
        /*print(answerArray.count)
        print(questionArray.count)*/
    }
    
    @IBAction func btnUpdateData(sender: AnyObject) {
//        do {
//            let document = database.documentWithID((self.txtIdName?.text)!)
//            var properties = document!.properties
//            properties!["answer"] = "Bạn gái Bảo Mập"
//            try document!.putProperties(properties!)
//            print("Sửa xong")
//        } catch let error as NSError {
//            print(error)
//        }
    }
    
    @IBAction func deleteData(sender: AnyObject) {
//        do {
//            let document = database.documentWithID((self.txtIdName?.text)!);
//            try document!.deleteDocument()
//        } catch let error as NSError {
//            print(error)
//        }
    }
    
    // Returns the singleton DemoAppDelegate object.
    var appDelegate : AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    @IBAction func onLogout(sender: UIButton) {
        if User.currentUser != nil {
            TwitterClient.sharedInstance.logout()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
//    func userDidSelectTime(time: Int) {
//        self.timer = time
//        print("You just click on timer \(timer)")
//    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "Timer30" {
//            let selectTimeViewController : selectTimeVC = segue.destinationViewController as! selectTimeVC
//            selectTimeViewController.delegate = self
//            
//        }
//    }
}

