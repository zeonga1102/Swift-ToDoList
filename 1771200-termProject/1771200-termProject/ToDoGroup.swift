//
//  ToDoGroup.swift
//  1771200-termProject
//
//  Created by mac027 on 2021/05/27.
//

import Foundation

class ToDoGroup: NSObject {
    var todos = [ToDo]()
    
    override init() {
        super.init()
    }
    
    func testData() {
        for _ in 0...10 {
            todos.append(ToDo(random: true))
        }
    }
    
    func count() -> Int { return todos.count }
    func addTodo(todo: ToDo) { todos.append(todo) }
    func modifyTodo(todo: ToDo, index: Int) { todos[index] = todo }
    func removeTodo(index: Int) { todos.remove(at: index) }
}
