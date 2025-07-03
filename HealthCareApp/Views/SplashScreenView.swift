import SwiftUI

struct SplashScreenView: View {
    @State private var opacity: Double = 0.0
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Image("splashScreenIcon") // Replace with your splash image asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .opacity(opacity)
                Text("Your Health, Our Priority.")
                    .font(.title)
                    .fontWeight(.bold)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            opacity = 1.0
                        }
                    }
                Spacer()
                
                Text("Copyright © 2025 Yogesh Rathore. All rights reserved.")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    SplashScreenView()
} 
