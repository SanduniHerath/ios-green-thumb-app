import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var profileVM:   ProfileViewModel
    @EnvironmentObject var authVM:      AuthViewModel
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var router:      AppRouter
    @State private var showSettings = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
               
                VStack(alignment: .leading, spacing: GTSpacing.md) {
                   //navigation
                    HStack {
                        Button { router.selectedTab = 0 } label: {
                            Image(systemName: "arrow.left")
                                .circleButton()
                        }
                        Spacer()
                        if selectedTab == 0 {
                            Button { showSettings = true } label: {
                                Image(systemName: "gearshape")
                                    .circleButton()
                            }
                        }
                    }
                    .padding(.horizontal, GTSpacing.lg)
                    .padding(.top, 54)

                   //dynamic title
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedTab == 0 ? "User Profile" : "Community\nFeed")
                            .font(GTFont.displayLarge())
                            .foregroundColor(.white)
                            .lineSpacing(-8)
                    }
                    .padding(.horizontal, 105)
                    .padding(.bottom, selectedTab == 0 ? 0 : 20)

                    if selectedTab == 0 {
                        //profile info
                        VStack(spacing: GTSpacing.sm) {
                            GTAvatar(name: profileVM.profile.name, size: 100)
                            
                            VStack(spacing: 2) {
                                Text(profileVM.profile.name)
                                    .font(GTFont.displaySmall())
                                    .foregroundColor(.white)
                                
                                Text("\(profileVM.profile.handle) - Member since \(profileVM.profile.memberSince)")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.gtLightGreen.opacity(0.8))
                            }
                            
                            GTBadgeComponent(text: profileVM.profile.userType)
                        }
                        .padding(.horizontal, 80)
                        
                        //stats row
                        HStack {
                            GTStatItem(value: "\(profileVM.profile.plantCount)", label: "Plants tracked")
                            GTStatItem(value: "\(profileVM.profile.streakDays)", label: "Day streak")
                            GTStatItem(value: "\(profileVM.profile.sessionsCount)", label: "Sessions")
                            GTStatItem(value: "\(profileVM.profile.logEntriesCount)", label: "Log entries")
                        }
                        .padding(.vertical, GTSpacing.md)
                        .padding(.horizontal, GTSpacing.md)
                    }
                }
                .padding(.bottom, GTSpacing.lg)
                .background(Color.gtForestGreen)
                
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        //tab switcher
                        GTSegmentedControl(options: ["My profile", "Community"], selectedIndex: $selectedTab)
                            .padding(.horizontal, GTSpacing.xxl)
                            .padding(.vertical, GTSpacing.lg)
                        
                        //content body
                        VStack(spacing: GTSpacing.lg) {
                            if selectedTab == 0 {
                                myProfileContent
                            } else {
                                communityContent
                            }
                        }
                        .padding(.horizontal, GTSpacing.lg)
                        .padding(.bottom, GTSpacing.xxxl)
                    }
                }
                .background(Color.gtBackground)
            }
            .background(Color.gtForestGreen)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(isPresented: $showSettings) { AppSettingsView() }
        }
    }
    
    private var myProfileContent: some View {
        VStack(spacing: GTSpacing.lg) {
            //sterak alert card
            GTStreakAlertCard(streak: profileVM.profile.streakDays, best: profileVM.profile.streakDays + 5)
            
            //my plant section
            VStack(alignment: .leading, spacing: GTSpacing.md) {
                Text("My plants")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                if profileVM.recentPlants.isEmpty {
                    Text("No plants tracked yet. Start adding some!")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                        .padding(.vertical, GTSpacing.md)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: GTSpacing.md) {
                            ForEach(profileVM.recentPlants) { plant in
                                Button {
                                    router.navigate(to: .plantDetails(plant))
                                } label: {
                                    GTPlantCompactCard(
                                        name: plant.name,
                                        health: Int.random(in: 70...95),
                                        icon: "🪴",
                                        imageURL: plant.imageURL,
                                        borderColor: .gtDarkGreen
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
            
            //recent session section
            VStack(alignment: .leading, spacing: GTSpacing.md) {
                Text("Recent expert sessions")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                if profileVM.recentSessions.isEmpty {
                    Text("No sessions booked yet.")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                        .padding(.vertical, GTSpacing.md)
                } else {
                    VStack(spacing: 0) {
                        ForEach(profileVM.recentSessions.prefix(3)) { session in
                            GTSessionHistoryRow(
                                expert: session.expertName,
                                topic: "Garden Consultation",
                                detail: "Session on \(session.timeSlot)",
                                rating: 5,
                                date: session.date.formatted(date: .abbreviated, time: .omitted),
                                initials: String(session.expertName.prefix(1)),
                                color: Color.gtBadgePurpleText
                            )
                            if session.id != profileVM.recentSessions.prefix(3).last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            
            //sign out
            Button { authVM.signOut() } label: {
                HStack {
                    Image(systemName: "arrow.right.to.line")
                    Text("Sign out")
                }
                .font(GTFont.labelMedium())
                .foregroundColor(.gtStatusUrgent)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.gtStatusUrgent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: GTRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: GTRadius.md)
                        .stroke(Color.gtStatusUrgent.opacity(0.3), lineWidth: 1.5)
                )
            }
            .padding(.top, GTSpacing.md)
        }
    }
    
    private var communityContent: some View {
        VStack(spacing: GTSpacing.lg) {
            //category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GTSpacing.sm) {
                    ForEach(["All", "Disease tips", "Soil"], id: \.self) { category in
                        Button { communityVM.selectedCategory = category } label: {
                            Text(category)
                                .font(GTFont.labelMedium())
                                .foregroundColor(communityVM.selectedCategory == category ? .white : .gtTextSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(communityVM.selectedCategory == category ? Color.gtDarkGreen : Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.gtBorder, lineWidth: communityVM.selectedCategory == category ? 0 : 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .padding(.top, GTSpacing.xs)
            
            //feed
            VStack(spacing: GTSpacing.lg) {
                ForEach(communityVM.filteredPosts) { post in
                    GTCommunityPostCard(post: post)
                }
            }
        }
    }
}

extension View {
    func circleButton() -> some View {
        self.font(.system(size: 16, weight: .bold))
            .foregroundColor(.gtTextPrimary)
            .frame(width: 40, height: 40)
            .background(Color.white)
            .clipShape(Circle())
            .gtShadow(GTShadow.card)
    }
}


#Preview { UserProfileView()
    .environmentObject(ProfileViewModel()).environmentObject(AuthViewModel()).environmentObject(AppRouter())
    .environmentObject(PlantViewModel()).environmentObject(DiagnoseViewModel())
    .environmentObject(SchedulerViewModel()).environmentObject(ExpertViewModel())
    .environmentObject(CommunityViewModel()).environmentObject(NotificationsViewModel()) }
