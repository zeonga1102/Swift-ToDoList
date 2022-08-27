//
//  TodoDetailViewController.swift
//  1771200-termProject
//
//  Created by mac027 on 2021/05/28.
//

import UIKit

class TodoDetailViewController: UIViewController {

    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var datePickerView: UIDatePicker!
    
    var todo: ToDo?
    
}

extension TodoDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todo = todo ?? ToDo()
        todoTextField.text = todo!.todo
        
        let dateStr = todo!.time
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let datetime = formatter.date(from: dateStr)
        if let unwrappedDate = datetime {
            datePickerView.setDate(unwrappedDate, animated: true)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

extension TodoDetailViewController {
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension TodoDetailViewController {
    @IBAction func doneButton(_ sender: UIButton) {
        if let todo = todo {
            if todoTextField.text?.isEmpty == true {
                return
            }

            todo.todo = todoTextField.text!

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"

            todo.time = formatter.string(from: datePickerView.date)
        }
    }
}
