import SwiftUI

// ----------------------------------------------------------
// Composant carte de statistique
// ----------------------------------------------------------

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let percent: Double?
    let barColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Titre + icône côte à côte à gauche
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(barColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            // Barre fine
            if let pct = percent {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray4))
                            .frame(height: 4)
                        Capsule()
                            .fill(barColor)
                            .frame(width: CGFloat(max(min(pct, 1), 0)) * geo.size.width, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.vertical, 2)
            }
            // Valeur principale centrée
            HStack {
                Spacer()
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .frame(width: 160, height: 80)
    }
}
