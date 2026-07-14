import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label(
                        "tab.dashboard",
                        systemImage: "chart.bar.fill"
                    )
                }

            TransactionListView()
                .tabItem {
                    Label(
                        "tab.transactions",
                        systemImage: "list.bullet.rectangle"
                    )
                }

            AddTransactionView()
                .tabItem {
                    Label(
                        "tab.add_transaction",
                        systemImage: "plus.circle.fill"
                    )
                }
        }
    }
}

