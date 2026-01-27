import SwiftUI

struct FavoriteFuelSelection: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    
    var body: some View {
        VStack {
            List {
                VStack(alignment: .leading) {
                    Image(systemName: "fuelpump.fill")
                        .fontSize(60)
                    Spacer()
                        .frame(height: 24)
                    Text("Favorite fuel")
                        .fontSize(30)
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 12)
                    Text("With a favorite fuel selected, the fuel station marker in the map will include the price of that fuel type on that station.")
                }
                .padding(.horizontal, -12)
                .padding(.bottom, -12)
                .listRowBackground(Color.listBackground)
                Picker(String(stringLiteral: ""), selection: $favoriteFuel) {
                    ForEach(favoriteFuels, id: \.self) { fuelSection in
                        ForEach(fuelSection.fuels, id: \.self) { fuel in
                            Text(fuel.label)
                                .tag(fuel.fuelType)
                        }
                    }
                }
                .pickerStyle(.inline)
            }
            .padding(.top, -24)
            HStack {
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
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
                    onboardingViewModel.finishOnboarding()
                } label: {
                    HStack {
                        Text("Finish")
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
                .condition { view in
                    if #available(iOS 26.0, *) {
                        view.buttonStyle(.glassProminent)
                    }
                    else {
                        view.buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(24)
        }
    }
}
