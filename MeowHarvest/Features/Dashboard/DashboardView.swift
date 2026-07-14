//
//  DashboardView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(
        sort: \TransactionRecord.transactionDate,
        order: .reverse
    )
    private var transactions: [TransactionRecord]

    private var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { total, transaction in
                total + transaction.amount
            }
    }

    private var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { total, transaction in
                total + transaction.amount
            }
    }

    private var balance: Double {
        totalIncome - totalExpense
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 12
                    ) {
                        DashboardSummaryCard(
                            title: Text("dashboard.balance"),
                            value: currencyText(balance),
                            systemImage: "banknote"
                        )

                        DashboardSummaryCard(
                            title: Text("dashboard.total_income"),
                            value: currencyText(totalIncome),
                            systemImage: "arrow.down.circle"
                        )

                        DashboardSummaryCard(
                            title: Text("dashboard.total_expense"),
                            value: currencyText(totalExpense),
                            systemImage: "arrow.up.circle"
                        )

                        DashboardSummaryCard(
                            title: Text("dashboard.record_count"),
                            value: String(transactions.count),
                            systemImage: "list.bullet.rectangle"
                        )
                    }

                    if transactions.isEmpty {
                        ContentUnavailableView(
                            "dashboard.empty_title",
                            systemImage: "chart.bar",
                            description: Text(
                                "dashboard.empty_description"
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                    } else {
                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {
                            Text("dashboard.recent_transactions")
                                .font(.title2)
                                .fontWeight(.bold)

                            ForEach(
                                Array(transactions.prefix(5))
                            ) { transaction in
                                NavigationLink {
                                    TransactionDetailView(
                                        transaction: transaction
                                    )
                                } label: {
                                    RecentTransactionRow(
                                        transaction: transaction
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(
                Text("dashboard.navigation_title")
            )
        }
    }

    private func currencyText(
        _ amount: Double
    ) -> String {
        amount.formatted(
            .currency(code: "USD")
        )
    }
}

private struct DashboardSummaryCard: View {
    let title: Text
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)

            title
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 115,
            alignment: .leading
        )
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }
}

private struct RecentTransactionRow: View {
    let transaction: TransactionRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(
                systemName: transaction.type == .income
                    ? "arrow.down.circle.fill"
                    : "arrow.up.circle.fill"
            )
            .font(.title2)
            .foregroundStyle(
                transaction.type == .income
                    ? .green
                    : .orange
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.vendorOrSource)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(
                    transaction.transactionDate.formatted(
                        date: .abbreviated,
                        time: .omitted
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(
                transaction.amount.formatted(
                    .currency(code: "USD")
                )
            )
            .fontWeight(.semibold)
            .foregroundStyle(.primary)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.regularMaterial)
        }
    }
}
