import Foundation

enum CategoryCatalog {

    // 数据库中保存稳定的分类 ID
    static let expenseCategories = [
        "expense.land_rent",
        "expense.seeds",
        "expense.fertilizer",
        "expense.pesticides",
        "expense.irrigation",
        "expense.tools_equipment",
        "expense.fuel",
        "expense.labor",
        "expense.insurance",
        "expense.portable_toilet",
        "expense.marketing",
        "expense.packaging",
        "expense.maintenance",
        "expense.other"
    ]

    static let incomeCategories = [
        "income.u_pick",
        "income.produce_sales",
        "income.event_tickets",
        "income.market_sales",
        "income.other"
    ]

    static func categories(
        for type: TransactionType
    ) -> [String] {
        switch type {
        case .expense:
            return expenseCategories

        case .income:
            return incomeCategories
        }
    }

    // 根据当前语言显示分类名称
    static func localizedName(
        for storedValue: String,
        type: TransactionType
    ) -> String {
        let categoryID = normalizedID(
            from: storedValue,
            type: type
        )

        switch categoryID {
        case "expense.land_rent":
            return String(
                localized: "category.expense.land_rent"
            )

        case "expense.seeds":
            return String(
                localized: "category.expense.seeds"
            )

        case "expense.fertilizer":
            return String(
                localized: "category.expense.fertilizer"
            )

        case "expense.pesticides":
            return String(
                localized: "category.expense.pesticides"
            )

        case "expense.irrigation":
            return String(
                localized: "category.expense.irrigation"
            )

        case "expense.tools_equipment":
            return String(
                localized: "category.expense.tools_equipment"
            )

        case "expense.fuel":
            return String(
                localized: "category.expense.fuel"
            )

        case "expense.labor":
            return String(
                localized: "category.expense.labor"
            )

        case "expense.insurance":
            return String(
                localized: "category.expense.insurance"
            )

        case "expense.portable_toilet":
            return String(
                localized: "category.expense.portable_toilet"
            )

        case "expense.marketing":
            return String(
                localized: "category.expense.marketing"
            )

        case "expense.packaging":
            return String(
                localized: "category.expense.packaging"
            )

        case "expense.maintenance":
            return String(
                localized: "category.expense.maintenance"
            )

        case "expense.other":
            return String(
                localized: "category.expense.other"
            )

        case "income.u_pick":
            return String(
                localized: "category.income.u_pick"
            )

        case "income.produce_sales":
            return String(
                localized: "category.income.produce_sales"
            )

        case "income.event_tickets":
            return String(
                localized: "category.income.event_tickets"
            )

        case "income.market_sales":
            return String(
                localized: "category.income.market_sales"
            )

        case "income.other":
            return String(
                localized: "category.income.other"
            )

        default:
            return storedValue
        }
    }

    // 兼容之前保存的中文分类
    static func normalizedID(
        from storedValue: String,
        type: TransactionType
    ) -> String {
        let value = storedValue.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        switch value {
        case "expense.land_rent", "土地租金":
            return "expense.land_rent"

        case "expense.seeds", "种苗 / 种子":
            return "expense.seeds"

        case "expense.fertilizer", "肥料":
            return "expense.fertilizer"

        case "expense.pesticides", "农药":
            return "expense.pesticides"

        case "expense.irrigation", "灌溉":
            return "expense.irrigation"

        case "expense.tools_equipment", "工具设备":
            return "expense.tools_equipment"

        case "expense.fuel", "燃油":
            return "expense.fuel"

        case "expense.labor", "人工":
            return "expense.labor"

        case "expense.insurance", "保险":
            return "expense.insurance"

        case "expense.portable_toilet", "移动厕所":
            return "expense.portable_toilet"

        case "expense.marketing", "广告营销":
            return "expense.marketing"

        case "expense.packaging", "包装材料":
            return "expense.packaging"

        case "expense.maintenance", "维修保养":
            return "expense.maintenance"

        case "income.u_pick", "U-Pick":
            return "income.u_pick"

        case "income.produce_sales", "农产品销售":
            return "income.produce_sales"

        case "income.event_tickets", "活动门票":
            return "income.event_tickets"

        case "income.market_sales", "摊位销售":
            return "income.market_sales"

        case "expense.other":
            return "expense.other"

        case "income.other":
            return "income.other"

        case "其他":
            return type == .expense
                ? "expense.other"
                : "income.other"

        default:
            return value
        }
    }
}
