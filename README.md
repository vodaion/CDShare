# CDShare - CoreData Share

[![CI Status](https://img.shields.io/travis/vadeara/CDShare.svg?style=flat)](https://travis-ci.org/vadeara/CDShare)
[![Version](https://img.shields.io/cocoapods/v/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)
[![License](https://img.shields.io/cocoapods/l/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)
[![Platform](https://img.shields.io/cocoapods/p/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)

## Info
This work was inspired by how Apple iWork office suite applications work in iOS and a specific feature of how the documents are sharing between apps even in offline mode.

### `CDShare` will answer the question: <br> How do we share CoreData between `2*n` application, where n >= 1? ###
Before to go direct to the subject, let's have a short introduction for each part that is touched in this tutorial.
More details ![here:](https://github.com/vadeara/CDShare/wiki)
# Example description #

## Setup

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
```
iOS 11.0+ 
Xcode 10
```

## Installation
CDShare is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CDShare'
```

Under the Example folder, you will find a project of how to use the `CDShare.framework`.
The project will contain a showcase for an Application and an Extension for it and they will share the CoreData.

The logic of the framework looks like this:
1. Create a class/struct that implement `ApplicationGroupInfo` protocol. 
```swift
struct ApplicationGroupInfoModel: ApplicationGroupInfo {
    var group: ApplicationIdentifier = ApplicationIdentifierModel(identifier: "group.voda.the.cdshare")
    var reading: ApplicationIdentifier = ApplicationIdentifierModel(identifier: "com.CDShareExample")
    var writing: [ApplicationIdentifier] = [ApplicationIdentifierModel(identifier: "com.CDShareExample.CDShareExampleToday")]
}
```
You can have diferent context for reading and writing, for the sake of the example I did use the same context.

Each parameter of the `ApplicationGroupInfo` protocol require to be descedent of the `ApplicationIdentifier` protocol.
```swift
struct ApplicationIdentifierModel: ApplicationIdentifier {
    var identifier: String
}
```
2. Create the `CoreDataShareConfiguration` instance.
```swift
let context: NSManagedObjectContext = ...
let configuration = try! CoreDataShareConfiguration(ApplicationGroupInfoModel(), readingContext: context, writingContext: context)
```
3. Create `CoreDataShare` instance.
```swift
let coreDataShare = try! CoreDataShare(configuration: configuration, viewContext: context)
```
4. Do not forget to add the class type that you want to update/reload objects in memory.
```swift
coreDataShare.sharedInScopeEntityNames = [String(describing: Counter.self)]
```
5. Add the notification of `.CoreDataShareDidSave:`.
```swift
let selector = #selector(reloadObjects)
NotificationCenter.default.addObserver(self, selector: selector, name: .CoreDataShareDidSave, object: nil)
```

## Author
vodaion, vanea.voda@gmail.com

## License

CDShare is available under the MIT license. See the LICENSE file for more info.
Application documentation.
