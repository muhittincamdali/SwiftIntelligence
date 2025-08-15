import SwiftUI

// MARK: - Basic Card

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct BasicCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    public init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, y: 2)
    }
}

// MARK: - Profile Card

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ProfileCard: View {
    let name: String
    let subtitle: String
    let imageName: String?
    let imageURL: URL?
    let action: (() -> Void)?
    
    public init(
        name: String,
        subtitle: String,
        imageName: String? = nil,
        imageURL: URL? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.subtitle = subtitle
        self.imageName = imageName
        self.imageURL = imageURL
        self.action = action
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Group {
                        if let imageName = imageName {
                            Image(systemName: imageName)
                                .font(.title2)
                                .foregroundColor(.blue)
                        } else {
                            Text(name.prefix(2).uppercased())
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        .onTapGesture {
            action?()
        }
    }
}

// MARK: - Stats Card

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct StatsCard: View {
    let title: String
    let value: String
    let change: Double?
    let icon: String
    let color: Color
    
    public init(
        title: String,
        value: String,
        change: Double? = nil,
        icon: String,
        color: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.change = change
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                if let change = change {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text("\(abs(change), specifier: "%.1f")%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(change >= 0 ? .green : .red)
                }
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
}

// MARK: - Feature Card

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct FeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isNew: Bool
    
    public init(
        title: String,
        description: String,
        icon: String,
        color: Color = .blue,
        isNew: Bool = false
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.isNew = isNew
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Spacer()
                
                if isNew {
                    Text("NEW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [color.opacity(0.05), color.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Product Card

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ProductCard: View {
    let title: String
    let price: String
    let imageName: String
    let rating: Double
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onAddToCart: () -> Void
    
    public init(
        title: String,
        price: String,
        imageName: String,
        rating: Double = 0,
        isFavorite: Bool = false,
        onFavorite: @escaping () -> Void = {},
        onAddToCart: @escaping () -> Void = {}
    ) {
        self.title = title
        self.price = price
        self.imageName = imageName
        self.rating = rating
        self.isFavorite = isFavorite
        self.onFavorite = onFavorite
        self.onAddToCart = onAddToCart
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Image placeholder
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: imageName)
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                    )
                
                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Text("(\(rating, specifier: "%.1f"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(price)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: onAddToCart) {
                        Image(systemName: "cart.badge.plus")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}