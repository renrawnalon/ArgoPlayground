# ArgoPlayground

A simple project that imports the json parsing library Argo and plays around with json decoding in an easy to manipulate playground format.

This project has now been split into two playground pages. The first page uses dummy json data to specifically test the various aspects of parsing with Argo. The second page, however, also imports RxSwift and Moya in order to test parsing json results from real apis. I chose the Github api to test because it is public, easy to use, and it provides json blobs along with its various well defined errors, which is something else I wanted to test. Using this, I would like to attempt to intellegently parse both the json returned in the success case, as well as the json returned in the failure case.

The code, as is, performs unauthenticated access to the Github api, which has an inherent request limit of 60 requests per hour. However, this limit can be increased to 5000 requests per hour by authenticating requests. This is easilt done by providing an `access token` in the request header. Information on generating Github access tokens can be found [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use/), then authenticated requests can be performed by changing this:

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

Suggestions about how I could improve any of the code or thoughts on the concepts themselves are very welcome, so feel free to leave comments!

# Installation

Run `pod install` with CocoaPods 0.36 or newer.

Open ArgoTest.xcworkspace to edit playground with Cocoapods imports.

Run the blank project once to build the pods.

### Optional

Install SwiftLint using Homebrew to enforce Swift style and conventions.

```
brew install swiftlint
```

or

Go to [realm/SwiftLint](https://github.com/realm/SwiftLint) to build from source and get more information.
