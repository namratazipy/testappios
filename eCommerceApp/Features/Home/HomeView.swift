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
    
    func loadProducts() {
        guard products.isEmpty else { return }  // Only load if products are empty
        isLoading = true
        
        // Simulate API call with more products
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.allProducts = [
                // Sports Category
                Product(name: "Nike Air Max", price: 129.99, imageURL: "nike", description: "Comfortable running shoes for professional athletes", category: "Sports", rating: 4.5, reviewCount: 45),
                Product(name: "Yoga Mat Premium", price: 29.99, imageURL: "yoga", description: "Premium yoga mat with extra cushioning", category: "Sports", rating: 4.3, reviewCount: 78),
                Product(name: "Training Gloves", price: 24.99, imageURL: "gloves", description: "Professional training gloves", category: "Sports", rating: 4.4, reviewCount: 56),
                Product(name: "Running Shoes Pro", price: 89.99, imageURL: "shoes", description: "Professional running shoes with advanced cushioning", category: "Sports", rating: 4.6, reviewCount: 145),
                Product(name: "Dumbbell Set", price: 149.99, imageURL: "dumbbell", description: "Adjustable dumbbell set for home gym", category: "Sports", rating: 4.7, reviewCount: 89),
                Product(name: "Basketball", price: 29.99, imageURL: "basketball", description: "Professional indoor/outdoor basketball", category: "Sports", rating: 4.5, reviewCount: 67),
                Product(name: "Tennis Racket", price: 79.99, imageURL: "tennis", description: "Professional tennis racket", category: "Sports", rating: 4.6, reviewCount: 34),
                Product(name: "Gym Bag", price: 39.99, imageURL: "gym_bag", description: "Spacious gym bag with compartments", category: "Sports", rating: 4.4, reviewCount: 91),
                
                // Electronics Category
                Product(name: "iPhone 13 Pro", price: 999.99, imageURL: "iphone", description: "Latest iPhone with Pro camera system", category: "Electronics", rating: 4.8, reviewCount: 128),
                Product(name: "MacBook Pro", price: 1299.99, imageURL: "macbook", description: "Powerful laptop for professionals", category: "Electronics", rating: 4.9, reviewCount: 256),
                Product(name: "AirPods Pro", price: 249.99, imageURL: "airpods", description: "Wireless earbuds with noise cancellation", category: "Electronics", rating: 4.7, reviewCount: 89),
                
                // Home Category
                Product(name: "Coffee Maker", price: 79.99, imageURL: "coffee", description: "Automatic coffee maker", category: "Home", rating: 4.6, reviewCount: 156),
                Product(name: "Smart TV", price: 799.99, imageURL: "tv", description: "4K Smart TV", category: "Home", rating: 4.8, reviewCount: 234),
                Product(name: "Blender", price: 59.99, imageURL: "blender", description: "High-speed blender", category: "Home", rating: 4.4, reviewCount: 78),
                
                // Accessories Category
                Product(name: "Leather Wallet", price: 49.99, imageURL: "wallet", description: "Genuine leather wallet", category: "Accessories", rating: 4.4, reviewCount: 34),
                Product(name: "Sunglasses", price: 159.99, imageURL: "sunglasses", description: "Designer sunglasses", category: "Accessories", rating: 4.2, reviewCount: 92),
                Product(name: "Backpack", price: 69.99, imageURL: "backpack", description: "Water-resistant backpack", category: "Accessories", rating: 4.5, reviewCount: 112)
            ]
            
            self.products = self.allProducts
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
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
                                NavigationLink(destination: CategoryView(category: category)) {
                                    CategoryButton(
                                        title: category,
                                        isSelected: viewModel.selectedCategory == category,
                                        action: {}
                                    )
                                }
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
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var quantity = 1
    
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
                            .padding(.vertical, 8)
                        
                        // Quantity Selector
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    if quantity > 1 { quantity -= 1 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(ColorTheme.primary)
                                        .font(.title2)
                                }
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(width: 40)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    if quantity < 99 { quantity += 1 }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(ColorTheme.primary)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Total Price
                        HStack {
                            Text("Total Price")
                                .font(.headline)
                            Spacer()
                            Text("$\(String(format: "%.2f", product.price * Double(quantity)))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTheme.primary)
                        }
                        .padding(.vertical, 8)
                        
                        Button(action: {
                            cartViewModel.addItem(product, quantity: quantity)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Add to Cart")
                                    .fontWeight(.bold)
                            }
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
        }
    }
}

struct CategoryView: View {
    let category: String
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedProduct: Product?
    
    var body: some View {
        if category == "Sports" {
            SportsView(viewModel: viewModel)
                .onAppear {
                    viewModel.loadProducts()
                }
        } else {
            ProductListView(category: category, viewModel: viewModel)
                .onAppear {
                    viewModel.loadProducts()
                }
        }
    }
}

