//
//  HelpViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/11/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit

class HelpViewController: ViewController {
    
    @IBOutlet weak var textField: UITextView!
    
    let boldFontAttribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]
    let normalFontAttribute = [NSAttributedString.Key.font : UIFont.init(descriptor: UIFontDescriptor(), size: 20)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help & FAQs"
        configureTextField()
    }
    
    func configureTextField() {
        // change UI as deemed necessary
        textField.isEditable = false
        textField.isScrollEnabled = true
        textField.textAlignment = NSTextAlignment(rawValue: 0)!
        // attributed text
        let attrText : NSMutableAttributedString = NSMutableAttributedString()
        // traverse the questions and answers arrays at the same time
        for index in 0...Questions.QUESTIONS.count-1 {
            // define question
            let question = Questions.QUESTIONS[index]
            // format the question
            let boldedBlue = formatQuestion(question: question, color: UIColor.blue)
            //append to the attributed text string
            attrText.append(boldedBlue)
            // define answer
            let answer = Questions.ANSWERS[index]
            // append answer with regular font
            attrText.append(NSMutableAttributedString(string: answer, attributes: normalFontAttribute))
        }
        textField.attributedText = attrText
    }
    
    func formatQuestion(question : String, color : UIColor) -> NSAttributedString {
        // bold the question
        let boldedBlue = NSMutableAttributedString(string: question, attributes: boldFontAttribute)
        // add the blue attribute
        boldedBlue.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:0,length: question.count))
        return boldedBlue
    }
    
}
