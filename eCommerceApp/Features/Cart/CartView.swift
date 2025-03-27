import SwiftUI

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}

class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    
    var total: Double {
        items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    func addItem(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                items[index].quantity = quantity
            } else {
                items.remove(at: index)
            }
        }
    }
}

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.items.isEmpty {
                    EmptyCartView()
                } else {
                    CartListView(viewModel: viewModel, showingCheckout: $showingCheckout)
                }
            }
            .navigationTitle("Cart")
            .sheet(isPresented: $showingCheckout) {
                CheckoutView(total: viewModel.total)
            }
        }
    }
}

struct CartListView: View {
    @ObservedObject var viewModel: CartViewModel
    @Binding var showingCheckout: Bool
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                CartItemRow(item: item, viewModel: viewModel)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.removeItem(viewModel.items[index])
                }
            }
            
            Section {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.total))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    showingCheckout = true
                }) {
                    Text("Proceed to Checkout")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .listRowInsets(EdgeInsets())
                .padding()
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var viewModel: CartViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                
                Text("$\(String(format: "%.2f", item.product.price))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                // Quantity Stepper
                Stepper(
                    value: Binding(
                        get: { item.quantity },
                        set: { viewModel.updateQuantity(for: item, quantity: $0) }
                    ),
                    in: 1...99
                ) {
                    Text("Quantity: \(item.quantity)")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some products to your cart")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CheckoutView: View {
    let total: Double
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Order Summary")) {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text("$\(String(format: "%.2f", total))")
                            .fontWeight(.bold)
                    }
                }
                
                Section(header: Text("Payment Method")) {
                    Picker("Payment Method", selection: .constant(0)) {
                        Text("Credit Card").tag(0)
                        Text("PayPal").tag(1)
                        Text("Apple Pay").tag(2)
                    }
                }
                
                Section {
                    Button(action: {
                        // Process payment
                    }) {
                        Text("Place Order")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
} 