import UIKit
import Foundation

struct CloudinaryService {
    
   
    private static let cloudName   = "dpphlrsjg"
    private static let uploadPreset = "green thumb"
    
   //upload an image and send it URL
    static func upload(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.badURL)
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
       
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        //upload preset fil
        body.appendFormField(name: "upload_preset", value: uploadPreset, boundary: boundary)
        
        //file field
        body.appendFileField(
            name: "file",
            fileName: "plant_\(Date().timeIntervalSince1970).jpg",
            mimeType: "image/jpeg",
            data: imageData,
            boundary: boundary
        )
        
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "Cloudinary", code: 0, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        //parse the URL from the JSON object
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let secureURL = json["secure_url"] as? String else {
            throw NSError(domain: "Cloudinary", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse image URL from response"])
        }
        
        print("Cloudinary: Image uploaded → \(secureURL)")
        return secureURL
    }
}

private extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
    
    mutating func appendFileField(name: String, fileName: String, mimeType: String, data: Data, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }
}
