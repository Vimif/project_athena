//
//  DeviceInfoCard.swift
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

struct DeviceInfoCard: View {
    var deviceName: String { UIDevice.current.name }
    var iosVersion: String { "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)" }
    var model: String { getDeviceModel() }
    var chip: String { getChipModel(model: model) }
    var memory: String { getTotalMemory() }
    var storage: String { getTotalDiskSpace() }
    var uptime: String { getUptimeString() }
    var lastReboot: String { getLastBootString() }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: "iphone.gen3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33, height: 35)
                        .foregroundColor(.blue)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(deviceName)
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(iosVersion)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.gray.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
            }
            // Grille 2 colonnes, bien espacée
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 17) {
                infoRow(label: "Modèle", value: model)
                infoRow(label: "Stockage", value: storage)
                infoRow(label: "Puce", value: chip)
                infoRow(label: "Mémoire", value: memory)
                infoRow(label: "Temps de fonctionnement", value: uptime)
                infoRow(label: "Date de redémarrage", value: lastReboot)
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.11), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 6)
    }
    // Ligne info style Apple
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.gray.opacity(0.8))
                .lineLimit(1)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}
