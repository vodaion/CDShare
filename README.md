# CDShare

[![CI Status](https://img.shields.io/travis/vadeara/CDShare.svg?style=flat)](https://travis-ci.org/vadeara/CDShare)
[![Version](https://img.shields.io/cocoapods/v/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)
[![License](https://img.shields.io/cocoapods/l/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)
[![Platform](https://img.shields.io/cocoapods/p/CDShare.svg?style=flat)](https://cocoapods.org/pods/CDShare)

## Example

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

## Usage
This work was inspired by how Apple iWork office suite applications work in iOS and a specific feature of how the documents are sharing between apps even in offline mode.

### `CDShare` will answer the question: <br> How do we share CoreData between `2*n` application, where n >= 1? ###
Before we will direct to the subject, let have a short introduction for each part that we will touch in this tutorial.

# What is CoreData? #
CoreData is a framework created by Apple, is used for object layer modeling management.
It provides a general solution for functions associated with the object lifecycle, object management, and persistence.
What should be mentioned in this framework are the following classes:
```swift
NSPersitentStoreCoordinator / NSPersitentStoreContainer
NSManagedObjectModel
NSManagedObjectContext
NSManagedObject
```
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/CoreDataState1.png)</span>
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/CoreDataState2.png)</span>

# iOS Application structure: #
In order to share CoreData between `2*n` applications, we have some impediments.

The main problem in iOS is that each application is totally isolated from other applications through a Sandbox.
This limits are interprocess communication and accessing directories/files between applications, normally we do not have access to applications in the directory structure.
# Directory structure of an application: #
Application directory structure with iCloud:
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/AppStructure2.png)</span>

Application directory structure without iCloud:
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/AppStructure1.png)</span>

# AppGroup #
First of all, you need to create app groups for your application. Go to <a href="https://developer.apple.com/membercenter/">Apple Developer Member Center</a> and register app group. Fill the description and identifier and follow the instructions.

![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/1.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/2.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/3.png)

After that when you will create an identifier for an application or an extension, don’t forget to enable the service <i>App Groups</i>.

![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/4.png)

Then go to the application or the extension and edit services. It’s really simple, see the next screenshots:

![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/5.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/6.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/7.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/8.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/9.png)

And please, perform this procedure for all extensions of the group. It’s all settings, now open the Xcode and let’s go to write code.

In the Xcode for the each target enable <i>App Groups</i> in target settings.

We have support for access and communication between applications, it needs to belong to the same group.

Each application when running is a separate process, and even if the applications are part of the same group, 
they do not access each other's directories, but they have access to the Shared Container that has a Sandbox-like directory structure.
# Process structure between Applications #
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/ProcessState.png)</span>

# CDShare Logic #
We will create a folder in the Shared Container where we will save `SQLite` and we will have one folder for each application, the folder name will be the bundle ID of each application. In these folders, we will save files with a unique name in which they will contain the payload received in the notification with the name `CoreDataSaveNotification`.
# Framework structure #
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/FrameworkState.png)</span>


# iOS Application states #
Applications in IOS have 5 states, these states are shown in the schematic below:
<br>
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/iOSState.png)</span>
<br>
`FolderWatcher` will work as long as the application is active when it enters the background, `fileDescriptor EventHandler` is put in a queue when the application will come in the active state, events from the queue will be fired.
The `fileDescriptor ` does it automatically you do not have to make any extra handlers.

# Example description #
Under the Example folder, you will find a project of how to use the `CDShare.framework`.
The project will contain a showcase for an Application and an Extension for it and they will share the CoreData.

The example will be based on another tutorial that you can find [here](https://github.com/maximbilan/iOS-Shared-CoreData-Storage-for-App-Groups).

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
