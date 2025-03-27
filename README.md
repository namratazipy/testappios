# eCommerce iOS App

A modern iOS eCommerce application built with SwiftUI and MVVM architecture.

## Features

- User Authentication
- Product Browsing
- Shopping Cart
- Checkout Process
- User Profile Management
- Modern UI/UX Design

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+
- CocoaPods (for dependency management)

## Installation

1. Clone the repository
2. Open Terminal and navigate to the project directory
3. Install dependencies:
   ```bash
   pod install
   ```
4. Open `eCommerceApp.xcworkspace` in Xcode
5. Build and run the project

## Project Structure

```
eCommerceApp/
├── App/
│   └── eCommerceAppApp.swift
├── Features/
│   ├── Authentication/
│   ├── Home/
│   ├── ProductDetails/
│   ├── Cart/
│   ├── Checkout/
│   └── Profile/
├── Core/
│   ├── Models/
│   ├── ViewModels/
│   ├── Services/
│   └── Utils/
├── UI/
│   ├── Components/
│   ├── Styles/
│   └── Resources/
└── Network/
    ├── API/
    └── Endpoints/
```

## Dependencies

- Alamofire: For network requests
- Kingfisher: For image loading and caching
- SwiftUI-Introspect: For custom UI components
- Combine: For reactive programming

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture with the following principles:

- SwiftUI for modern UI development
- Combine for reactive programming
- Protocol-oriented programming
- Dependency injection
- Clean Architecture principles

## Getting Started

1. Set up your development environment
2. Install required dependencies
3. Configure API endpoints in `Network/API/APIConfig.swift`
4. Build and run the project

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request # testappios
