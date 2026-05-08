import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SchedulerViewModel: ObservableObject {
    @Published var tasks: [SchedulerTaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let collectionName = "scheduler_tasks"
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        // fetchTasks() // Only uncomment to fetch all tasks globally
        // seedTasks()  // Only uncomment once to seed
    }

    func seedTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //delete all old tasks
        db.collection(collectionName).whereField("userId", isEqualTo: userId).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { $0.reference.delete() }
            
            //create the fresh new tasks
            self.db.collection("users").document(userId).collection("plants").getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                
                for doc in docs {
                    if let plant = try? doc.data(as: PlantModel.self) {
                        self.generateDefaultTasks(for: plant)
                    }
                }
                print("Clean Sweep Complete! Your database is now tidy.")
            }
        }
    }

    //generate tasks
    func generateDefaultTasks(for plant: PlantModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let taskData: [(TaskType, Date, String)] = [
            (.water,     Date(), "Morning session: 300ml"),
            (.fertilize, Date(), "Use rose-specific liquid feed"),
            (.prune,     Calendar.current.date(byAdding: .day, value: 1, to: Date())!, "Remove spent blooms"),
            (.inspect,   Calendar.current.date(byAdding: .day, value: 2, to: Date())!, "Check for aphids under leaves")
        ]
        
        for (type, date, note) in taskData {
            let taskId = "\(plant.id.uuidString)-\(type.rawValue)"
            let task = SchedulerTaskModel(
                id: taskId,
                userId: userId,
                plantId: plant.id.uuidString,
                plantName: plant.name,
                taskType: type,
                dueDate: date,
                notes: note
            )
            try? db.collection(collectionName).document(task.id).setData(from: task)
        }
        print("Created 4 default tasks for: \(plant.name)")
    }

    func fetchTasks(for plantId: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        listenerRegistration?.remove()
        
        var query = db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
        
        //apply strict plant filter if provided
        if let pid = plantId, !pid.isEmpty {
            query = query.whereField("plantId", isEqualTo: pid)
            print("🔍 Filtering tasks for plant ID: \(pid)")
        } else {
            print("📋 Fetching all tasks for user")
        }
        
        //start the fresh listener
        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Firestore Error: \(error.localizedDescription)")
                return
            }
            
            let fetchedTasks = snapshot?.documents.compactMap { doc in
                try? doc.data(as: SchedulerTaskModel.self)
            } ?? []
            
            //sort by date and time
            self.tasks = fetchedTasks.sorted(by: { $0.dueDate < $1.dueDate })
            print("Successfully fetched \(self.tasks.count) tasks")
        }
    }

    func toggleTask(_ task: SchedulerTaskModel) {
        let docRef = db.collection(collectionName).document(task.id)
        let newStatus = !task.isCompleted
        
        docRef.updateData(["isCompleted": newStatus]) { error in
            if let error = error {
                print("Error updating task: \(error.localizedDescription)")
            } else if newStatus {
                //if marked as completed cancel any future notifications
                NotificationManager.shared.cancelNotification(id: task.id)
            }
        }
    }
    
    func addTask(plantId: String, plantName: String, type: TaskType, dueDate: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newTask = SchedulerTaskModel(
            userId: userId,
            plantId: plantId,
            plantName: plantName,
            taskType: type,
            dueDate: dueDate
        )
        
        do {
            try db.collection(collectionName).document(newTask.id).setData(from: newTask)
            
            //schedule the notifications
            NotificationManager.shared.scheduleCalendarNotification(
                id: newTask.id,
                title: "\(type.rawValue) Reminder \(type.icon)",
                body: "It's time to \(type.rawValue.lowercased()) your \(plantName)!",
                date: dueDate
            )
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }

    var pendingTasks: [SchedulerTaskModel] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [SchedulerTaskModel] { tasks.filter { $0.isCompleted } }
    
    func tasks(for date: Date) -> [SchedulerTaskModel] {
        let dayTasks = tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        var uniqueTasks: [SchedulerTaskModel] = []
        var seenKeys: Set<String> = []
        
        for task in dayTasks {
            let key = "\(task.plantId)-\(task.taskType.rawValue)"
            if !seenKeys.contains(key) {
                uniqueTasks.append(task)
                seenKeys.insert(key)
            }
        }
        
        return uniqueTasks
    }
}

