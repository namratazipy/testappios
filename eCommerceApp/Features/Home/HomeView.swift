import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let imageURL: String
    let description: String
    let category: String
    let rating: Double
    let reviewCount: Int
}

class HomeViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var sortOption: SortOption = .featured
    @Published var currentPage = 1
    @Published var hasMorePages = true
    
    private let itemsPerPage = 10
    private var allProducts: [Product] = []
    
    enum SortOption: String, CaseIterable {
        case featured = "Featured"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case newest = "Newest"
        case highestRated = "Highest Rated"
    }
    
    var categories: [String] {
        Array(Set(products.map { $0.category })).sorted()
    }
    
    var filteredProducts: [Product] {
        var filtered = products
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply sorting
        switch sortOption {
        case .featured:
            filtered.sort { $0.rating > $1.rating }
        case .priceLowToHigh:
            filtered.sort { $0.price < $1.price }
        case .priceHighToLow:
            filtered.sort { $0.price > $1.price }
        case .newest:
            filtered.sort { $0.id.uuidString > $1.id.uuidString }
        case .highestRated:
            filtered.sort { $0.rating > $1.rating }
        }
        
        return filtered
    }
    
    var paginatedProducts: [Product] {
        let startIndex = (currentPage - 1) * itemsPerPage
        return Array(filteredProducts[startIndex..<min(startIndex + itemsPerPage, filteredProducts.count)])
    }
    
    init() {
        loadProducts()
    }
    
    private func loadProducts() {
        isLoading = true
        
        // Simulate API call with more products
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            self.allProducts = [
                Product(name: "iPhone 13 Pro", price: 999.99, imageURL: "iphone", description: "Latest iPhone with Pro camera system", category: "Electronics", rating: 4.8, reviewCount: 128),
                Product(name: "MacBook Pro", price: 1299.99, imageURL: "macbook", description: "Powerful laptop for professionals", category: "Electronics", rating: 4.9, reviewCount: 256),
                Product(name: "AirPods Pro", price: 249.99, imageURL: "airpods", description: "Wireless earbuds with noise cancellation", category: "Electronics", rating: 4.7, reviewCount: 89),
                Product(name: "iPad Pro", price: 799.99, imageURL: "ipad", description: "Pro tablet for creative work", category: "Electronics", rating: 4.6, reviewCount: 167),
                Product(name: "Nike Air Max", price: 129.99, imageURL: "nike", description: "Comfortable running shoes", category: "Sports", rating: 4.5, reviewCount: 45),
                Product(name: "Yoga Mat", price: 29.99, imageURL: "yoga", description: "Premium yoga mat", category: "Sports", rating: 4.3, reviewCount: 78),
                Product(name: "Leather Wallet", price: 49.99, imageURL: "wallet", description: "Genuine leather wallet", category: "Accessories", rating: 4.4, reviewCount: 34),
                Product(name: "Sunglasses", price: 159.99, imageURL: "sunglasses", description: "Designer sunglasses", category: "Accessories", rating: 4.2, reviewCount: 92),
                Product(name: "Coffee Maker", price: 79.99, imageURL: "coffee", description: "Automatic coffee maker", category: "Home", rating: 4.6, reviewCount: 156),
                Product(name: "Smart Watch", price: 299.99, imageURL: "watch", description: "Fitness tracking smartwatch", category: "Electronics", rating: 4.7, reviewCount: 203),
                Product(name: "Gaming Console", price: 499.99, imageURL: "console", description: "Next-gen gaming console", category: "Electronics", rating: 4.8, reviewCount: 312),
                Product(name: "Wireless Mouse", price: 39.99, imageURL: "mouse", description: "Ergonomic wireless mouse", category: "Electronics", rating: 4.3, reviewCount: 67),
                Product(name: "Running Shoes", price: 89.99, imageURL: "shoes", description: "Professional running shoes", category: "Sports", rating: 4.6, reviewCount: 145),
                Product(name: "Dumbbell Set", price: 149.99, imageURL: "dumbbell", description: "Adjustable dumbbell set", category: "Sports", rating: 4.7, reviewCount: 89),
                Product(name: "Backpack", price: 69.99, imageURL: "backpack", description: "Water-resistant backpack", category: "Accessories", rating: 4.5, reviewCount: 112),
                Product(name: "Smart TV", price: 799.99, imageURL: "tv", description: "4K Smart TV", category: "Electronics", rating: 4.8, reviewCount: 234),
                Product(name: "Blender", price: 59.99, imageURL: "blender", description: "High-speed blender", category: "Home", rating: 4.4, reviewCount: 78),
                Product(name: "Desk Chair", price: 129.99, imageURL: "chair", description: "Ergonomic office chair", category: "Home", rating: 4.6, reviewCount: 167),
                Product(name: "Wireless Keyboard", price: 79.99, imageURL: "keyboard", description: "Mechanical keyboard", category: "Electronics", rating: 4.5, reviewCount: 98),
                Product(name: "Fitness Tracker", price: 199.99, imageURL: "fitness", description: "Advanced fitness tracker", category: "Electronics", rating: 4.7, reviewCount: 178)
            ]
            
            self.products = Array(self.allProducts.prefix(self.itemsPerPage))
            self.isLoading = false
        }
    }
    
    func loadMoreIfNeeded(currentProduct product: Product) {
        let thresholdIndex = products.index(products.endIndex, offsetBy: -5)
        if products.firstIndex(where: { $0.id == product.id }) ?? 0 >= thresholdIndex {
            loadMoreProducts()
        }
    }
    
    private func loadMoreProducts() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        // Simulate API call for more products
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            let startIndex = self.products.count
            let endIndex = min(startIndex + self.itemsPerPage, self.allProducts.count)
            
            if startIndex < self.allProducts.count {
                let newProducts = Array(self.allProducts[startIndex..<endIndex])
                self.products.append(contentsOf: newProducts)
                self.hasMorePages = endIndex < self.allProducts.count
            } else {
                self.hasMorePages = false
            }
            
            self.isLoading = false
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedProduct: Product?
    @State private var showingFilters = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding()
                    
                    // Category ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: {
                                        viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    
                    // Sort Button
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(HomeViewModel.SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    viewModel.sortOption = option
                                }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if viewModel.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(viewModel.sortOption.rawValue)
                            }
                            .foregroundColor(ColorTheme.primary)
                        }
                        .padding(.horizontal)
                    }
                    
                    if viewModel.isLoading && viewModel.products.isEmpty {
                        ProgressView()
                            .padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.paginatedProducts) { product in
                                ProductCard(product: product)
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded(currentProduct: product)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Products")
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.textSecondary)
            
            TextField("Search products...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? ColorTheme.primary : Color.white)
                .foregroundColor(isSelected ? .white : ColorTheme.text)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack {
                Color.gray.opacity(0.1)
                Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .cornerRadius(15)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(ColorTheme.accent)
                        Text(String(format: "%.1f", product.rating))
                            .font(.caption)
                    }
                }
                
                Text(product.category)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct ProductDetailView: View {
    let product: Product
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity = 1
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Product Image
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("$\(String(format: "%.2f", product.price))")
                                .font(.title2)
                                .foregroundColor(ColorTheme.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(ColorTheme.accent)
                                Text(String(format: "%.1f", product.rating))
                                Text("(\(product.reviewCount))")
                                    .foregroundColor(ColorTheme.textSecondary)
                            }
                        }
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        // Quantity Selector
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    if quantity > 1 { quantity -= 1 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(ColorTheme.primary)
                                }
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(width: 40)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(ColorTheme.primary)
                                }
                            }
                        }
                        
                        Button(action: {
                            // Simulate adding to cart
                            showingSuccessAlert = true
                        }) {
                            Text("Add to Cart")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [ColorTheme.primary, ColorTheme.secondary]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("\(quantity) \(product.name) added to cart"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 