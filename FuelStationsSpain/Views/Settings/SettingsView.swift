import SwiftUI

struct SettingsView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var contactDeveloperSafariOpen = false
    @State private var showBuildNumber = false
    @State private var dataSourceSafariOpen = false
    @State private var appRepoSafariOpen = false
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            List {
                Picker("Theme", selection: $theme) {
                    ListRowWithIconEntry(systemIcon: "iphone", iconColor: .green, label: "System defined")
                        .tag(Enums.Theme.system)
                    ListRowWithIconEntry(systemIcon: "sun.max.fill", iconColor: .orange, label: "Light")
                        .tag(Enums.Theme.light)
                    ListRowWithIconEntry(systemIcon: "moon.fill", iconColor: .indigo, label: "Dark")
                        .tag(Enums.Theme.dark)
                }
                .pickerStyle(.inline)
                
                Section("App settings") {
                    NavigationLink {
                        GeneralSettings()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "gear", iconColor: .blue, label: "General settings")
                    }
                }

                Section {
                    Button {
                        dataSourceSafariOpen = true
                    } label: {
                        ListRowWithIconEntry(systemIcon: "text.document.fill", iconColor: .red, label: "Data source")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This application receives the data from a public API of the Spanish government.")
                }
                
                Section {
                    NavigationLink {
                        TipsView()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "dollarsign.circle.fill", iconColor: .green, label: "Give a tip to the developer")
                    }
                    Button {
                        contactDeveloperSafariOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "message.fill", iconColor: .brown, label: "Contact the developer")
                    }
                    Button {
                        appRepoSafariOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(assetIcon: colorScheme == .dark ? "github" : "github-white", iconColor: Color.github, label: "App repository")
                    }
                    HStack {
                        ListRowWithIconEntry(systemIcon: "info.circle.fill", iconColor: .teal, label: "App version")
                        Spacer()
                        Text(showBuildNumber == true ? buildNumber : version)
                            .foregroundColor(Color.listItemValue)
                            .animation(.default, value: showBuildNumber)
                            .onTapGesture {
                                showBuildNumber.toggle()
                            }
                    }
                } header: {
                    Text("About the app")
                } footer: {
                    HStack {
                        Spacer()
                        Text("Created on 🇪🇸 by JGeek00")
                            .multilineTextAlignment(.center)
                            .fontSize(16)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $contactDeveloperSafariOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.appSupport)!).ignoresSafeArea()
            })
            .fullScreenCover(isPresented: $dataSourceSafariOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.dataSourceApi)!).ignoresSafeArea()
            })
            .fullScreenCover(isPresented: $appRepoSafariOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.appRepo)!).ignoresSafeArea()
            })
        }
    }
}
