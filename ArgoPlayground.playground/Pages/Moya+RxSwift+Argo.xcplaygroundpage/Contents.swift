//: [Previous](@previous)

import Moya
import Alamofire
import RxSwift
import Argo
import Curry
import XCPlayground

//: # Argo Code

struct InfoModel {
    let currentUserUrl: String
    let emojisUrl: String
    let eventsUrl: String
    let feedsUrl: String
}

extension InfoModel: Decodable {
    static func decode(json: JSON) -> Decoded<InfoModel> {
        return curry(InfoModel.init)
            <^> json <| "current_user_url"
            <*> json <| "emojis_url"
            <*> json <| "events_url"
            <*> json <| "feeds_url"
    }
}

struct EmojisModel {
    let plusOne: String
    let minusOne: String
    let airplane: String
    let zzz: String
}

extension EmojisModel: Decodable {
    static func decode(json: JSON) -> Decoded<EmojisModel> {
        return curry(EmojisModel.init)
            <^> json <| "+1"
            <*> json <| "-1"
            <*> json <| "airplane"
            <*> json <| "zzz"
    }
}

struct ErrorModel {
    let message: String
    let documentationUrl: String
}

extension ErrorModel: Decodable {
    static func decode(json: JSON) -> Decoded<ErrorModel> {
        return curry(ErrorModel.init)
            <^> json <| "message"
            <*> json <| "documentation_url"
    }
}

//: # Moya.Response+Argo and Observable+Argo code

//: This code is *heavily* influenced by [ivanbruel's Moya-ObjectMapper](https://github.com/ivanbruel/Moya-ObjectMapper). Many thanks for giving me the building blocks to be able to apply to parse Moya responses with Argo.
//: Similarly to how Moya-ObjectMapper was ported to a micro-framework, I think it would be useful to do the same with this solution for using Moya (or Moya+RxSwift or Moya+RAC) with Argo and would probably be appreciated by the community. I plan on doing this as my first contribution to OSS!!!

//: *Note:* I am declaring the generic type of the map functions as `mapDecodable<T: Decodable where T.DecodedType == T>` as opposed to `mapDecodable<T: Decodable>` based of [this Argo issue](https://github.com/thoughtbot/Argo/issues/98). Apparently, this is necessary because of the way Argo is implemented.

//: Moya.Response+Argo
extension Moya.Response {
    // Decode Object throwing Argo parsing error on failure.
    func mapDecodable<T: Decodable where T.DecodedType == T>() throws -> T {
        let decodable: Decoded<T> = decode(try mapJSON())
        switch decodable {
        case let .Success(value):
            return value
        case let .Failure(error):
            throw error
        }
    }
    
    // Decode Array throwing Argo parsing error on failure.
    func mapDecodable<T: Decodable where T.DecodedType == T>() throws -> [T] {
        let decodable: Decoded<[T]> = decode(try mapJSON())
        switch decodable {
        case let .Success(value):
            return value
        case let .Failure(error):
            throw error
        }
    }
    
    // Decode Object returning Decoded object to retain failure info.
    func mapDecodable<T: Decodable where T.DecodedType == T>() throws -> Decoded<T> {
        return decode(try mapJSON()) as Decoded<T>
    }
    
    // Decode Array returning Decoded object to retain failure info.
    func mapDecodable<T: Decodable where T.DecodedType == T>() throws -> Decoded<[T]> {
        return decode(try mapJSON()) as Decoded<[T]>
    }
}

//: Observable+Argo
extension ObservableType where E == Moya.Response {
    // Decode Object returning an observable of raw value type.
    func mapDecodable<T: Decodable where T.DecodedType == T>() -> Observable<T> {
        return flatMap { response -> Observable<T> in
            let value: T = try response.mapDecodable()
            return Observable.just(value)
        }
    }
    
    // Decode Array returning an observable of raw value type.
    func mapDecodable<T: Decodable where T.DecodedType == T>() -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            let value: [T] = try response.mapDecodable()
            return Observable.just(value)
        }
    }
    
    // Decode Object returning an observable of decoded type with failure info.
    func mapDecodable<T: Decodable where T.DecodedType == T>() -> Observable<Decoded<T>> {
        return flatMap { response -> Observable<Decoded<T>> in
            let decodable: Decoded<T> = try response.mapDecodable()
            return Observable.just(decodable)
        }
    }
    
    // Decode Array returning an observable of decoded type with failure info.
    func mapDecodable<T: Decodable where T.DecodedType == T>() -> Observable<Decoded<[T]>> {
        return flatMap { response -> Observable<Decoded<[T]>> in
            let decodable: Decoded<[T]> = try response.mapDecodable()
            return Observable.just(decodable)
        }
    }
}

