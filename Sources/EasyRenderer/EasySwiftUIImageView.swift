//
//  File.swift
//  
//
//  Created by Twinkle Rathod on 31/05/24.
//

import Foundation
import SwiftUI

public struct EasySwiftUIRenderer<Placeholder>: View where Placeholder: View {

    // MARK: - Value
    // MARK: Private
    @State private var image: Image? = nil
    @State private var task: Task<(), Never>? = nil
    @State private var isProgressing = false

    private let url: URL?
    private let placeholder: () -> Placeholder?


    // MARK: - Initializer
    public init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
    }

    public init(url: URL?) where Placeholder == Color {
        self.init(url: url, placeholder: { Color.gray })
    }
    
    
    // MARK: - View
    // MARK: Public
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                placholderView
                imageView
                progressView
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .task {
                task?.cancel()
                task = Task.detached(priority: .background) {
                    await MainActor.run { isProgressing = true }
                
                    do {
                        let image = try await CombineNetworkManager.shared.download(url: url)
                    
                        await MainActor.run {
                            isProgressing = false
                            self.image = image
                        }
                    
                    } catch {
                        await MainActor.run { isProgressing = false }
                    }
                }
            }
            .onDisappear {
                task?.cancel()
            }
        }
    }
    
    // MARK: Private
    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            image
                .resizable()
                
        }
    }

    @ViewBuilder
    private var placholderView: some View {
        if !isProgressing, image == nil {
            placeholder()
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        if isProgressing {
            ProgressView()
                .progressViewStyle(.circular)
                .foregroundColor(.white)
        }
    }
}


#if DEBUG
struct ImageView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            EasySwiftUIRenderer(url: URL(string: "https://apod.nasa.gov/apod/image/2401/SarArcNz_McDonald_960.jpg"))
                .frame(width: 300, height: 300)
                .cornerRadius(20)
        
            EasySwiftUIRenderer(url: URL(string: "https://apod.nasa.gov/apod/image/2401/SarArcNz_McDonald_960")) {
                Text("⚠️")
                    .font(.system(size: 120))
            }
            .frame(width: 300, height: 300)
            .cornerRadius(20)
        }
    }
}
#endif
