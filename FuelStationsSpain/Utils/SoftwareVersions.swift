import Foundation

func compareSoftwareVersions(appVersion: String, comparisonVersion: String) -> Bool {
    let appVersionComponents = appVersion.split(separator: ".").map { Int($0) ?? 0 }
    let comparisonVersionComponents = comparisonVersion.split(separator: ".").map { Int($0) ?? 0 }

    if comparisonVersionComponents[0] > appVersionComponents[0] {
        return true
    }
    else if comparisonVersionComponents[1] > appVersionComponents[1] && comparisonVersionComponents[0] == appVersionComponents[0] {
        return true
    }
    else if comparisonVersionComponents[2] > appVersionComponents[2] && comparisonVersionComponents[1] == appVersionComponents[1] {
        return true
    }
    else {
        return false
    }
}
