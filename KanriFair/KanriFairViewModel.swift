import SwiftUI

enum UnitCountRange: String, CaseIterable, Identifiable {
    case small = "20戸以下"
    case medium = "21〜50戸"
    case large = "51〜100戸"
    case xlarge = "101〜200戸"
    case xxlarge = "201戸以上"

    var id: String { rawValue }
    var label: String { rawValue }

    var averagePerSqm: Int {
        switch self {
        case .small: return 271
        case .medium: return 245
        case .large: return 228
        case .xlarge: return 215
        case .xxlarge: return 202
        }
    }
}

enum FloorRange: String, CaseIterable, Identifiable {
    case low = "5階以下"
    case mid = "6〜10階"
    case high = "11〜19階"
    case tower = "20階以上（タワー）"

    var id: String { rawValue }
    var label: String { rawValue }

    var adjustment: Double {
        switch self {
        case .low: return 0.95
        case .mid: return 1.0
        case .high: return 1.08
        case .tower: return 1.25
        }
    }
}

enum BuildingAgeRange: String, CaseIterable, Identifiable {
    case new = "5年以内"
    case young = "6〜15年"
    case mid = "16〜25年"
    case old = "26〜35年"
    case veryOld = "36年以上"

    var id: String { rawValue }
    var label: String { rawValue }

    var adjustment: Double {
        switch self {
        case .new: return 0.90
        case .young: return 0.95
        case .mid: return 1.0
        case .old: return 1.08
        case .veryOld: return 1.15
        }
    }
}

class KanriFairViewModel: ObservableObject {
    @Published var unitCountRange: UnitCountRange = .medium
    @Published var floorRange: FloorRange = .mid
    @Published var ageRange: BuildingAgeRange = .mid
    @Published var areaText: String = "70"
    @Published var currentFeeText: String = ""
    @Published var showResult = false

    var averagePerSqm: Int = 0
    var estimatedFee: Int = 0
    var currentFee: Int = 0
    var differenceText: String = ""
    var differenceColor: Color = .primary
    var verdict: String = ""
    var verdictColor: Color = .primary
    var advice: String = ""

    func calculate() {
        guard let area = Double(areaText),
              let fee = Int(currentFeeText) else { return }

        let basePerSqm = Double(unitCountRange.averagePerSqm)
        let adjusted = basePerSqm * floorRange.adjustment * ageRange.adjustment
        averagePerSqm = Int(adjusted)
        estimatedFee = Int(adjusted * area)
        currentFee = fee

        let diff = fee - estimatedFee
        let diffPercent = Double(diff) / Double(estimatedFee) * 100

        if diff > 0 {
            differenceText = "+¥\(diff)（+\(Int(diffPercent))%）"
        } else {
            differenceText = "¥\(diff)（\(Int(diffPercent))%）"
        }

        if diffPercent > 30 {
            differenceColor = .red
            verdict = "かなり割高"
            verdictColor = .red
            advice = "管理委託費の見直し、管理会社の変更を検討する価値があります。理事会で管理費の内訳明細を確認しましょう。"
        } else if diffPercent > 15 {
            differenceColor = .orange
            verdict = "やや割高"
            verdictColor = .orange
            advice = "管理内容に見合っているか確認を。コンシェルジュや豪華な共用施設があれば妥当な場合もあります。"
        } else if diffPercent > -15 {
            differenceColor = .green
            verdict = "適正範囲"
            verdictColor = .green
            advice = "相場通りの管理費です。管理内容に不満がなければ問題ありません。"
        } else if diffPercent > -30 {
            differenceColor = .blue
            verdict = "やや割安"
            verdictColor = .blue
            advice = "安い分、管理が行き届いているか確認を。修繕積立金が不足していないかも要チェック。"
        } else {
            differenceColor = .purple
            verdict = "かなり割安（要注意）"
            verdictColor = .purple
            advice = "管理費が安すぎると、将来の大規模修繕時に一時金徴収のリスクがあります。長期修繕計画を確認してください。"
        }

        showResult = true
    }
}
