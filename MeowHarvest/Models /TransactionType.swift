import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case expense
    case income

    var id: String {
        rawValue
    }

    // 当前界面显示文字
    var displayName: String {
        switch self {
        case .expense:
            return "支出"
        case .income:
            return "收入"
        }
    }

    // 同时兼容以前数据库中保存的中文值
    static func fromStoredValue(
        _ value: String
    ) -> TransactionType {
        let normalizedValue = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalizedValue {
        case "expense", "支出":
            return .expense

        case "income", "收入":
            return .income

        default:
            return .expense
        }
    }
}
