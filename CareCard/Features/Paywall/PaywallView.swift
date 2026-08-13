import SwiftUI

/// ペイウォール。買い切り「合格パック」¥1,800のみ（サブスクは作らない）。
struct PaywallView: View {
    var allowsDismiss: Bool = true
    var onUnlocked: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(EntitlementStore.self) private var store

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "flame.fill").font(.system(size: 44)).foregroundStyle(CardTheme.accent)
                Text("すべてのカードを無制限に").font(.title2.bold())
                Text("介護支援分野・保健医療サービス分野・福祉サービス分野の全カード、試験日ペース管理、弱点マップが使えます。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                planRow(
                    title: "合格パック（買い切り）",
                    fallbackPrice: "¥1,800",
                    note: "一度の購入でずっと使える"
                )
                .padding(.horizontal)

                Button {
                    Task {
                        await store.purchase(productID: ProductIDs.unlock)
                        if store.isEntitled { closeIfPossible() }
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(billedAmountText()).font(.title3.bold())
                        Text("購入する").font(.footnote)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .accessibilityIdentifier("paywall_purchase")
                .disabled(store.isProcessing)

                Button("購入を復元") {
                    Task {
                        await store.restore()
                        if store.isEntitled { closeIfPossible() }
                    }
                }
                .font(.footnote)
                .accessibilityIdentifier("paywall_restore")

                Text("一度購入すると追加費用なくすべてのカードを使い続けられます。合格を保証するものではありません。")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Link("利用規約（EULA）",
                         destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("プライバシーポリシー",
                         destination: URL(string: "https://goonobu-dot.github.io/caremanecard-public/privacy.html")!)
                }
                .font(.caption2)
                .accessibilityIdentifier("paywall_legal_links")
                Spacer()
            }
            .padding()
            .toolbar {
                if allowsDismiss {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { closeIfPossible() }
                    }
                }
            }
        }
    }

    private func closeIfPossible() {
        onUnlocked?()
        dismiss()
    }

    private func billedAmountText() -> String {
        store.products[ProductIDs.unlock]?.displayPrice ?? "¥1,800"
    }

    @ViewBuilder
    private func planRow(title: String, fallbackPrice: String, note: String) -> some View {
        let price = store.products[ProductIDs.unlock]?.displayPrice ?? fallbackPrice
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(price).font(.title3.bold())
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(note).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
