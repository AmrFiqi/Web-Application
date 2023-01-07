//
//  ViewController.swift
//  SimpleBrowser
//
//  Created by Amr El-Fiqi on 06/01/2023.
//
import WebKit
import UIKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "twitter.com", "hackingwithswift.com"]
    var allowedWebsites = ["apple.com", "hackingwithswift.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        // Add space and refresh button
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        // Add progress bar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // Go back and forward buttons
        let back = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backClicked))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(forwardClicked))
        
        //fill toobaritems array with the created buttons and show the toolbar
        toolbarItems = [back, progressButton, forward, space, reload]
        navigationController?.isToolbarHidden = false
        
        //Adding observer to view the loading progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        
        // Do any additional setup after loading the view.
        let url = URL(string: "https://\(websites[0])")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        
    }
    
    // Add a button to open other links in websites array
    @objc func openTapped(){
        let ac = UIAlertController(title: "Open Page...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    //load the selected page
    func openPage(action: UIAlertAction){
        guard let actionTitle = action.title else {return}
        guard let url  = URL(string: "https://\(actionTitle)") else {return}
        
        // Check if the website is in the allowed websites list or show an error to the user
        if allowedWebsites.contains(actionTitle){
            webView.load(URLRequest(url: url))
        }
        else{
            let ac = UIAlertController(title: "Error", message: "This is a blocked website", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Return", style: .default))
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            
            present(ac, animated: true)
        }
        
    }
    
    // Set the page title
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    //Change the progress value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    //Allow the redirection to another website or not
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website){
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
    }
    
    // Go back to previous page
    @objc func backClicked (sender: UIBarButtonItem){
        if(webView.canGoBack) {
            //Go back in webview history
            webView.goBack()
        } else {
            //Pop view controller to preview view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
    // Go to the next page
    @objc func forwardClicked (sender: UIBarButtonItem){
        if(webView.canGoForward){
            webView.goForward()
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}


