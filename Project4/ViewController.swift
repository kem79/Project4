//
//  ViewController.swift
//  Project4
//
//  Created by Marc on 18/09/2026.
//

import UIKit
import WebKit

// class must conform to WKNavigationDelegate so that it can act as a delegate to WK web view.
// parent class comes first, then protocols come after the comma
class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com"]
    
    // loadView() is run before viewDidLoad()
    override func loadView() {
        webView = WKWebView()
        // here, self must conform to WKNavigationDelegate
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2 steps to load a URL
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "open", style: .plain, target: self, action: #selector(openTapped))
        
        // 1. create tool bar items
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        // progress button
        // 1. create the progress view UI object
        progressView = UIProgressView(progressViewStyle: .bar)
        // fit the content fully
        progressView.sizeToFit()
        // 2. wrap the ui progress view object inside a toolbar button
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // 2. create toolbar
        // every view controller comes with a toolbarItems property
        toolbarItems = [progressButton, spacer, refresh]
        // 3. navigation controller controls the toolbar, make the toolbar visible
        navigationController?.isToolbarHidden = false
        
        // observe web page loading progress property
        // 1. add the observer to observe a key path
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: websites[0], style: .default, handler: openPage))
        ac.addAction(UIAlertAction(title: websites[1], style: .default, handler: openPage))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)
        webView.load(URLRequest(url: url!))
    }

     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // 2. observer: react to observed value change
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // allow/forbid navigation based on website whitelist - action "decidePolicyFor"
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void)
    {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
    }
}

