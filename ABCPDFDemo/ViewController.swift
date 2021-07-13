//
//  ViewController.swift
//  ABCPDFDemo
//
//  Created by Wil Ferrel on 5/9/21.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    let emptyGoodBallot: String = "part1_original"
    let misalignedBallot: String = "part1"
    let macUserNameDirectory: String = "Wil"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load original pds with annotation
        if let url = Bundle.main.url(forResource: emptyGoodBallot,
                                     withExtension: ".pdf") {
            let document = PDFDocument(url: url)
            guard let page1 = document!.page(at: 0) else { return }
            _ = page1.annotations.map {
                print("Annotation Properties => \(String(describing: $0.fieldName))")
                if let fieldName = $0.fieldName {
                    switch fieldName {
                    case "mayor.write-in-text":
                        $0.widgetStringValue = "Mayor One"
                        break
                    case "control_board.write-in-text" :
                        $0.widgetStringValue = "Mayor Two"
                        break
                    default:
                        page1.addAnnotation(fillInForAnnotation($0))
                    }
                }
            }

            document?.write(to: urlForNewPDF())

        }
    }

    // Fill in object using pre-created image
    func fillInForAnnotation(_ annotation: PDFAnnotation) -> PDFAnnotation {
        let image = UIImage(named: "Filled_In_Oval")
        let annotationHeight = annotation.bounds.size.height
        let annotationWidth = annotation.bounds.size.width

        let imageAnnotation = PDFImageAnnotation(image, bounds: CGRect(x: annotation.bounds.origin.x, y: annotation.bounds.origin.y+5, width: annotationWidth, height: annotationHeight/2), properties: nil)
        return imageAnnotation
    }

    func urlForNewPDF() -> URL {
        // If running on simulator save file in username provided Desktop
        #if targetEnvironment(simulator)
        let path = URL(string: "file:///Users/\(macUserNameDirectory)/Desktop/PDFKit/awesomeBallot.pdf")!
        #else
        // If running on device save file in App Documents Directory
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("awesomeBallot.pdf")
        #endif
        print(path)
        return path
    }

}

extension URL {
    static func localURLForXCAsset(name: String) -> URL? {
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            guard let image = UIImage(named: name), let data = image.pngData() else {return nil}
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
        return url
    }
}

// Custom class that creates annotation of with image, this gets drawn in to provide CGRect
class PDFImageAnnotation: PDFAnnotation {

    var image: UIImage?

    convenience init(_ image: UIImage?, bounds: CGRect, properties: [AnyHashable: Any]?) {
        self.init(bounds: bounds, forType: .ink, withProperties: properties)
        self.image = image
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)

         // Drawing the image within the annotation's bounds.
        guard let cgImage = image?.cgImage else { return }
        context.draw(cgImage, in: bounds)
    }
}
