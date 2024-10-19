import SwiftUI

struct StationDetailsListItem: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String?
    @ViewBuilder let viewSubtitle: (() -> AnyView)?
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.viewSubtitle = nil
    }
    
    init(icon: String, iconColor: Color, title: String, viewSubtitle: (() -> AnyView)? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.viewSubtitle = viewSubtitle
        self.subtitle = nil
    }
    
    var body: some View {
        return HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.white)
                .frameDynamicSize(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)
            Spacer()
                .frame(width: 12)
            VStack(alignment: .leading) {
                Text(title)
                    .fontSize(16)
                    .fontWeight(.semibold)
                if let subtitle = subtitle {
                    Spacer()
                        .frame(height: 8)
                    Text(subtitle)
                        .fontSize(14)
                        .foregroundStyle(Color.gray)
                        .fontWeight(.medium)
                }
                if let viewSubtitle = viewSubtitle {
                    Spacer()
                        .frame(height: 8)
                    viewSubtitle()
                }
                else {
                    EmptyView()
                }
            }
            Spacer()
        }
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
        .padding()
    }
}
