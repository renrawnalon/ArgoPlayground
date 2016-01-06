//: [Previous](@previous)

import Moya
import Alamofire
import RxSwift
import Argo
import Curry
import XCPlayground

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
    
    static func request(target: GithubAPI, completion: Moya.Completion) -> Cancellable {
        return Provider.sharedProvider.request(target, completion: completion)
    }
}

//: Make request whos response will be parsed with Argo.
Provider.sharedProvider.request(.Info).subscribe { (event) in
    print(event)
    switch event {
    case .Next(let response):
        print(String(data: response.data, encoding: NSUTF8StringEncoding))
    case .Error(let error):
        print(error)
    default:
        break
    }
}

//: [Next](@next)
