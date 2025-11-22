import SwiftUI
//import Formatting

struct MetricsGridView: View {
    // On récupère un objet stats complet, ou on injecte les valeurs explicitement
    let cpuFraction: Double
    let ramFraction: Double
    let ramGo: Double
    let storageUsed: Double
    let storageTotal: Double
    let percentUsed: Double
    let batteryLevel: Float
    let batteryState: UIDevice.BatteryState
    let batteryStatusText: String
    
    var body: some View {
        
        let batteryColor = Formatting.appleBatteryColor(level: batteryLevel, state: batteryState)
        let batteryText = Formatting.batteryStatusText(state: batteryState)
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            // CPU
            StatAppleCard(
                icon: "cpu",
                iconBg: Color.blue,
                title: "CPU",
                valueLeft: "",
                valueRight: String(format: "%.1f%%", cpuFraction * 100),
                percent: cpuFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )

            
            // RAM
            StatAppleCard(
                icon: "memorychip",
                iconBg: Color.white,
                title: "RAM",
                valueLeft: String(format: "%.2f Go / %.2f Go", ramFraction * ramGo, ramGo),
                valueRight: String(format: "%.1f%%", ramFraction * 100),
                percent: ramFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                    startPoint: .leading, endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )

            // Stockage
            StatAppleCard(
                icon: "internaldrive",
                iconBg: Color.white,
                title: "Stockage",
                valueLeft: String(format: "%.1f G/%.1f G", storageUsed, storageTotal),
                valueRight: String(format: "%.1f%%", percentUsed * 100),
                percent: percentUsed,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .leading, endPoint: .trailing
                
                ),
                caseColor: Color.cardBackground
            )
            
            // Batterie
            StatAppleCard(
                icon: "battery.100",
                iconBg: batteryColor,
                title: "Batterie",
                valueLeft: batteryText,
                valueRight: String(format: "%.0f%%", batteryLevel * 100),
                percent: Double(batteryLevel),
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [batteryColor, Color(.systemGray3)]),
                    startPoint: .leading, endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )

        }
    }
}
