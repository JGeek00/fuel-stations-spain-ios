import SwiftUI

struct LocationAccessRequest: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "location.fill")
                .fontSize(60)
            Spacer()
                .frame(height: 24)
            Text("Location access")
                .fontSize(30)
                .fontWeight(.semibold)
                .padding(.bottom, 12)
            Spacer()
                .frame(height: 12)
            Text("This application requires access to realtime location to display the nearby service stations. On the following step, location access will be requested.")
            Spacer()
            HStack {
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 0
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Spacer()
                            .frame(width: 4)
                        Text("Previous")
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view.buttonStyle(.glass)
                    }
                    else {
                        view.buttonStyle(.plain)
                    }
                }
                Spacer()
                Button {
                    locationManager.requestLocationAccess()
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 2
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Spacer()
                            .frame(width: 4)
                        Image(systemName: "chevron.right")
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view.buttonStyle(.glass)
                    }
                    else {
                        view.buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(24)
    }
}
