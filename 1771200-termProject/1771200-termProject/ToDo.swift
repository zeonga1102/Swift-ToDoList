//
//  ToDo.swift
//  1771200-termProject
//
//  Created by mac027 on 2021/05/27.
//

import Foundation

class ToDo: NSObject {
    var todo: String    //할 일 저장
    var time: String    //마감 시간 저장
    var color: String?  //마감 시간과 현재 시간을 계산해서 해당하는 색 저장
    
    init(todo: String, time: String) {
        self.todo = todo
        self.time = time
        
        super.init()
    }
}

extension ToDo {
    convenience init(random: Bool = false) {
        if random == false {
            self.init(todo:"", time:"")
            return
        }
        
        let todos = ["iOS Programming", "Information Security", "Compiler"]
        let times = ["2021-05-29 23:00", "2021-06-14 13:00", "2021-05-30 09:30"]
        
        var index = Int(arc4random_uniform(UInt32(todos.count)))
        let todo = todos[index]
        
        index = Int(arc4random_uniform(UInt32(times.count)))
        let time = times[index]
        
        self.init(todo: todo, time: time)
    }
}

extension ToDo {
    func clone() -> ToDo {
        let todo = ToDo()
        todo.todo = self.todo
        todo.time = self.time
        return todo
    }
}

extension ToDo {
    func isEqual(todo: ToDo) -> Bool {
        if todo.todo != self.todo { return false }
        else if todo.time != self.time { return false }
        
        return true
    }
}

extension ToDo {
    func setColor() {   //마감 시간과 현재 시간을 계산해서 색을 지정해주는 함수
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        
        let nowTime = Date()
        let time = format.date(from: self.time)
        let timeRemaining = Float(time!.timeIntervalSince(nowTime)) / 3600  //남은 시간
                
        if timeRemaining <= 0 { //마감 시간이 지났을 때
            self.color = "gray"
        }
        else if timeRemaining <= 24 {   //마감 시간이 24시간 남았을 때
            self.color = "red"
        }
        else {  //마감 시간이 24시간 이상 남았을 때
            self.color = "white"
        }
    }
}
