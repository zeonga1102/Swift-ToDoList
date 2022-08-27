//
//  ViewController.swift
//  1771200-termProject
//
//  Created by mac027 on 2021/05/24.
//

import UIKit

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    
    var todoGroup: ToDoGroup!
    var doneTodos: Array<ToDo> = [] //Done으로 완료한 데이터를 이동시키기 위한 배열
    var todoClonee: ToDo?
}

extension ToDoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sceneDelegate = (UIApplication.shared.connectedScenes.first as? UIWindowScene)!.delegate as? SceneDelegate {
            todoGroup = sceneDelegate.todoGroup
        }
        
        todoTableView.dataSource = self
        todoTableView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longPressGesture)
        
    }
}

extension ToDoViewController {
    @objc func longPress(sender: UILongPressGestureRecognizer) {    //셀을 길게 눌렀을 때 실행되는 제스처
        let touchPoint = sender.location(in: self.todoTableView)
        if let indexPath = todoTableView.indexPathForRow(at: touchPoint) {
            
            let alert = UIAlertController(title: "Are you done?", message: "\(self.todoGroup.todos[indexPath.row].todo)", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {_ in  //Yes를 선택하면 선택한 셀이 삭제되고 Done의 테이블로 이동
                self.doneTodos.append(self.todoGroup.todos[indexPath.row])  //Done으로 데이터를 이동시키기 위해 배열에 append
                self.todoGroup.removeTodo(index: indexPath.row)
                self.todoTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ToDoViewController {
    override func viewWillAppear(_ animated: Bool) {
        let parent = self.parent?.parent as! UITabBarController
        let child = parent.viewControllers![1] as! UINavigationController
        let doneViewController = child.viewControllers[0] as! DoneViewController
        let restores = doneViewController.getRestoreTodos() //Done에서 데이터 가져오기
        
        if !restores.isEmpty {  //Done에서 가져온 데이터가 있으면 insert
            for restore in restores {
                todoGroup.addTodo(todo: restore)
                let indexPath = IndexPath(row: todoGroup.count() - 1, section: 0)
                todoTableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension ToDoViewController {
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = todoTableView.indexPathForSelectedRow {
            if let clonee = todoClonee {
                if clonee.isEqual(todo: todoGroup.todos[indexPath.row]) == false {  //데이터가 수정된 경우
                    todoGroup.modifyTodo(todo: clonee, index: indexPath.row)
                    todoTableView.reloadRows(at: [indexPath], with: .automatic)
                }
                todoTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        else if let clonee = todoClonee {
            if !clonee.todo.isEmpty {
                //셀에 새로운 데이터를 추가
                todoGroup.addTodo(todo: clonee)
                let indexPath = IndexPath(row: todoGroup.count() - 1, section: 0)
                todoTableView.insertRows(at: [indexPath], with: .automatic)
                todoTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        
        if todoGroup.count() < 1 { return }
        
        for i in 0...todoGroup.count() - 1 {    //셀마다 색 설정
            let indexPath = IndexPath(row: i, section: 0)
            todoGroup.todos[i].setColor()
            let color = todoGroup.todos[i].color
            
            if color == "gray" {
                todoTableView.cellForRow(at: indexPath)?.backgroundColor = .gray
            }
            else if color == "red" {
                todoTableView.cellForRow(at: indexPath)?.backgroundColor = .red
            }
            else {
                todoTableView.cellForRow(at: indexPath)?.backgroundColor = .white
            }
        }
        todoClonee = nil
    }
}

extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoGroup.count()
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoTableViewCell")!
        
        let todo = todoGroup.todos[indexPath.row]
        cell.textLabel!.text = todo.todo
        cell.detailTextLabel!.text = todo.time
        
        todo.setColor()
        let color = todo.color

        if color == "gray" {    //셀에 색 지정
            cell.backgroundColor = .gray
        }
        else if color == "red" {
            cell.backgroundColor = .red
        }
        else {
            cell.backgroundColor = .white
        }

        return cell
    }
}


extension ToDoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    //셀 삭제
            let title = "Delete \(todoGroup.todos[indexPath.row].todo)"
            let alert = UIAlertController(title: title, message: "Are you sure you want to delete this?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {_ in    //delete 선택하면 삭제
                self.todoGroup.removeTodo(index: indexPath.row)
                self.todoTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {    //셀 순서 변경
        let from = todoGroup.todos[sourceIndexPath.row]

        if sourceIndexPath.row < destinationIndexPath.row { //셀을 아래로 내릴 때
            var nextTodo = todoGroup.todos[sourceIndexPath.row + 1]
            for i in sourceIndexPath.row..<destinationIndexPath.row {
                let todo = nextTodo
                nextTodo = todoGroup.todos[i+1]
                todoGroup.modifyTodo(todo: todo, index: i)
            }
        }
        else {  //위로 올릴 때
            var nextTodo = todoGroup.todos[destinationIndexPath.row]
            for i in destinationIndexPath.row..<sourceIndexPath.row {
                let todo = nextTodo
                nextTodo = todoGroup.todos[i+1]
                todoGroup.modifyTodo(todo: todo, index: i + 1)
            }
        }
        
        todoGroup.modifyTodo(todo: from, index: destinationIndexPath.row)
        todoTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}

extension ToDoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let todoDetailViewController = segue.destination as! TodoDetailViewController
        if segue.identifier == "ShowTodo" {
            if let row = todoTableView.indexPathForSelectedRow?.row {
                todoClonee = todoGroup.todos[row].clone()
                todoDetailViewController.todo = todoClonee
            }
        }
        else if segue.identifier == "MakeTodo" {
            todoClonee = ToDo()
            todoDetailViewController.todo = todoClonee
            if let indexPath = todoTableView.indexPathForSelectedRow {
                todoTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}


extension ToDoViewController {
    @IBAction func editingTable(_ sender: UIBarButtonItem) {
        if todoTableView.isEditing == true {
            todoTableView.isEditing = false
            sender.title = "Edit"
        } else {
            todoTableView.isEditing = true
            sender.title = "Done"
        }
    }
}

extension ToDoViewController {
    @IBAction func unwind2ToDoView (_ unwindSegue: UIStoryboardSegue) {
        //TodoDetailViewController에서 Done 버튼 눌렀을 때 돌아오기 위한 함수
    }
}

extension ToDoViewController {
    func getDoneTodos() -> Array<ToDo> {  //완료했다고 한 데이터들을 전달하기 위한 함수
        let tmp = doneTodos
        doneTodos = []
        return tmp
    }
}