//: # Moya/RxSwift code

//: More about using Moya with RxSwift can be found [here](https://github.com/Moya/Moya) and [here](https://github.com/Moya/Moya/blob/master/docs/RxSwift.md).

//: Allow for Asynchronous calls to be completed.
XCPSetExecutionShouldContinueIndefinitely(true)

//: Declare the two apis to test.
enum GithubAPI {
    case Info
    case Emojis
}

//: Define api specifics.
extension GithubAPI : TargetType {
    var path: String {
        switch self {
            
        case .Info:
            return ""
        case .Emojis:
            return "emojis"
        }
    }
    
    var base: String { return "https://api.github.com" }
    var baseURL: NSURL { return NSURL(string: base)! }
    
    var parameters: [String: AnyObject]? {
        return nil
    }
    
    var method: Moya.Method {
        return .GET
    }
    
    var sampleData: NSData {
        return NSData()
    }
}

//: Create RxMoyaProvider subclass.
class GithubProvider<T where T: TargetType>: RxMoyaProvider<T> {
    
    override init(endpointClosure: MoyaProvider<T>.EndpointClosure = MoyaProvider.DefaultEndpointMapping,
        requestClosure: MoyaProvider<T>.RequestClosure = MoyaProvider.DefaultRequestMapping,
        stubClosure: MoyaProvider<T>.StubClosure = MoyaProvider.NeverStub,
        manager: Manager = Alamofire.Manager.sharedInstance,
        plugins: [PluginType] = []) {
            
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins)
    }
}

//: Define provider singleton with a static endpoint closure.
struct Provider {
    private static let endpointClosure = { (target: GithubAPI) -> Endpoint<GithubAPI> in
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint = Endpoint<GithubAPI>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
        // Uncomment this line and use it instead to perform authenticated requests. This will allow you a rate limit of 5000 requests per hour. 
        // Sample access token header field call: ["Authorization": "token 123456789012345678901234567890"]
        // For information on generating a github access token, see the following link:
        // https://help.github.com/articles/creating-an-access-token-for-command-line-use/
        // return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "token <Insert token here>"])
        
        // Use this line to perform unauthenticated request. Doing this result in having a limit of 60 requests per hour, enforced by github's rate limit. For a request limit of 5000 per hour, authenticate your requests using the above code.
        return endpoint
    }
    
    static func DefaultProvider() -> GithubProvider<GithubAPI> {
        return GithubProvider(endpointClosure: endpointClosure)
    }
    
    private struct SharedProvider {
        static var instance = Provider.DefaultProvider()
    }
    
    private static var sharedProvider: GithubProvider<GithubAPI> {
        get {
        return SharedProvider.instance
        }
        
        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }
}

extension Provider {
    static func request(target: GithubAPI) -> Observable<Moya.Response> {
        return Provider.sharedProvider.request(target)
    }
    
    static func request(target: GithubAPI, completion: Moya.Completion) -> Cancellable {
        return Provider.sharedProvider.request(target, completion: completion)
    }
}

//: # Various sample api calls with various methods of parsing.

//: Parsing with Argo+RxSwift returning a model.
Provider.request(.Info)
    .mapDecodable()
    .subscribe { (event: Event<InfoModel>) in
        print(event)
        switch event {
        case .Next(let model):
            print(model)
        case .Error(let error): // This catches both Moya errors and Argo parsing errors!!
            print(error)
        default:
            break
        }
}

//: Parsing with Argo+RxSwift returning a Decoded.
Provider.request(.Info)
    .mapDecodable()
    .subscribe { (event: Event<Decoded<InfoModel>>) in
        print(event)
        switch event {
        case .Next(let decodedModel):
            switch decodedModel {
            case .Success(let model):
                print(model)
            case .Failure(let error): // This catches only Argo errors.
                print(error)
            }
        case .Error(let error): // This catches only Moya errors.
            print(error)
        default:
            break
        }
}

//: Parsing with Argo only.
Provider.request(.Info) { (response) in
    print(response)
    switch response {
    case .Success(let response):
        print(response)
        do {
            // Cast to Decoded InfoModel.
            if let decodedInfoModel: Decoded<InfoModel> = try response.mapDecodable() {
                print(decodedInfoModel)
            }
            
            // Cast to InfoModel.
            // For some reason, both of these Model casts are necessary to give the compile enough context to do the mapping.
            if let infoModel: InfoModel = try response.mapDecodable() as InfoModel {
                print(infoModel)
            }
        } catch {
            print("Parsing Error: \(error)")
        }
    case .Failure(let error):
        print(error)
    }
}

//: [Next](@next)
