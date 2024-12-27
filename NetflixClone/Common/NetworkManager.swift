import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

// 네트워크 로직이 필요할때 앱의 모든 곳에서 사용할 수 있는 싱글톤 네트워크 매니저.
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // 네트워크 로직을 수행하고, 결과를 Single 로 리턴함.
    // Single 은 오직 한 번만 값을 뱉는 Observable 이기 때문에 서버에서 데이터를 한 번 불러올 때 적절.
    func fetch<T: Decodable>(urlRequest: URLRequest) -> Single<T> {
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: urlRequest) { data, response, error in
                // 에러가 발생하면 Single에 fail 방출.
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                // 데이터가 없거나 HTTP 상태 코드가 성공 범위를 벗어나면 dataFetchFail 방출.
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    // 데이터를 JSON으로 디코딩하고 성공하면 success로 방출.
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodedData))
                } catch {
                    // 디코딩 실패 시 decodingFail 방출.
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
