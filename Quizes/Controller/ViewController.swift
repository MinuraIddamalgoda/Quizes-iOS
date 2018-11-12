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

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //createQuestion()
    }

    func updateUI(question: Questions) {
        
    }
    
    func updateFromDDB() {
        
    }
    
    func createQuestion() {
        let dynamoDbObjMapper = AWSDynamoDBObjectMapper.default()
        
        // Creating a new question
        let question: Questions = Questions()
        question._userId = AWSIdentityManager.default().identityId
        question._qDateAdded = NSNumber(value: Int(Date().timeIntervalSince1970))
        question._qAnswer = true
        question._qId = UUID().uuidString
        // Why does casting a date to an int need to be this difficult????
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

