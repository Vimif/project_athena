import SwiftUI

struct FancyBar: View {
    var value: Double        // de 0 à 1
    var color: Color
    var label: String
    var secondary: String = ""
    var icon: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f %%", value * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.7)]),
                        startPoint: .leading, endPoint: .trailing))
                    .frame(height: 24)
                    .shadow(radius: 1)
                Capsule()
                    .fill(color)
                    .frame(width: CGFloat(min(max(value, 0), 1)) * 320, height: 24)
                    .animation(.easeInOut(duration: 0.2), value: value)
                HStack(spacing: 0) {
                    ForEach(0..<11) { i in
                        if i != 0 {
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 1, height: 24)
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 320)
            .frame(maxWidth: .infinity)
            if !secondary.isEmpty {
                Text(secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
    }
}
