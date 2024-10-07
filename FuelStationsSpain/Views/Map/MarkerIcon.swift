import Foundation
import SwiftUI

struct PriceMarker: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: width*0.5, y: height))
        path.addLine(to: CGPoint(x: width*0.4, y: height*0.8))
        path.addLine(to: CGPoint(x: 0, y: height*0.8))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height*0.8))
        path.addLine(to: CGPoint(x: width*0.6, y: height*0.8))
        path.closeSubpath()
        
        return path
    }
}

struct NormalMarker: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.33646*width, y: 0.97982*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.375*height), control1: CGPoint(x: 0.05268*width, y: 0.56842*height), control2: CGPoint(x: 0, y: 0.5262*height))
        path.addCurve(to: CGPoint(x: 0.375*width, y: 0), control1: CGPoint(x: 0, y: 0.16789*height), control2: CGPoint(x: 0.16789*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.75*width, y: 0.375*height), control1: CGPoint(x: 0.58211*width, y: 0), control2: CGPoint(x: 0.75*width, y: 0.16789*height))
        path.addCurve(to: CGPoint(x: 0.41354*width, y: 0.97982*height), control1: CGPoint(x: 0.75*width, y: 0.5262*height), control2: CGPoint(x: 0.69732*width, y: 0.56842*height))
        path.addCurve(to: CGPoint(x: 0.33646*width, y: 0.97982*height), control1: CGPoint(x: 0.39492*width, y: 1.00673*height), control2: CGPoint(x: 0.35508*width, y: 1.00672*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.375*width, y: 0.53125*height))
        path.addCurve(to: CGPoint(x: 0.53125*width, y: 0.375*height), control1: CGPoint(x: 0.46129*width, y: 0.53125*height), control2: CGPoint(x: 0.53125*width, y: 0.46129*height))
        path.addCurve(to: CGPoint(x: 0.375*width, y: 0.21875*height), control1: CGPoint(x: 0.53125*width, y: 0.28871*height), control2: CGPoint(x: 0.46129*width, y: 0.21875*height))
        path.addCurve(to: CGPoint(x: 0.21875*width, y: 0.375*height), control1: CGPoint(x: 0.28871*width, y: 0.21875*height), control2: CGPoint(x: 0.21875*width, y: 0.28871*height))
        path.addCurve(to: CGPoint(x: 0.375*width, y: 0.53125*height), control1: CGPoint(x: 0.21875*width, y: 0.46129*height), control2: CGPoint(x: 0.28871*width, y: 0.53125*height))
        path.closeSubpath()
        return path
    }
}
