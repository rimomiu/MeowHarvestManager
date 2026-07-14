//
//  TransactionListView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        sort: \TransactionRecord.transactionDate,
        order: .reverse
    )
    private var transactions: [TransactionRecord]

    var body: some View {
        NavigationStack {
            List {
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(transaction.vendorOrSource)
                                .font(.headline)

                            Spacer()

                            Text(
                                transaction.amount,
                                format: .currency(code: "USD")
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                transaction.type == .income
                                    ? .green
                                    : .primary
                            )
                        }

                        Text(
                            "\(transaction.type.rawValue) · \(transaction.category)"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(
                            transaction.transactionDate.formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteTransactions)
            }
            .navigationTitle("账目记录")
            .overlay {
                if transactions.isEmpty {
                    ContentUnavailableView(
                        "暂无账目",
                        systemImage: "tray",
                        description: Text("保存收入或支出后会显示在这里。")
                    )
                }
            }
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(transactions[offset])
        }

        try? modelContext.save()
    }
}
