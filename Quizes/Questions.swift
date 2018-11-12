//
//  Questions.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class Questions: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _qDateAdded: NSNumber?
    var _qAnswer: NSNumber?
    var _qId: String?
    var _qImage: String?
    var _qText: String?
    
    class func dynamoDBTableName() -> String {

        return "quizesios-mobilehub-70694695-Questions"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_qDateAdded"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_qDateAdded" : "qDateAdded",
               "_qAnswer" : "qAnswer",
               "_qId" : "qId",
               "_qImage" : "qImage",
               "_qText" : "qText",
        ]
    }
}