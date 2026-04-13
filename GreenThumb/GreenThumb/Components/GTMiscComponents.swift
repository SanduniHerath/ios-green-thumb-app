import SwiftUI

struct GTChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 60) }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 3) {
                Text(message.content)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(message.isFromUser ? .white : .gtTextPrimary)
                    .padding(.horizontal, GTSpacing.md)
                    .padding(.vertical, GTSpacing.xs + 2)
                    .background(
                        RoundedRectangle(cornerRadius: GTRadius.lg)
                            .fill(message.isFromUser ? Color.gtDarkGreen : Color.gtPaleGreen)
                    )

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }

            if !message.isFromUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, GTSpacing.md)
    }
}

struct GTSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(GTFont.labelLarge())
                .foregroundColor(.gtTextPrimary)
            Spacer()
            if let actionTitle {
                Button { action?() } label: {
                    Text(actionTitle)
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtDarkGreen)
                }
            }
        }
    }
}

struct GTToggleSwitch: View {
    let label: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(.gtDarkGreen)
                .labelsHidden()
        }
    }
}

struct GTSchedulerTask: View {
    let task: SchedulerTaskModel
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: GTSpacing.md) {
            Button { onToggle?() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(task.isCompleted ? Color.gtDarkGreen : Color.gtBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gtDarkGreen)
                    }
                }
            }

            Text(task.taskType.icon).font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(task.plantName)
                    .font(GTFont.labelMedium())
                    .foregroundColor(task.isCompleted ? .gtTextMuted : .gtTextPrimary)
                    .strikethrough(task.isCompleted)
                Text(task.taskType.rawValue)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
            }

            Spacer()

            Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                .font(GTFont.labelSmall())
                .foregroundColor(.gtTextMuted)
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(task.isCompleted ? Color.gtPaleGreen.opacity(0.4) : .white)
                .gtShadow(GTShadow.card)
        )
        .opacity(task.isCompleted ? 0.65 : 1)
    }
}

struct GTCommunityPost: View {
    let post: CommunityPostModel
    var onLike: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.sm) {
            HStack(spacing: GTSpacing.xs) {
                Circle()
                    .fill(Color.gtPaleGreen)
                    .frame(width: 38, height: 38)
                    .overlay(Text("🌿").font(.system(size: 18)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorName)
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    Text(post.timestamp.formatted(.relative(presentation: .named)))
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                }
                Spacer()
            }

            Text(post.content)
                .font(GTFont.bodyMedium())
                .foregroundColor(.gtTextPrimary)

            HStack(spacing: GTSpacing.md) {
                Button { onLike?() } label: {
                    Label("\(post.likes)", systemImage: "heart")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                }
                Label("\(post.comments)", systemImage: "bubble.left")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
            }
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(.white)
                .gtShadow(GTShadow.card)
        )
    }
}

struct GTTimelineEntry: View {
    let entry: CareLogEntry
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: GTSpacing.md) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.gtPaleGreen)
                        .frame(width: 36, height: 36)
                    Text(entry.type == .watering ? "💧" :
                         entry.type == .fertilizing ? "🌿" :
                         entry.type == .pruning ? "✂️" : "📝")
                    .font(.system(size: 16))
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.gtBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.type.rawValue)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                Text(entry.note)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
            .padding(.bottom, isLast ? 0 : GTSpacing.lg)
        }
    }
}

struct GTAvatar: View {
    var name: String = ""
    var imageURL: String? = nil
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gtPaleGreen)
                .frame(width: size, height: size)
            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.gtDarkGreen)
        }
    }
}

struct GTQuestionCard: View {
    let question: QAQuestionModel

    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xs) {
            HStack {
                GTStatusBadge(
                    text: question.status.rawValue.capitalized,
                    backgroundColor: question.status == .answered ? Color.gtPaleGreen : Color(red:1,green:0.95,blue:0.85),
                    foregroundColor: question.status == .answered ? .gtDarkGreen : Color(red:0.7,green:0.5,blue:0)
                )
                Spacer()
                Text(question.timestamp.formatted(.relative(presentation: .named)))
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
            Text(question.title)
                .font(GTFont.labelLarge())
                .foregroundColor(.gtTextPrimary)
            Text(question.body)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .lineLimit(2)
            HStack(spacing: 4) {
                Image(systemName: "bubble.left")
                    .foregroundColor(.gtTextMuted)
                Text("\(question.answerCount) answers")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextMuted)
            }
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(.white)
                .gtShadow(GTShadow.card)
        )
    }
}
struct GTAlertBanner: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: GTSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: GTRadius.sm)
                    .fill(Color.gtStatusUrgent.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.gtStatusUrgent)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                Text(subtitle)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button { action?() } label: {
                Text(actionTitle)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtStatusUrgent)
                    .padding(.horizontal, GTSpacing.md)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().stroke(Color.gtStatusUrgent, lineWidth: 1.5)
                    )
            }
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(Color.gtStatusUrgent.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: GTRadius.md)
                        .stroke(Color.gtStatusUrgent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct GTAuthHeader: View {
    var title: String = "Welcome back,"
    var subtitle: String = "green gardener."
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.sm) {
            if let onBack {
                Button(action: onBack) {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 38, height: 38).gtShadow(GTShadow.card)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gtTextPrimary)
                    }
                }
                .padding(.top, GTSpacing.lg)
            }
            
            GTLogoHeader(iconSize: 30)
                .padding(.top, onBack == nil ? GTSpacing.lg : GTSpacing.xs)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GTFont.displaySmall())
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(GTFont.accentItalic())
                    .foregroundColor(.gtAccentGreen)
            }
            .padding(.top, GTSpacing.xxs)
            .padding(.bottom, GTSpacing.lg)
        }
        .padding(.horizontal, GTSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gtForestGreen)
    }
}

