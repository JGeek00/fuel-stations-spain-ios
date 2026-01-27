import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if horizontalSizeClass == .compact {
            TabView(selection: $onboardingViewModel.selectedTab) {
                Welcome()
                    .tag(0)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                LocationAccessRequest()
                    .tag(1)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                FavoriteFuelSelection()
                    .tag(2)
                    .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            }
            .background(Color.listBackground)
            .fontDesign(.rounded)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            .onAppear {
                  UIScrollView.appearance().isScrollEnabled = false
            }
        }
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Group {
                        TabView(selection: $onboardingViewModel.selectedTab) {
                            Welcome()
                                .tag(0)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                            LocationAccessRequest()
                                .tag(1)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                            FavoriteFuelSelection()
                                .tag(2)
                                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                        }
                        .padding()
                        .background(Color.listBackground)
                        .fontDesign(.rounded)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    }
                    .frame(maxWidth: 600, maxHeight: 800)
                    .condition { view in
                        if #available(iOS 26.0, *) {
                            view.cornerRadius(32)
                        }
                        else {
                            view.cornerRadius(12)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .background(colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [Color.init(hex: "525252"), Color.init(hex: "404040")]), startPoint: .top, endPoint: .bottom) : LinearGradient(gradient: Gradient(colors: [Color.init(hex: "dcdcdb"), Color.init(hex: "abacab")]), startPoint: .top, endPoint: .bottom))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .shadow(radius: 20)
        }
    }
}
