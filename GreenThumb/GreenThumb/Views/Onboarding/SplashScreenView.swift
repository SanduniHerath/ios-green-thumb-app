import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var router: AppRouter
    @State private var opacity: Double = 0
    @State private var scale: Double   = 0.85
    @State private var navigateNext    = false

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                //background
                Color.gtForestGreen
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    
                    VStack(spacing: GTSpacing.md) {
                        //logo icon
                        ZStack {
                            RoundedRectangle(cornerRadius: GTRadius.md)
                                .stroke(Color.gtAccentGreen.opacity(0.6), lineWidth: 2)
                                .frame(width: 180, height: 160)

                            GTLogoIcon(
                                size: 130,
                                primaryColor: Color(red: 0.56, green: 0.78, blue: 0.40),
                                houseColor: Color(red: 0.18, green: 0.32, blue: 0.18)
                            )
                        }

                        //app name
                        Text("GreenThumb")
                            .font(.custom("Georgia", size: 38))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                       //tagline
                        Text("GROW WITH CONFIDENCE")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .tracking(2.5)
                            .foregroundColor(.gtAccentGreen)
                    }
                    .opacity(opacity)
                    .scaleEffect(scale)

                    Spacer()

                    
                    GTLoadingDots()
                        .opacity(opacity)
                        .padding(.bottom, GTSpacing.xxl)
                }
            }
            .navigationDestination(isPresented: $navigateNext) {
                OnboardingScreen1View()
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .signIn: SignInView()
                case .register: RegisterView()
                default: AnyView(EmptyView())
                }
            }
        }


        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1
                scale   = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                navigateNext = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AppRouter())
        .environmentObject(AuthViewModel())
        .environmentObject(PlantViewModel())
        .environmentObject(DiagnoseViewModel())
        .environmentObject(SchedulerViewModel())
        .environmentObject(ExpertViewModel())
        .environmentObject(CommunityViewModel())
        .environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel())
}
