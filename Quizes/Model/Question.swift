//
//  Question.swift
//  Quizes
//
//  Created by Minura Iddamalgoda on 14/11/18.
//  Copyright © 2018 Minura Iddamalgoda. All rights reserved.
//

import Foundation
import UIKit

class Question : Questions {
    var headerImage: UIImage
    
    init(newImage headerImage: UIImage) {
        self.headerImage = headerImage
        super.init()
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
