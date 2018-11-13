//
//  ViewController.swift
//  Quizes
//
//  Created by Minura Iddamalgoda on 12/11/18.
//  Copyright © 2018 Minura Iddamalgoda. All rights reserved.
//

import UIKit

import AWSCore
import AWSMobileClient
import AWSDynamoDB

class ViewController: UIViewController {
    
    // MARK: View IBOutlets
    @IBOutlet weak var questionTextField: UITextView!
    @IBOutlet weak var headerImageView: UIImageView!
    
    // MARK: View IBActions
    @IBAction func onTruePressed(_ sender: UIButton) {
        updateAllFromDDB()
    }
    
    // MARK: Data structs
    var questionList = [Question]()
    var questionsList = [Questions]()
    
    // MARK: AWSDDB Instance vars
    var ddbObjMapper = AWSDynamoDBObjectMapper.default()

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateAllFromDDB()
    }
    
    // Gets the header image given a url and adds it to the QuestionList
    // array and returns true if successful
    func getHeaderImage(urlStr _: String) -> Bool {
        return true
    }

    func updateUI(question: Question) {
        // No need to check if image downloaded here as it's performed
        // in getHeaderImage()
        self.questionTextField.text = question._qText
        self.headerImageView.image = question.headerImage
    }
    
    func updateAllFromDDB() {
        var activityIndicator = UIActivityIndicatorView()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator.style = .gray
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = UIColor.white
        
        // Perform get all
        let scanExpr = AWSDynamoDBScanExpression()
        // Limiting the number of items returned so I don't go over quota
        scanExpr.limit = 10
        
        ddbObjMapper.scan(Questions.self, expression: scanExpr).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("Unable to update from DDB: \(error)")
            } else if let paginatedOutput = task.result {
                for questions in paginatedOutput.items as! [Questions] {
                    self.questionsList.append(questions)
                }
            }
            return()
        })
        
        for question in questionsList {
            print("Item ID: \(String(describing: question._qId))")
        }
        
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    func createDummyQuestion() {
        let dynamoDbObjMapper = AWSDynamoDBObjectMapper.default()
        
        // Creating a new question
        let question: Questions = Questions()
        question._userId = AWSIdentityManager.default().identityId
        // Why does casting a date to an int need to be this difficult????
        question._qDateAdded = NSNumber(value: Int(Date().timeIntervalSince1970))
        question._qAnswer = true
        question._qId = UUID().uuidString
        question._qImage = "https://images.unsplash.com/photo-1504670732632-321700b02c35?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=c7d1984f6730d5756bfcd2f76f52c9cd&auto=format&fit=crop&w=634&q=80"
        question._qText = "Is this a cool app?"

        // Saving the question
        dynamoDbObjMapper.save(question) {
            (error: Error?) -> Void in
            
            if let error = error {
                print("AWS DDB Save Error: \(error))")
                return
            }
            print("Item \(String(describing: question._qId)) was saved")
        }
    }
}

