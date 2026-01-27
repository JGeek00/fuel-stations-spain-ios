import SwiftUI

struct Welcome: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Image("AppIconImage")
                    .resizable()
                    .frame(width: verticalSizeClass == .regular ? 130 : 90, height: verticalSizeClass == .regular ? 130 : 90)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                Spacer()
                    .frame(height: 24)
                Text("Welcome to HispaFuel")
                    .fontSize(verticalSizeClass == .regular ? 40 : 36)
                    .fontWeight(.bold)
                    .padding(.bottom, 12)
                    .multilineTextAlignment(.center)
                Text("Realtime information about fuel prices on Spanish service stations.")
                    .fontWeight(.medium)
                    .fontSize(verticalSizeClass == .regular ? 30 : 26)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
                    }
                } label: {
                    Text("Get started")
                        .fontWeight(.medium)
                        .fontSize(20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view.buttonStyle(.glassProminent)
                    }
                    else {
                        view.buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                Spacer()
            }
            .padding()
        }
        .padding(0)
        .fontDesign(.rounded)
    }
}
