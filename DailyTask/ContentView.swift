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
    
    //create variable for new task
    @State var newTask = ""
    //create variable to handle new task alert
    @State var showingEmptyNameAlert = false
    @Environment(\.managedObjectContext) var moc
    //fetch record from database
    @FetchRequest(entity: Tasks.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Tasks.displayOrder, ascending: false)]) var tasks: FetchedResults<Tasks>
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("New Task")) {
                    HStack {
                        //textField for new task
                        TextField("Name", text: $newTask)
                        //add button to add new task
                        Button(action: {
                            if (self.newTask.isEmpty) {
                                //show alert if
                                self.showingEmptyNameAlert.toggle()
                            } else {
                                //get current date
                                let getDate = getCurrentDate()
                                let formatter = DateFormatter()
                                formatter.dateFormat = "d MMM y"
                                //change string to date
                                let changedDate = formatter.date(from: getDate)
                                //insert values into database
                                let taskContext = Tasks(context: self.moc)
                                taskContext.id = UUID()
                                taskContext.title = "\(self.newTask)"
                                taskContext.displayOrder = Int16(self.tasks.endIndex)
                                taskContext.date = changedDate
                                taskContext.status = false
                                try? self.moc.save()
                                //set new task textfield to empty
                                self.newTask = ""
                            }
                        }){
                            Image(systemName: "plus.circle.fill").foregroundColor(Color.orange).imageScale(.large)
                            } .alert(isPresented: $showingEmptyNameAlert) {
                                //display alert if new task is empty
                                Alert(title: Text("Alert"), message: Text("Please enter new task name."), dismissButton: .default(Text("OK")))
                            }
                    }
                }
                Section(header: Text("Your Tasks")) {
                    ForEach(tasks, id: \.self) { task in
                        //display fetched record in list view
                            HStack {
                            Button(action: {
                                //check if task is completed or not
                                var changeStatus: Bool
                                if task.status == true {
                                    //change bool value if completed task button clicked
                                    changeStatus = false
                                } else {
                                    changeStatus = true
                                }
                                //update data if user clicked on task completed button
                                updateData(taskId: task.id!, astatus: changeStatus)
                            }) {
                                //strike task value if completed or display as its
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
                                //convert date to string and display into text view
                                Text(" "+changeDateToString(adate: task.date!)).font(.subheadline)
                            }
                        
                    }
                    //Delete item function
                        .onDelete{ (indexSet) in
                            for offset in indexSet {
                                //delete row from list view
                                let task = self.tasks[offset]
                                self.moc.delete(task)
                            }
                            //save context
                            try? self.moc.save()
                    }
                    
                    }
            }.navigationBarItems(trailing: EditButton().foregroundColor(Color.orange))
            .navigationBarTitle("Tasks")
        }
    }
}

//function to get current date
func getCurrentDate() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    let date = formatter.string(from: today)
    return date
}

//function to change date to string
func changeDateToString(adate: Date) -> String {
        let adate =  adate
        //let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        let result = formatter.string(from: adate)
        return result
}

//update data if user clicked on completed task button
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
