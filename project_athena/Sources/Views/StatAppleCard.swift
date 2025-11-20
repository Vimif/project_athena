//
//  StatAppleCard.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

struct DeviceInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoCard()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct StatAppleCard: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let valueLeft: String
    let valueRight: String
    let percent: Double
    let barGradient: LinearGradient
    var valueStatus: String? = nil
    var caseColor: Color = Color(.systemBackground)

    var body: some View {
        CaseView(caseColor: caseColor) {
            VStack(alignment: .leading, spacing: 10) {
                // En-tête icône + titre
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(iconBg)
                            .frame(width: 30, height: 30)
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                // Barre de progression TOUJOURS au-dessus
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 8)
                        Capsule()
                            .fill(barGradient)
                            .frame(width: geometry.size.width * CGFloat(max(min(percent, 1), 0)), height: 8)
                    }
                }
                .frame(height: 8)
                // Bloc statistiques ou status
                if let valueStatus = valueStatus {
                    HStack {
                        Text(valueStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(valueLeft)
                            .font(.subheadline)
                            .foregroundColor(iconBg)
                    }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        Text(valueLeft)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(valueRight)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
