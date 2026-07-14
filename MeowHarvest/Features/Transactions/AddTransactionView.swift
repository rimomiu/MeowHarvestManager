//
//  AddTransactionView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var transactionType: TransactionType = .expense
    @State private var transactionDate = Date()
    @State private var amountText = ""
    @State private var category = CategoryCatalog.expenseCategories[0]
    @State private var vendorOrSource = ""
    @State private var memo = ""
    @State private var showSavedAlert = false

    private var categories: [String] {
        transactionType == .expense
            ? CategoryCatalog.expenseCategories
            : CategoryCatalog.incomeCategories
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("账目信息") {
                    Picker("类型", selection: $transactionType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: transactionType) {
                        category = categories[0]
                    }

                    DatePicker(
                        "日期",
                        selection: $transactionDate,
                        displayedComponents: .date
                    )

                    TextField("金额", text: $amountText)
                        .keyboardType(.decimalPad)

                    Picker("分类", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }

                    TextField(
                        transactionType == .expense
                            ? "商家 / 收款人"
                            : "收入来源",
                        text: $vendorOrSource
                    )

                    TextField(
                        "备注",
                        text: $memo,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section {
                    Button("保存记录") {
                        saveTransaction()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle("新增账目")
            .alert("保存成功", isPresented: $showSavedAlert) {
                Button("好的", role: .cancel) {}
            }
        }
    }

    private var formIsValid: Bool {
        guard let amount = Double(amountText), amount > 0 else {
            return false
        }

        return !vendorOrSource
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    private func saveTransaction() {
        guard let amount = Double(amountText), amount > 0 else {
            return
        }

        let transaction = TransactionRecord(
            type: transactionType,
            transactionDate: transactionDate,
            amount: amount,
            category: category,
            vendorOrSource: vendorOrSource,
            memo: memo
        )

        modelContext.insert(transaction)

        do {
            try modelContext.save()
            resetForm()
            showSavedAlert = true
        } catch {
            print("Save failed: \(error.localizedDescription)")
        }
    }

    private func resetForm() {
        transactionDate = Date()
        amountText = ""
        vendorOrSource = ""
        memo = ""
        category = categories[0]
    }
}
