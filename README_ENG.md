# WBMAnalytics

SDK for logging events in iOS applications. Events are sequentially grouped into batches and sent to the server. Configuration is supported for production and debug environments. The count of sent events and batches is tracked to control data loss. Events are stored in CoreData until they are sent. In case of network absence, events will be sent when the network becomes available.

## ⬇️ Install

The SDK is distributed via SPM, to add it to your project simply add to your project:

```
.package(url:"https://github.com/wildberries-tech/wba_analytics_sdk_ios.git",exact:  "3.4.0")
```

## 🚀 Launch in app

The application assumes one analytics instance that can support multiple receivers.

To create a WBAnalyticsReceiver instance, you need to pass several mandatory parameters to its initializer:
    
- **environment:** Application environment, can be .production or .test, if needed you can set your own apiKey .custom("apiKey"). ([example](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/blob/master/WBMAnalytics/WBMAnalyticsTestApp/AppDelegate.swift?ref_type%253Dheads#L31))
- **analyticsURL:** URL to which analytics data will be sent.
- **isFirstLaunch:** Flag indicating whether the current app launch is the first one. (stored somewhere in your code, for example in UserDefaults [example](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/blob/master/WBMAnalytics/WBMAnalyticsTestApp/AppDelegate.swift?ref_type%253Dheads#L30))
- **loggingOptions:** Logging settings, including logging level and file writing. [Details](.Docs/LoggingOptions.md)
- **networkTypeProvider:** Object providing information about the current network type.
- **batchConfig:** Batch data sending configuration.

For each receiver, you can set your own parameters and your own apiKey, then the receiver is passed to a single instance. After initialization, you need to set up the receiver.

Example receiver initialization:
```swift
let service = WBMAnalytics()

let apiKey = "<PUT API KEY HERE>"

let reciever1 = WBAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig()
)
reciever1.setup() // Important to setup before use

let reciever2 = WBAnalyticsReceiver(
    apiKey: "TestKey",
    isFirstLaunch: isFirstLaunch,
    loggingOptions: LoggingOptions.default,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig()
)

service.registerReceiver(reciever1)
service.registerReceiver(reciever2)

return service
```

## 🧑‍💻 Log events

### 1. Event Logging

To log events in the application, you can use the trackEvent method of the analytics service:
    
```swift
service.trackEvent(name: "EventName", parameters: [:])
```

Event Parameters

- **name:** Name of the event to be logged.
- **parameters:** Dictionary with additional event parameters. Keys should be strings (String), and values should be types that can be serialized to JSON.

Supported types for values:

    - String
    - Int
    - Double
    - Bool
    - [String: Any] (nested dictionaries) **where Any is a supported type**
    - [Any] (arrays, **where Any is a supported type**)
        
Example of logging an event with additional parameters:
```swift
let parameters: [String: Any] = [
    "user_id": 123,
    "screen_name": "MainScreen",
    "action": "button_click"
]

service.trackEvent(name: "UserInteraction", parameters: parameters)
```

### 2. User engagement logging

Every 30 seconds, "user_engagement" is automatically tracked. If you need to track manually, you can use trackUserEngagement with UserEngagement as parameters.

```swift
let userEngagement: UserEngagement = .init(screenName: "name", textSize: .large)
analytics.trackUserEngagement(userEngagement)
```

### 3. Custom parameters
To send your custom parameters in addition to the main ones in each request, there's a method setCommonParameters(_ parameters: [String:Any]). By adding the needed parameters to it, they will be added to every event (of this receiver).

Examples of setting custom parameters:
```swift
reciever.setCommonParameters(["client_id": 123])
// or for a specific receiver 
service.setCommonParameters(["client_id": 123], reciever.identifier) 
```
**IMPORTANT:** repeated use of setCommonParameters overwrites previously saved parameters (if any)

### 4. Track events with callback:
If you need to know whether your analytics event reached its destination, there's a trackEventWithCompletion method that can be used for a specific receiver or for all at once.

**IMPORTANT:** the event is sent individually and independently of all others. Use only if you're sure you need to know the result.

Usage example: 
``` swift
// 1
service.trackEventWithCompletion(name: "eventName", parameters: ["key":"123"], completion: { 
    print("result is success \($0))
})
// 2
service.trackEventWithCompletion(name: "eventName", parameters: ["key":"123"], receiverIdentifier: reciever.identifier, completion: { 
    print("result is success \($0))
})
```

### 5. Getting Attribution Data

The SDK supports the ability to get attribution data:

- `link`
- a set of custom parameters that are present in links.

Link example:

```bash
https://wildtracker.wb.ru/link?counterId=1&link=https://www.wildberries.ru/catalog/256870994/detail.aspx
```

At app startup, you need to call the following code:

```swift
analytics.checkAttribution { result in
            switch result {
            case .success(let response):
                guard let response else { return }
                // Here we got attribution data, we can work with it further
                print("[Attribution] Success: \(response)")
            case .failure(let error):
                print("[Attribution] Error: \(error)")
            }
        }
```

Example of handling deferred deep links through this system from the marketplace:

```swift
analyticsService.checkAttribution { result in
            switch result {
            case .success(let data):
                guard let data else { return }
                guard let link = data.link, let url = URL(string: link) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, completionHandler: nil)
                }
            case .failure(let error):
                break
            }
        }
```

## 📝 F.A.Q

 - **Do I need to call trackEvent not in the main queue?** 

Answer: No. The SDK manages the queue independently, you can call it from anywhere.

 - **How to specify the needed api key** 

Answer: each receiver has an environment parameter in the initializer .production/.test/.custom("YOU_API_KEY")

 - **How to pass the user token**

Answer: the setUserToken method saves the token and passes it in the x-user-token header of the request **(for all receivers)**

- **If the connection is lost, the user exits the app, etc. Will the analytics event reach its destination?**
 
Answer: we save events in CoreData and then send them in batches. In case an event **doesn't reach** the server, we try to send it again, other events wait. You can see more details in BatchWorker.swift 