import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ExpertViewModel: ObservableObject {
    @Published var experts: [ExpertModel] = []
    @Published var selectedExpert: ExpertModel? = nil
    @Published var chatMessages: [ChatMessage] = [] // For live chat
    @Published var messages: [ChatMessage] = [] // Legacy/General
    @Published var messageInput: String = ""
    @Published var searchText: String = ""
    @Published var selectedFilter: String = "All"
    @Published var bookingSuccess: Bool = false
    
    private let db = Firestore.firestore()
    private var expertListener: ListenerRegistration?
    private var chatListener: ListenerRegistration?

    init() {
        fetchExperts()
        // seedExperts()
    }

    // ... (filteredExperts and fetchExperts remain)

    func startChat(with expert: ExpertModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let chatId = getChatId(userId: userId, expertId: expert.id.uuidString)
        
        chatListener?.remove()
        chatMessages = []
        
        chatListener = db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening to chat: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.chatMessages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
                print("✅ Received \(self.chatMessages.count) messages for chat \(chatId)")
            }
    }

    func sendChatMessage(expert: ExpertModel, content: String) {
        guard let userId = Auth.auth().currentUser?.uid, !content.isEmpty else { return }
        let chatId = getChatId(userId: userId, expertId: expert.id.uuidString)
        
        let message = ChatMessage(senderId: userId, content: content, isFromUser: true)
        
        do {
            try db.collection("chats").document(chatId).collection("messages").addDocument(from: message)
            
            // Mock expert reply after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let reply = ChatMessage(senderId: expert.id.uuidString, content: "I've received your message. I'll get back to you shortly!", isFromUser: false)
                try? self.db.collection("chats").document(chatId).collection("messages").addDocument(from: reply)
            }
        } catch {
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }

    private func getChatId(userId: String, expertId: String) -> String {
        return "\(userId)_\(expertId)"
    }

    var filteredExperts: [ExpertModel] {
        var base = experts
        if selectedFilter != "All" {
            base = base.filter { $0.tags.contains(selectedFilter) }
        }
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.specialty.localizedCaseInsensitiveContains(searchText) || $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) }
    }

    func fetchExperts() {
        expertListener?.remove()
        expertListener = db.collection("experts").addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ Error fetching experts: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.experts = documents.compactMap { try? $0.data(as: ExpertModel.self) }
        }
    }

    func bookSession(expert: ExpertModel, date: Date, timeSlot: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let booking = ExpertBookingModel(
            expertId: expert.id.uuidString,
            expertName: expert.name,
            userId: userId,
            date: date,
            timeSlot: timeSlot
        )
        
        do {
            try db.collection("bookings").document(booking.id).setData(from: booking)
            self.bookingSuccess = true
            print("✅ Session booked successfully!")
        } catch {
            print("❌ Error booking session: \(error.localizedDescription)")
        }
    }

    func seedExperts() {
        for expert in ExpertModel.samples {
            do {
                try db.collection("experts").document(expert.id.uuidString).setData(from: expert)
                print("📤 Uploaded expert: \(expert.name)")
            } catch {
                print("❌ Error seeding expert: \(error)")
            }
        }
    }

    func sendMessage() {
        guard !messageInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let msg = ChatMessage(senderId: "user", content: messageInput, isFromUser: true)
        messages.append(msg)
        messageInput = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let reply = ChatMessage(senderId: "expert", content: "Thanks for your message! I'll review your plant's symptoms and get back to you shortly.", isFromUser: false)
            self.messages.append(reply)
        }
    }
}