struct ProductListView: View {
    let category: String
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedProduct: Product?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredProducts: [Product] {
        viewModel.products.filter { $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Category Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(filteredProducts.count) items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Products Grid
                if filteredProducts.isEmpty {
                    Text("No products found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(category)
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
}

struct SportsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedProduct: Product?
    @State private var selectedSubcategory: String = "All"
    @State private var sortOption: HomeViewModel.SortOption = .featured
    @State private var selectedSubcategoryForDetail: String?
    
    let subcategories = ["All", "Running", "Yoga", "Training", "Team Sports"]
    
    var filteredProducts: [Product] {
        var products = viewModel.products.filter { $0.category == "Sports" }
        
        if selectedSubcategory != "All" {
            products = products.filter { $0.description.localizedCaseInsensitiveContains(selectedSubcategory) }
        }
        
        switch sortOption {
        case .priceLowToHigh:
            products.sort { $0.price < $1.price }
        case .priceHighToLow:
            products.sort { $0.price > $1.price }
        case .highestRated:
            products.sort { $0.rating > $1.rating }
        default:
            break
        }
        
        return products
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Subcategories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(subcategories, id: \.self) { subcategory in
                            if subcategory != "All" {
                                NavigationLink(destination: SubcategoryDetailView(subcategory: subcategory, products: filteredProducts)) {
                                    CategoryButton(
                                        title: subcategory,
                                        isSelected: selectedSubcategory == subcategory,
                                        action: {
                                            selectedSubcategory = subcategory
                                        }
                                    )
                                }
                            } else {
                                CategoryButton(
                                    title: subcategory,
                                    isSelected: selectedSubcategory == subcategory,
                                    action: {
                                        selectedSubcategory = subcategory
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Sort Options
                HStack {
                    Spacer()
                    Menu {
                        ForEach(HomeViewModel.SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                sortOption = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortOption.rawValue)
                        }
                        .foregroundColor(ColorTheme.primary)
                    }
                }
                .padding(.horizontal)
                
                if filteredProducts.isEmpty {
                    Text("No products found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Featured Items
                    if selectedSubcategory == "All" {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Featured Items")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                NavigationLink(destination: FeaturedItemsView(products: filteredProducts)) {
                                    Text("See All")
                                        .foregroundColor(ColorTheme.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(filteredProducts.prefix(3)) { product in
                                        FeaturedProductCard(product: product)
                                            .onTapGesture {
                                                selectedProduct = product
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Products Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCard(product: product)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
}

struct SubcategoryDetailView: View {
    let subcategory: String
    let products: [Product]
    @State private var selectedProduct: Product?
    @State private var showingFilter = false
    @State private var priceRange: ClosedRange<Double> = 0...1000
    
    var filteredProducts: [Product] {
        products.filter { product in
            product.description.localizedCaseInsensitiveContains(subcategory) &&
            product.price >= priceRange.lowerBound &&
            product.price <= priceRange.upperBound
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with filter button
                HStack {
                    Text("\(filteredProducts.count) items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        showingFilter.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(ColorTheme.primary)
                    }
                }
                .padding()
                
                // Products Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredProducts) { product in
                        ProductCard(product: product)
                            .onTapGesture {
                                selectedProduct = product
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(subcategory)
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .sheet(isPresented: $showingFilter) {
            FilterView(priceRange: $priceRange)
        }
    }
}

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var priceRange: ClosedRange<Double>
    @State private var lowerBound: Double
    @State private var upperBound: Double
    
    init(priceRange: Binding<ClosedRange<Double>>) {
        self._priceRange = priceRange
        self._lowerBound = State(initialValue: priceRange.wrappedValue.lowerBound)
        self._upperBound = State(initialValue: priceRange.wrappedValue.upperBound)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Price Range")) {
                    VStack {
                        HStack {
                            Text("$\(Int(lowerBound))")
                            Spacer()
                            Text("$\(Int(upperBound))")
                        }
                        
                        RangeSlider(value: Binding(
                            get: { lowerBound...upperBound },
                            set: { newValue in
                                lowerBound = newValue.lowerBound
                                upperBound = newValue.upperBound
                            }
                        ), in: 0...1000)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Apply") {
                    priceRange = lowerBound...upperBound
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct RangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    init(value: Binding<ClosedRange<Double>>, in bounds: ClosedRange<Double>) {
        self._value = value
        self.bounds = bounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Slider(value: Binding(
                    get: { value.lowerBound },
                    set: { value = $0...value.upperBound }
                ), in: bounds)
                
                Slider(value: Binding(
                    get: { value.upperBound },
                    set: { value = value.lowerBound...$0 }
                ), in: bounds)
            }
        }
    }
}

struct FeaturedItemsView: View {
    let products: [Product]
    @State private var selectedProduct: Product?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(products) { product in
                    FeaturedProductCard(product: product)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedProduct = product
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Featured Items")
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
}

struct FeaturedProductCard: View {
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
            .frame(width: 200, height: 200)
            .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.primary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(ColorTheme.accent)
                    Text(String(format: "%.1f", product.rating))
                        .font(.caption)
                    Text("(\(product.reviewCount))")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 

