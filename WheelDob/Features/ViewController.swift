//
//  ViewController.swift
//  WheelDob
//
//  Created by Hareram on 04/10/26.
//

import UIKit

class ViewController: UIViewController {

    //MARK: -------------VARIABLE
    var selectedDate:String?
    private let dobPicker = WheelCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wheelDobSetup()
    }

    func wheelDobSetup(){
        
        dobPicker.frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 600)
        dobPicker.delegate = self
        dobPicker.backgroundColor = UIColor.clear
        self.view.addSubview(dobPicker)
        
    }

}

extension ViewController: SelectedDateDelegate{
   
    func selectAge(age: String?) {
        print("age is = ", age ?? "")
    }
    
    func selectDate(date: (year: String?, month: String?, day: String?)?) {
        selectedDate = nil
        guard let date = date else { return }
        print("selected date is = ", date)
        selectedDate = "\(date.year ?? "")-\(date.month ?? "")-\(date.day ?? "")"
    }
    
    
}
