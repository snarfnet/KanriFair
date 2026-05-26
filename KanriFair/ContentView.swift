import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = KanriFairViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: 0x07111F), Color(hex: 0x0F2B4D)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        heroSection
                        inputSection
                        if viewModel.showResult {
                            resultSection
                        } else {
                            insightStrip
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 76)
                }
            }
            .navigationTitle("管理費チェッカー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/KANRIFAIR_B")
                    .frame(height: 50)
                    .background(.ultraThinMaterial)
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MANAGEMENT FEE")
                        .font(.caption.bold())
                        .foregroundStyle(.cyan)
                    Text("マンション管理費の妥当性をすばやく確認")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                }
                Spacer()
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 46))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.cyan)
            }

            HStack(spacing: 10) {
                metric("戸数", viewModel.unitCountRange.label)
                metric("階数", viewModel.floorRange.label)
                metric("築年", viewModel.ageRange.label)
            }
        }
        .padding(20)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(.white.opacity(0.12)))
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("物件条件")
                .font(.headline)

            selector("総戸数", selection: $viewModel.unitCountRange, values: UnitCountRange.allCases)
            selector("階数", selection: $viewModel.floorRange, values: FloorRange.allCases)
            selector("築年数", selection: $viewModel.ageRange, values: BuildingAgeRange.allCases)

            HStack(spacing: 12) {
                inputField("専有面積", text: $viewModel.areaText, suffix: "㎡", keyboard: .decimalPad)
                inputField("現在の管理費", text: $viewModel.currentFeeText, suffix: "円/月", keyboard: .numberPad)
            }

            Button(action: viewModel.calculate) {
                Label("診断する", systemImage: "gauge.with.dots.needle.67percent")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(18)
        .foregroundStyle(.primary)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("診断結果")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(viewModel.verdict)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(viewModel.verdictColor)
                }
                Spacer()
                Text(viewModel.rateText)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(viewModel.verdictColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(viewModel.verdictColor)
            }

            Gauge(value: viewModel.comparisonProgress) {
                Text("相場比")
            }
            currentValueLabel: {
                Text(viewModel.formatCurrency(viewModel.currentFee))
            }
            minimumValueLabel: {
                Text("安")
            }
            maximumValueLabel: {
                Text("高")
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(Gradient(colors: [.blue, .green, .orange, .red]))

            VStack(spacing: 12) {
                resultRow("相場目安", "\(viewModel.formatCurrency(viewModel.estimatedFee)) / 月")
                resultRow("㎡単価目安", "\(viewModel.formatCurrency(viewModel.averagePerSqm)) / ㎡")
                resultRow("現在の管理費", "\(viewModel.formatCurrency(viewModel.currentFee)) / 月")
                resultRow("差額", viewModel.differenceText, color: viewModel.verdictColor)
            }

            Text(viewModel.advice)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(viewModel.verdictColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))

            Text("国土交通省のマンション総合調査を参考にした簡易目安です。管理仕様、地域、共用施設、修繕計画により実際の適正額は変わります。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var insightStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(.green)
            Text("入力内容は端末内で計算します。管理会社や外部サーバーへ送信しません。")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    private func selector<T: Identifiable & Hashable>(_ title: String, selection: Binding<T>, values: [T]) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Picker(title, selection: selection) {
                ForEach(values) { value in
                    Text(label(for: value)).tag(value)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func label<T>(for value: T) -> String {
        if let value = value as? UnitCountRange { return value.label }
        if let value = value as? FloorRange { return value.label }
        if let value = value as? BuildingAgeRange { return value.label }
        return "\(value)"
    }

    private func inputField(_ title: String, text: Binding<String>, suffix: String, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            HStack {
                TextField("0", text: text)
                    .keyboardType(keyboard)
                    .font(.headline)
                Text(suffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func resultRow(_ title: String, _ value: String, color: Color = .primary) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .font(.subheadline)
    }
}

private extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}
