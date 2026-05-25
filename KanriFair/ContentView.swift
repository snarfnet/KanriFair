import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = KanriFairViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    inputSection
                    if viewModel.showResult {
                        resultSection
                    }
                    Spacer(minLength: 60)
                }
                .padding()
            }
            .navigationTitle("管理費チェッカー")
            .safeAreaInset(edge: .bottom) {
                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/KANRIFAIR_B")
                    .frame(height: 50)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            Text("マンション管理費の適正診断")
                .font(.headline)
            Text("国交省マンション総合調査データに基づき\nあなたの管理費が相場と比べて適正か診断します")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            Group {
                HStack {
                    Text("総戸数")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.unitCountRange) {
                        ForEach(UnitCountRange.allCases) { range in
                            Text(range.label).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }

                HStack {
                    Text("階数")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.floorRange) {
                        ForEach(FloorRange.allCases) { range in
                            Text(range.label).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }

                HStack {
                    Text("築年数")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.ageRange) {
                        ForEach(BuildingAgeRange.allCases) { range in
                            Text(range.label).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }

                HStack {
                    Text("専有面積")
                        .frame(width: 100, alignment: .leading)
                    TextField("㎡", text: $viewModel.areaText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("㎡")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("現在の管理費")
                        .frame(width: 100, alignment: .leading)
                    TextField("円/月", text: $viewModel.currentFeeText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    Text("円/月")
                        .foregroundColor(.secondary)
                }
            }

            Button(action: viewModel.calculate) {
                Text("診断する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("診断結果")
                .font(.title2.bold())

            VStack(spacing: 8) {
                HStack {
                    Text("相場（㎡単価）")
                    Spacer()
                    Text("¥\(viewModel.averagePerSqm)/���")
                        .bold()
                }
                HStack {
                    Text("あなたの物件の相場目安")
                    Spacer()
                    Text("¥\(viewModel.estimatedFee)/月")
                        .bold()
                }
                HStack {
                    Text("現在の管理費")
                    Spacer()
                    Text("¥\(viewModel.currentFee)/月")
                        .bold()
                }

                Divider()

                HStack {
                    Text("相場との差")
                    Spacer()
                    Text(viewModel.differenceText)
                        .bold()
                        .foregroundColor(viewModel.differenceColor)
                }

                Text(viewModel.verdict)
                    .font(.headline)
                    .foregroundColor(viewModel.verdictColor)
                    .padding(.top, 8)

                Text(viewModel.advice)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding()
            .background(viewModel.verdictColor.opacity(0.05))
            .cornerRadius(12)

            Text("※ 国交省「マンション総合調査」の平均値に基づく目安です。\n管理内容や立地により変動します。")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
