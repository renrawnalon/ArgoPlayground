# ArgoPlayground

A simple project that imports the json parsing library [Argo](https://github.com/thoughtbot/Argo) and plays around with json decoding in an easy to manipulate playground format.

This project has now been split into two playground pages. The first page uses dummy json data to specifically test the various aspects of parsing with Argo. The second page, however, also imports [RxSwift](https://github.com/ReactiveX/RxSwift) and [Moya](https://github.com/Moya/Moya) in order to test parsing json results from real apis. I chose the Github api to test because it is public, easy to use, and it provides json blobs along with its various well defined errors, which is something else I wanted to test. Using this, I would like to attempt to intellegently parse both the json returned in the success case, as well as the json returned in the failure case.

Suggestions about how I could improve any of the code or thoughts on the concepts themselves are very welcome, so feel free to leave comments!

### Moya+Argo(+RxSwift)

In the second page, I reimplement ivanbruel's [Moya-ObjectMapper](https://github.com/ivanbruel/Moya-ObjectMapper) extension with Argo instead of [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) as the json parsing framework. Currently, I only have this solution implemented in this playground, but plan on turning it into a micro-framework like Moya-ObjectMapper so that other Argo users can easily use it as well.

Using the map functions of this extension, it becomes possible to write clean Moya code with free json parsing like this:

```
Provider.sharedProvider
    .request(.Info)
    .mapDecodable()
    .subscribe { (event: Event<InfoModel>) in
        switch event {
        case .Next(let model):
            print(model)
        case .Error(let error):
            print(error)
        default:
            break
        }
}
```

In this implementation, I provide functions that return either the raw value type T or the Decoded<T> type, leaving it to the user to decide how they wany their error information returned. In the case the T is the return type, the parsing error provided in `Decoded.Error(error)` is thrown and can be caught in either the `Error(error)` case of `Event<T>` from RxSwift's `Observable` or the `Failure(error)` case of `Response<T>` from Moya. This seems like the preferable solution, because it keeps all of the error logic in on place. The resulting code for making an api call would look something like this:

```
switch event { // (event: Event<InfoModel>)
case .Next(let model):
     print(model)
case .Error(let error): // This catches both Moya errors and Argo parsing errors!!
     print(error)
default:
     break
}
```

The alternitave would cause Moya errors and Argo errors to be returned to two different places, which doesn't make sense. The resuling code for making an api call would look like this:

```
switch event { // (event: Event<Decoded<InfoModel>>) 
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
```

Arguably, the first approach is much more userful and managable. In this project, I have included both solutions for the sake of completeness, but when released as a framework, it would probably make sense to exclude the second approach all together, in order to avoid confusion and bad practive.

### A note on authenticating the Github api

The code, as is, performs unauthenticated access to the [Github api](https://developer.github.com/v3/), which has an inherent request limit of 60 requests per hour. However, this limit can be increased to 5000 requests per hour by authenticating requests. This is easily done by providing an `access token` in the request header. Information on generating Github access tokens can be found [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use/), then authenticated requests can be performed by changing this:

```
private static let endpointClosure = { (target: GithubAPI) -> Endpoint<GithubAPI> in
	let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
	let endpoint = Endpoint<GithubAPI>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
	
	return endpoint
}
```

to this:

```
private static let endpointClosure = { (target: GithubAPI) -> Endpoint<GithubAPI> in
	let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
	let endpoint = Endpoint<GithubAPI>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
	
	 return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "token <Insert token here>"])
}
```

Here is an example of how the access token header field declaration looks with a dummy token:

```
["Authorization": "token 123456789012345678901234567890"]
```

# Installation

Run `pod install` with [CocoaPods](https://cocoapods.org/) 0.36 or newer.

Open ArgoTest.xcworkspace to edit playground with Cocoapods imports.

Run the blank project once to build the pods.

### Optional

Install [SwiftLint](https://github.com/realm/SwiftLint) using Homebrew to enforce Swift style and conventions.

```
brew install swiftlint
```

or

Go to [realm/SwiftLint](https://github.com/realm/SwiftLint) to build from source and get more information.
