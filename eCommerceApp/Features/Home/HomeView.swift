import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let imageURL: String
    let description: String
}

class HomeViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    
    init() {
        loadProducts()
    }
    
    private func loadProducts() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.products = [
                Product(name: "iPhone 13 Pro", price: 999.99, imageURL: "iphone", description: "Latest iPhone with Pro camera system"),
                Product(name: "MacBook Pro", price: 1299.99, imageURL: "macbook", description: "Powerful laptop for professionals"),
                Product(name: "AirPods Pro", price: 249.99, imageURL: "airpods", description: "Wireless earbuds with noise cancellation"),
                Product(name: "iPad Pro", price: 799.99, imageURL: "ipad", description: "Pro tablet for creative work")
            ]
            self?.isLoading = false
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedProduct: Product?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.products) { product in
                            ProductCard(product: product)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Products")
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            // Product Image
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ProductDetailView: View {
    let product: Product
    @Environment(\.presentationMode) var presentationMode
    
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
                        
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // Add to cart action
                        }) {
                            Text("Add to Cart")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 