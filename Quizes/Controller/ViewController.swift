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
    @IBOutlet weak var uiStackView: UIStackView!
    
    // MARK: Data structs
    var questionsList = [Questions]()
    var imageList = [String: UIImage]()
    
    // MARK: AWS DDB Instance vars
    var ddbObjMapper = AWSDynamoDBObjectMapper.default()
    
    // MARK: - View IBActions
    @IBAction func onTruePressed(_ sender: UIButton) {
//        updateAllFromDDB()
        updateUI(question: questionsList[0])
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up remaining UI elements programatically
        questionTextField.layer.cornerRadius = 5
        
        uiStackView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.70
        view.insertSubview(blurEffectView, belowSubview: uiStackView)
        
        createDummyQuestion()
    }
    
    // Gets the header image given a url and adds it to the QuestionList
    // array and returns true if successful
    func getHeaderImage(urlStr: String, questions: Questions) -> Bool {
        if urlStr == "nil" {
            return false
        }
        
        if let url = URL(string: urlStr) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Can force unwrap questions._qID as the urlStr above is not  nil
                        // Can force unwrap UIImage here as "error" image is saved locally with app
                        self.imageList[questions._qId!] = UIImage(data: data) ?? UIImage(named: "error")!
                    }
                }
            }
        }
        
        return true
    }

    func updateUI(question: Questions) {
        // No need to check if image downloaded here as it's performed
        // in getHeaderImage()
        self.questionTextField.text = question._qText
        self.headerImageView.contentMode = .scaleAspectFill
        
        self.headerImageView.image = imageList[question._qId!]
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
        
        for questions in questionsList {
            if !(getHeaderImage(urlStr: questions._qImage ?? "nil", questions: questions)) {
                print("Error in downloading image \(String(describing: questions._qImage))")
            }
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
        question._qAnswer = false
        question._qId = UUID().uuidString
        question._qImage = "https://images.unsplash.com/photo-1532581291347-9c39cf10a73c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=60c3b92d51f407ac2d0a8a42417053df&auto=format&fit=crop&w=1650&q=80"
        question._qText = "Is the capital of Alaska named Fairbanks?"

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

