//
//  PaymentWebViewController.swift
// NewBase
//
//  Created by Mohamed Hadwa on 10/07/2025.
//
import UIKit
import WebKit

class PaymentWebViewController: UIViewController, WKNavigationDelegate {
    
    var url: URL!
    private var webView: WKWebView!
    
    var onPaymentAccepted: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment".localized
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel".localized,
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let urlStr = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        print("➡️ Navigating to:", urlStr)
        
        // ✅ Payment success → close webview
        if urlStr.contains("orders/accepted-form") {
            print("✅ Payment Accepted")
            
            decisionHandler(.cancel)
            
            dismiss(animated: true) {
                self.onPaymentAccepted?()
            }
            return
        }
        
        // ✅ Payment status → open normally inside webview
        if urlStr.contains("/payment/get-payment-status") {
            print("📄 Opening payment status page")
            
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let urlStr = webView.url?.absoluteString else { return }
        
        print("✅ Page finished loading:", urlStr)

        if urlStr.contains("result") {
            print("🎉 Payment finished → dismissing")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismiss(animated: true) {
                    self.onPaymentAccepted?()
                }
            }
        }
    }
}
