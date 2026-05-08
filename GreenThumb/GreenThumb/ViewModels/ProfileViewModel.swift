import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile = UserProfile()
    @Published var recentPlants: [PlantModel] = []
    @Published var recentSessions: [ExpertBookingModel] = []
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    init() {
        setupListeners()
    }

    func setupListeners() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //listen to user document
        let profileListener = db.collection("users").document(uid).addSnapshotListener { snapshot, _ in
            if let snapshot = snapshot, snapshot.exists {
                var updated = self.profile
                updated.name = snapshot.data()?["name"] as? String ?? updated.name
                updated.email = Auth.auth().currentUser?.email
                self.profile = updated
            }
        }
        
        //Listen to plants
        let plantsListener = db.collection("users").document(uid).collection("plants")
            .order(by: "dateAdded", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.recentPlants = docs.prefix(5).compactMap { try? $0.data(as: PlantModel.self) }
                self.profile.plantCount = docs.count
                self.profile.gardenCount = 1
            }
            
        //listen to expert sessions
        let sessionsListener = db.collection("bookings").whereField("userId", isEqualTo: uid)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.recentSessions = docs.compactMap { try? $0.data(as: ExpertBookingModel.self) }
                    .sorted(by: { $0.date > $1.date })
                self.profile.sessionsCount = docs.count
            }
            
        //listen to completed tasks
        let tasksListener = db.collection("scheduler_tasks")
            .whereField("userId", isEqualTo: uid)
            .whereField("isCompleted", isEqualTo: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.profile.logEntriesCount = docs.count
                
                let completedDates = docs.compactMap { ($0.data()["dueDate"] as? Timestamp)?.dateValue() }
                self.profile.streakDays = self.calculateStreak(from: completedDates)
            }

        listeners = [profileListener, plantsListener, sessionsListener, tasksListener]
    }

    private func calculateStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) })
        let sortedDays = uniqueDays.sorted(by: >) // Most recent first
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        //check today or yesterday as a starting point
        if !uniqueDays.contains(currentDate) {
            //if nothing done today, check if streak ended yesterday
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate),
                  uniqueDays.contains(yesterday) else {
                return 0 //streak broken
            }
            currentDate = yesterday
        }
        
        //count backwards
        while uniqueDays.contains(currentDate) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDate
        }
        
        return streak
    }

    func updateName(_ name: String) {
        profile.name = name
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
}
