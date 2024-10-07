import SwiftUI

struct LocationAccessRequest: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        GeometryReader { proxy in
            let smallMode = proxy.size.height < 500.0
            VStack(alignment: .leading) {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                Spacer()
                    .frame(height: 24)
                Text("Location access")
                    .font(.system(size: 30))
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
                    }
                }
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, smallMode ? 12 : 24)
        }
    }
}
