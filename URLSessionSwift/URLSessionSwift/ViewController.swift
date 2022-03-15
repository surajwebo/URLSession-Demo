//
//  ViewController.swift
//  URLSessionSwift
//
//  Created by Suraj Mirajkar on 14/03/22.
//

import UIKit
import QuickLook

class ViewController: UIViewController, QLPreviewControllerDataSource {
    @IBOutlet weak var loaderIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    var filePathUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1.0
    }
    
    @IBAction func dataTaskRequest(_ sender: Any) {
        if imageView.image != nil {
            return
        }
        loaderIndicatorView.startAnimating()
        let request = NSMutableURLRequest(url: NSURL(string: "https://bit.ly/3tbBIrL")! as URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                print("Response: \(String(describing: response))")
                DispatchQueue.main.async {
                    if let data = data {
                        self.loaderIndicatorView.stopAnimating()
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }
        })
        task.resume()
    }
    
    @IBAction func downloadTaskRequest(_ sender: Any) {
        if launchFileIfExists() == true {
            return
        }
        guard let url = URL(string: "https://apple.co/3JdnQ5K") else {
            return
        }
        URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                print("Response: \(String(describing: response))")
                if let localURL = localURL {
                    do {
                        let str = try String(contentsOf: localURL)
                        if let url = self.filePathUrl {
                            // Write File to URL Path
                            try str.write(to: url, atomically: true, encoding: .utf8)
                            // Read File from URL Path
                            let input = try String(contentsOf: url)
                            print(input)
                            DispatchQueue.main.async {
                                // Open file in Quick Look
                                self.openDownloadedFile()
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }.resume()
    }
    
    func launchFileIfExists() -> Bool {
        var fileExists = false
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0]
        self.filePathUrl = documentsDirectory.appendingPathComponent("iTunesSearchResult.txt")
        let manager = FileManager.default
        if let filePathUrl = self.filePathUrl, manager.fileExists(atPath: filePathUrl.path) {
            // File Exists at Path
            fileExists = true
            DispatchQueue.main.async {
                // Open file in Quick Look
                self.openDownloadedFile()
            }
        }
        return fileExists
    }
    
}

extension ViewController {
    func openDownloadedFile() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = self.filePathUrl else {
            fatalError("Could not open file in QL")
        }
        return url as QLPreviewItem
    }
}


extension FileManager {
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dstURL.path) {
                try fileManager.removeItem(at: dstURL)
            }
            try fileManager.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at path \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}
