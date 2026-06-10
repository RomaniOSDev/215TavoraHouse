import UIKit

enum ExportService {
    static func createPDF(from text: String) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let attributed = NSAttributedString(string: text, attributes: attributes)
            attributed.draw(in: pageRect.insetBy(dx: 40, dy: 40))
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("learning_summary_\(Int(Date().timeIntervalSince1970)).pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    static func createTextFile(from text: String) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("learning_summary_\(Int(Date().timeIntervalSince1970)).txt")
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
