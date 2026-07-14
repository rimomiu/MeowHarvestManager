//
//  RootTabView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Text("Dashboard")
                .tabItem {
                    Label(
                        "概览",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                }

            TransactionListView()
                .tabItem {
                    Label(
                        "账目",
                        systemImage: "list.bullet.rectangle"
                    )
                }

            AddTransactionView()
                .tabItem {
                    Label(
                        "记账",
                        systemImage: "plus.circle.fill"
                    )
                }
        }
    }
}
