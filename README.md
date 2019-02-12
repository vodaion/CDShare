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
Before to go direct to the subject, let's have a short introduction for each part that is touched in this tutorial.

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

In iOS, each application is totally isolated from other applications through a Sandbox.
This was intentionally done by Apple for security reasons.
The limits are interprocess communication and accessing directories/files between applications.
Normally you do not have access to the other applications directory structure, outside of the application running process.

# Application directory structure with iCloud: #
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/AppStructure2.png)</span>

# Application directory structure without iCloud: #
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/AppStructure1.png)</span>

# AppGroup #

You do have the support of accessing and communicate between applications if the applications are in the same App Group.

Each application when is running in a separate process, even if the applications are part of the same App Group, 
they do not access each other's directories, but they have access to the Shared Container that has a Sandbox-like directory structure.
# Process structure between Applications #
 <span style="display:block;text-align:center">![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/ProcessState.png)</span>

First of all, you need to create App Group for your application. Go to <a href="https://developer.apple.com/membercenter/">Apple Developer Member Center</a> and register App Group. Fill the description and identifier and follow the instructions.

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
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/10.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/11.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/12.png)

It’s all settings, now open the Xcode and let’s go to write code.
In the Xcode for the each target enable <i>App Groups</i> in target settings.

![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/13.png)
![alt tag](https://github.com/vadeara/CDShare/blob/master/screenshots/14.png)

And please, perform this procedure for all applications or extensions of the group. 

# CDShare Logic #
A folder will be created in the Shared Container, in that folder the `SQLite` files will be saved and for each application will be created a sub-folder, the sub-folder name will be the bundle ID of each application. 
In these folders, we will save files with a unique name in which they will contain the payload received in the notification with the name `.CoreDataSaveNotification`.

`FolderWatcher` is one of the key components in the `CDShare.framework`.
For each application, we will have a `FolderWatcher`, the `readingEndpoint` we will receive events from each application each time one of the application will write anything in that folder.
For each event will we will process all the files that we did write in that folder.
For each application, we will handle CoreData notification `.CoreDataSaveNotification`, 
if notification contain any changes of the models that we are interest with `.sharedInScopeEntityNames` then,
that notification will be saved in the `writing` folders as a file with a unique name, The writing event will fire a reading event in each other applications.
After reading and merging in the applications the new changes the files are deleted.
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
