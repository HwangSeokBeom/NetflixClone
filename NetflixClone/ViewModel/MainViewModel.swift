import Foundation
import RxSwift

class MainViewModel {
    /// 구독 해제를 위한 DisposeBag.
    private let disposeBag = DisposeBag()
    
    /// View 가 구독할 Subject.
    let popularMovieSubject = BehaviorSubject(value: [Movie]())
    let topRatedMovieSubject = BehaviorSubject(value: [Movie]())
    let upcomingMovieSubject = BehaviorSubject(value: [Movie]())
    
    init() {
        fetchPopularMovie()
        fetchTopRatedMovie()
        fetchUpcomingMovie()
    }
    
    private func createRequest(endpoint: String) -> URLRequest? {
        let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NzMwZjliYTk4YjA4ZGIyZDIyOTdmZDM2MWUyODZkZSIsIm5iZiI6MTczNDA2MzgyMy4zNDYsInN1YiI6IjY3NWJiNmNmNWFjYzU2MDQ0Mjg4ZjMzZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FnqOgEtvM3Ul1GRoYlFzFzuIuiofw7dq40Uo-HLDlZM"
        guard var components = URLComponents(string: "https://api.themoviedb.org/3\(endpoint)") else { return nil }
    
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
   
    /// Popular Movie 데이터를 불러온다.
    /// ViewModel 에서 수행해야 할 비즈니스로직.
    func fetchPopularMovie() {
        // 잘못된 URL 인 경우 Subject 에서 에러가 방출되도록 함.
        guard let request = createRequest(endpoint: "/movie/popular") else {
            popularMovieSubject.onError(NetworkError.invalidUrl)
              return
          }
        // 이 네트워크 fetch 의 결과는 Single 타입이기 때문에, 구독할 수 있다.
        // NetworkManager 의 fetch 메서드의 Single 로 부터 흘러나온 데이터를,
        // 그대로 ViewModel 의 subject 로 그대로 물 흐르듯 흘려보내고 있다.
        // 그리고 View 에서는 이 subject 를 구독하고 있다가 데이터가 발행 된 순간 그에 맞는 행동을 할 것이다.
        // 이러한 특성 때문에 Observable 은 "데이터를 스트림으로 관리한다" 고 표현할 수 있다.
        NetworkManager.shared.fetch(urlRequest: request)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.popularMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.popularMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTopRatedMovie() {
        guard let request = createRequest(endpoint: "/movie/top_rated") else {
               topRatedMovieSubject.onError(NetworkError.invalidUrl)
               return
           }
        NetworkManager.shared.fetch(urlRequest: request)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.topRatedMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.topRatedMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchUpcomingMovie() {
        guard let request = createRequest(endpoint: "/movie/upcoming") else {
            upcomingMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(urlRequest: request)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.upcomingMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.upcomingMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    

    // movieId로부터 예고편 영상 URL을 얻어온다.
    func fetchTrailerURL(movie: Movie) -> Single<URL> {
        guard let movieId = movie.id else {
            return Single.error(NetworkError.dataFetchFail)
        }
        
        guard let request = createRequest(endpoint: "/movie/\(movieId)/videos") else {
            return Single.error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(urlRequest: request)
            .flatMap { (videoResponse: VideoResponse) -> Single<URL> in
                if let trailer = videoResponse.results.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }),
                   let videoURL = URL(string: "https://www.youtube.com/watch?v=\(trailer.key)") {
                    return Single.just(videoURL)
                } else {
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }

    // movieId로부터 예고편 영상 키를 얻어온다.
    func fetchTrailerKey(movie: Movie) -> Single<String> {
        guard let movieId = movie.id else {
            return Single.error(NetworkError.dataFetchFail)
        }
        
        guard let request = createRequest(endpoint: "/movie/\(movieId)/videos") else {
            return Single.error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(urlRequest: request)
            .flatMap { (videoResponse: VideoResponse) -> Single<String> in
                if let trailer = videoResponse.results.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }) {
                    if let key = trailer.key {
                        return Single.just(key)
                    } else {
                        return Single.error(NetworkError.dataFetchFail)
                    }
                } else {
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }
}
