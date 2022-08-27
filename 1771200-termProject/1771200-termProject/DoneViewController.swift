//
//  DoneViewController.swift
//  1771200-termProject
//
//  Created by mac027 on 2021/05/28.
//

import UIKit

class DoneViewController: UIViewController {

    @IBOutlet weak var doneTableView: UITableView!
    
    var doneGroup: ToDoGroup!
    var restoreTodos: Array<ToDo> = []
    
}

extension DoneViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneGroup = ToDoGroup()
        
        doneTableView.dataSource = self
        doneTableView.delegate = self
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(tapGesture)
    }
}

extension DoneViewController {
    @objc func longPress(sender: UILongPressGestureRecognizer) {    //셀을 길게 눌렀을 때 실행되는 제스처
        let touchPoint = sender.location(in: self.doneTableView)
        
        if let indexPath = doneTableView.indexPathForRow(at: touchPoint) {
            doneTableView.cellForRow(at: indexPath)?.backgroundColor = .lightGray
            let title = "Restore \(self.doneGroup.todos[indexPath.row].todo)"
            let alert = UIAlertController(title: title, message: "Do you want to restore this?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Restore", style: .default) {_ in  //Restore 선택하면 선택한 셀이 삭제되고 ToDo의 테이블로 이동
                self.restoreTodos.append(self.doneGroup.todos[indexPath.row])  //ToDo로 데이터를 이동시키기 위해 배열에 append
                self.doneGroup.removeTodo(index: indexPath.row)
                self.doneTableView.deleteRows(at: [indexPath], with: .automatic)
                self.doneTableView.cellForRow(at: indexPath)?.backgroundColor = .white
            }
            let noAction = UIAlertAction(title: "Cancel", style: .default) {_ in
                self.doneTableView.cellForRow(at: indexPath)?.backgroundColor = .white
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension DoneViewController {
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = doneTableView.indexPathForSelectedRow {
            doneTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let parent = self.parent?.parent as! UITabBarController
        let child = parent.viewControllers![0] as! UINavigationController
        let todoViewController = child.viewControllers[0] as! ToDoViewController
        let dones = todoViewController.getDoneTodos()
        
        if !dones.isEmpty { //ToDo에서 가져온 데이터가 있으면 insert
            for done in dones {
                doneGroup.addTodo(todo: done)
                let indexPath = IndexPath(row: doneGroup.count() - 1, section: 0)
                doneTableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension DoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneGroup.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doneTableViewCell")!
        
        let done = doneGroup.todos[indexPath.row]
        cell.textLabel!.text = done.todo
        cell.detailTextLabel!.text = done.time
        
        return cell
    }
}

extension DoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let title = "Delete \(doneGroup.todos[indexPath.row].todo)"
            let alert = UIAlertController(title: title, message: "Are you sure you want to delete this?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {_ in    //Delete 선택하면 셀 삭제
                self.doneGroup.removeTodo(index: indexPath.row)
                self.doneTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension DoneViewController {
    @IBAction func editingTable(_ sender: UIBarButtonItem) {
        if doneTableView.isEditing == true {
            doneTableView.isEditing = false
            sender.title = "Delete"
        } else {
            doneTableView.isEditing = true
            sender.title = "Done"
        }
    }
}

extension DoneViewController {
    func getRestoreTodos() -> Array<ToDo> {  //복구한다고 한 데이터들을 전달하기 위한 함수
        let tmp = restoreTodos
        restoreTodos = []
        return tmp
    }
}
