//
//  ContentView.swift
//  DailyTask
//
//  Created by Gurjit Singh on 19/03/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var newTask = ""
    @State var showingEmptyNameAlert = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Tasks.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Tasks.displayOrder, ascending: false)]) var tasks: FetchedResults<Tasks>
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("New Task")) {
                    HStack {
                        TextField("Name", text: $newTask)
                        Button(action: {
                            if (self.newTask.isEmpty) {
                                self.showingEmptyNameAlert.toggle()
                            } else {
                                let getDate = getCurrentDate()
                                let formatter = DateFormatter()
                                formatter.dateFormat = "d MMM y"
                                let changedDate = formatter.date(from: getDate)
                                let taskContext = Tasks(context: self.moc)
                                taskContext.id = UUID()
                                taskContext.title = "\(self.newTask)"
                                taskContext.displayOrder = Int16(self.tasks.endIndex)
                                taskContext.date = changedDate
                                taskContext.status = false
                                try? self.moc.save()
                                self.newTask = ""
                            }
                        }){
                            Image(systemName: "plus.circle.fill").foregroundColor(Color.orange).imageScale(.large)
                            } .alert(isPresented: $showingEmptyNameAlert) {
                                Alert(title: Text("Alert"), message: Text("Please enter new task name."), dismissButton: .default(Text("OK")))
                            }
                    }
                }
                Section(header: Text("Your Tasks")) {
                    ForEach(tasks, id: \.self) { task in
                        
                            HStack {
                            Button(action: {
                                var changeStatus: Bool
                                if task.status == true {
                                    changeStatus = false
                                } else {
                                    changeStatus = true
                                }
                                updateData(taskId: task.id!, astatus: changeStatus)
                            }) {
                                
                                if(task.status == true) {
                                    HStack{
                                    Image(systemName: "checkmark.circle.fill").imageScale(.large).font(.headline)
                                    Text("\(task.title!) \(String(task.status))").font(.headline).strikethrough()
                                    }
                                } else {
                                    HStack{
                                    Image(systemName: "circle").imageScale(.large).font(.headline)
                                    Text("\(task.title!)").font(.headline)
                                    }
                                }
                                
                            }
                                
                                Spacer()
                                Text(" "+changeDateToString(adate: task.date!)).font(.subheadline)
                            }
                        
                    }
                    //Delete item function
                        .onDelete{ (indexSet) in
                            for offset in indexSet {
                                let task = self.tasks[offset]
                                self.moc.delete(task)
                            }
                            try? self.moc.save()
                    }
                    
                    }
            }.navigationBarItems(trailing: EditButton().foregroundColor(Color.orange))
            .navigationBarTitle("Tasks")
        }
    }
}

func getCurrentDate() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    let date = formatter.string(from: today)
    return date
}

func changeDateToString(adate: Date) -> String {
        let adate =  adate
        //let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        let result = formatter.string(from: adate)
        return result
}

func checkStatus() {
    
}

func updateData(taskId: UUID, astatus: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Tasks")
    fetchRequest.predicate = NSPredicate(format: "id = %@", "\(taskId)")
    do {
        let test = try managedContext.fetch(fetchRequest)
        let objectUpdate = test[0] as! NSManagedObject
        objectUpdate.setValue(astatus, forKey: "status")
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    } catch {
        print(error)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
