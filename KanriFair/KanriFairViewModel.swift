import SwiftUI

enum UnitCountRange: String, CaseIterable, Identifiable {
    case small
    case medium
    case large
    case xlarge
    case xxlarge

    var id: String { rawValue }

    var label: String {
        switch self {
        case .small: return "20戸以下"
        case .medium: return "21〜50戸"
        case .large: return "51〜100戸"
        case .xlarge: return "101〜200戸"
        case .xxlarge: return "201戸以上"
        }
    }

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
    case low
    case mid
    case high
    case tower

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low: return "5階以下"
        case .mid: return "6〜10階"
        case .high: return "11〜19階"
        case .tower: return "20階以上"
        }
    }

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
    case new
    case young
    case mid
    case old
    case veryOld

    var id: String { rawValue }

    var label: String {
        switch self {
        case .new: return "5年以内"
        case .young: return "6〜15年"
        case .mid: return "16〜25年"
        case .old: return "26〜35年"
        case .veryOld: return "36年以上"
        }
    }

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

final class KanriFairViewModel: ObservableObject {
    @Published var unitCountRange: UnitCountRange = .medium
    @Published var floorRange: FloorRange = .mid
    @Published var ageRange: BuildingAgeRange = .mid
    @Published var areaText = "70"
    @Published var currentFeeText = ""
    @Published var showResult = false

    var averagePerSqm = 0
    var estimatedFee = 0
    var currentFee = 0
    var difference = 0
    var differenceRate = 0.0
    var verdict = "未診断"
    var advice = "専有面積と現在の管理費を入力すると、目安と比較できます。"

    var differenceText: String {
        let sign = difference > 0 ? "+" : ""
        return "\(sign)\(formatCurrency(difference))"
    }

    var rateText: String {
        String(format: "%+.0f%%", differenceRate)
    }

    var verdictColor: Color {
        switch differenceRate {
        case 30...: return .red
        case 15..<30: return .orange
        case -15...15: return .green
        case -30..<(-15): return .blue
        default: return .purple
        }
    }

    var statusLabel: String {
        switch differenceRate {
        case 30...: return "かなり高め"
        case 15..<30: return "やや高め"
        case -15...15: return "適正圏内"
        case -30..<(-15): return "やや安め"
        default: return "安すぎ注意"
        }
    }

    var comparisonProgress: Double {
        guard estimatedFee > 0 else { return 0 }
        return min(max(Double(currentFee) / Double(estimatedFee), 0), 1.8) / 1.8
    }

    func calculate() {
        guard let area = Double(areaText.replacingOccurrences(of: ",", with: "")),
              let fee = Int(currentFeeText.replacingOccurrences(of: ",", with: "")),
              area > 0 else { return }

        let adjusted = Double(unitCountRange.averagePerSqm) * floorRange.adjustment * ageRange.adjustment
        averagePerSqm = Int(adjusted.rounded())
        estimatedFee = Int((adjusted * area).rounded())
        currentFee = fee
        difference = fee - estimatedFee
        differenceRate = Double(difference) / Double(estimatedFee) * 100
        verdict = statusLabel

        switch differenceRate {
        case 30...:
            advice = "管理委託費、清掃費、設備保守費の内訳を確認しましょう。総会資料で支出の根拠を見直す価値があります。"
        case 15..<30:
            advice = "相場より少し高めです。共用施設や管理品質に見合っているか、同規模物件と比べて確認しましょう。"
        case -15...15:
            advice = "相場に近い水準です。金額だけでなく、修繕積立金や管理内容も合わせて確認すると判断しやすくなります。"
        case -30..<(-15):
            advice = "安めの水準です。管理が簡素すぎないか、将来の修繕費へしわ寄せが出ないかを確認しましょう。"
        default:
            advice = "かなり安めです。長期修繕計画、管理会社の業務範囲、未収金の有無を必ず確認してください。"
        }

        showResult = true
    }

    func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "¥\(value)"
    }
}
