//
//  project_athena_widgetLiveActivity.swift
//  project_athena_widget
//
//  Created by Thomas Boisaubert on 22/11/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct project_athena_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct project_athena_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: project_athena_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension project_athena_widgetAttributes {
    fileprivate static var preview: project_athena_widgetAttributes {
        project_athena_widgetAttributes(name: "World")
    }
}

extension project_athena_widgetAttributes.ContentState {
    fileprivate static var smiley: project_athena_widgetAttributes.ContentState {
        project_athena_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: project_athena_widgetAttributes.ContentState {
         project_athena_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: project_athena_widgetAttributes.preview) {
   project_athena_widgetLiveActivity()
} contentStates: {
    project_athena_widgetAttributes.ContentState.smiley
    project_athena_widgetAttributes.ContentState.starEyes
}
