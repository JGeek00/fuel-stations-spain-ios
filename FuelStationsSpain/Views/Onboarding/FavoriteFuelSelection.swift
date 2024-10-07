import SwiftUI

struct FavoriteFuelSelection: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    
    var body: some View {
        GeometryReader { proxy in
            let smallMode = proxy.size.height < 500.0
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Image(systemName: "fuelpump.fill")
                        .font(.system(size: smallMode ? 50 : 60))
                    Spacer()
                        .frame(height: 24)
                    Text("Favorite fuel")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 12)
                    Text("With a favorite fuel selected, the fuel station marker in the map will include the price of that fuel type on that station.")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 12)
                if !smallMode {
                    Form {
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
                    .padding(.top, -12)
                    .padding(.horizontal, 0)
                }
                else {
                    Picker("Favorite fuel", selection: $favoriteFuel) {
                        ForEach(favoriteFuels, id: \.self) { fuelSection in
                            ForEach(fuelSection.fuels, id: \.self) { fuel in
                                Text(fuel.label)
                                    .tag(fuel.fuelType)
                            }
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.horizontal, 24)
                }
                Spacer()
                    .frame(height: smallMode ? 12 : 24)
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
                    }
                    Spacer()
                    Button {
                        onboardingViewModel.finishOnboarding()
                    } label: {
                        HStack {
                            Text("Finish")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, smallMode ? 12 : 24)
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
        }
    }
}
