# WEServiceExtension

[![Version](https://img.shields.io/cocoapods/v/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)
[![License](https://img.shields.io/github/license/WebEngage/WEServiceExtension.svg)](http://cocoapods.org/pods/WEServiceExtension)
[![Platform](https://img.shields.io/cocoapods/p/WEServiceExtension.svg?style=flat)](http://cocoapods.org/pods/WEServiceExtension)
[![LastUpdated](https://img.shields.io/github/last-commit/WebEngage/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)

---

**Push notification service extensions** in iOS are needed to make notifications more interesting by adding images, videos, or interactive buttons. They also ensure that sensitive tasks, like processing user data, are done securely without affecting the app's performance.

## <!-- Start table -->

### Table of Content

<details>
    <summary>Click to Expand</summary>

- [Create service extension for Project](#step-1--create-service-extension-for-project)
- [Integrate WEServiceExtension inside Service Extension](#step-2--integrate-weserviceextension-inside-service-extension)
  - [Approach 1 : SPM](#approach-1--integrating-via-spm)
  - [Approach 2 : Cocoapods](#approach-2--integrating-via-cocoapods)
- [Import and Use the WebEngage inside Service Extension](#step-3--import-and-use-the-webengage-inside-service-extension)

  - [Swift](#swift)
  - [Objective C](#objective-c)

- [Configure ServiceExtension-Info.plist](#step-4--configure-serviceextension-infoplist)
- [Add App Groups](#step-5--create-app-groups-for-all-targets)
- [Build and Test](#step-6--build-and-test)
- [Migration from Older Service Extension](#migration-from-older-service-extension)

  </details>
  <!-- End table -->

## <!-- Start Of Step 1 -->

## Prerequisites

- WebEngage SDK needs to be integrated inside project
- Basic knowledge of Service Extension and Content Extension
- Basic knowledge about push notification , swift / Objc Programing Language

---

- ## **_Step 1 :_** Create service extension for Project

  - In Xcode, navigate to `File` > `New` > `Target` and select `Notification Service Extension` then `Next`

  - Enter the Product Name as `NotificationService`, and click Finish.

  - Click Activate on the prompt shown to activate the service extension. Xcode will now create a new top-level folder in your project with the name `NotificationService`.

  - #### **_Screenshots_**

    <p align="center">
      <img src="./assets/2.png" alt="Screenshot 1" width="1000">
    </p>
    <h5 align="center">Screenshot 1</h5>

    <p align="center">
      <img src="./assets/3.png" alt="Screenshot 2" width="1000">
    </p>
    <h5 align="center">Screenshot 2</h5>

    <p align="center">
      <img src="./assets/4.png" alt="Screenshot 3" width="1000">
    </p>
    <h5 align="center">Screenshot 3</h5>

    <p align="center">
      <img src="./assets/5.png" alt="Screenshot 4" width="1000">
    </p>
    <h5 align="center">Screenshot 4</h5>

<!-- End of Step 1 -->

---

<!-- Start of  -->

- ### **_Step 2 :_** Integrate WEServiceExtension inside Service Extension

  There are 2 common methods for integrating a library inside a Service Extension:

  ### Note: Choose Either SPM or CocoaPods

  > _It's recommended to choose either Swift Package Manager or CocoaPods for integrating the library into your Service Extension. Mixing both methods might lead to conflicts or inconsistencies in your project setup._

  ***

  ### **<u>Approach 1</u> :** Integrating via **_SPM_**

  - Select your `Project` > `Package Dependencies` > `+` button.
    Enter Package URL: `https://github.com/WebEngage/WEServiceExtension.git` in the search bar.

    ```
    https://github.com/WebEngage/WEServiceExtension.git
    ```

    <br>
    <p align="center">
    <img src="./assets/p1.png" alt="Screenshot 1 (SPM)" width="1000">
    </p>
    <h5 align="center">Screenshot 1 (SPM)</h5>

    <p align="center">
    <img src="./assets/p2.png" alt="Screenshot 2 (SPM)" width="1000">
    </p>
    <h5 align="center">Screenshot 2 (SPM)</h5>

    <p align="center">
    <img src="./assets/p3.png" alt="Screenshot 3 (SPM)" width="1000">
    </p>
    <h5 align="center">Screenshot 3 (SPM)</h5>

  - Under `Add to Target` select `NotificationService` (Your Service Extension Target).
  <br><br>
     <p align="center">
      <img src="./assets/p4.png" alt="Screenshot 4 (SPM)" width="1000">
      </p>
      <h5 align="center">Screenshot 4 (SPM)</h5>

  - Click `Add Package`.
  <br><br>
    <p align="center">
    <img src="./assets/p5.png" alt="Screenshot 5 (SPM)" width="1000">
    </p>
    <h5 align="center">Screenshot 5 (SPM)</h5>

  ### **<u>Approach 2</u> :** Integrating via **_CocoaPods_**

  - #### Prerequisites

    - Cocoapods should be installed inside your system

    - podfile should be available for your project

  - #### Edit Podfile

    - Open the Podfile using a text editor.

    - Add the library dependency to the Podfile. For example:

      ```ruby
      # this target name should be your ServiceExtension Name
      target 'NotificationService' do
        # Uncomment the line below if the parent target also uses frameworks
        # use_frameworks!
        pod 'WEServiceExtension'
        # Add other pods for the NotificationService target here
      end
      ```

      Note : Your target name should be the Service Extension name which you have entered while creating ServiceExtension, Over here refer screenshot 3

    - #### Install Pods

      - Save the changes to the Podfile.

      - Install the pods by running the following command:
        ```shell
        pod install
        ```

---

- ### **_Step 3 :_** Import and Use the WebEngage inside Service Extension

  - #### SWIFT

    1.  Open **NotificationService.swift**
    2.  Import **WEServiceExtension** by adding code `import WEServiceExtension`
    3.  Remove all existing code from the class `NotificationService`
    4.  Add subclassing to `NotificationService` with `WEXPushNotificationService`

        ```swift
        import UserNotifications
        // Step 1 : Importing WEServiceExtension
        import WEServiceExtension

        // Step 2 : Subclassing service Extension
        class NotificationService: WEXPushNotificationService {
        }

        ```

  - #### Objective C

    1.  Open **NotificationService.m**
    2.  Import `WEServiceExtension/WEServiceExtension-Swift.h`
    3.  Create Object of `WEXPushNotificationService`
    4.  Pass necessary information to `WebEngage` through above created object

    `NotificationService.m` will look like below code snippet

    ```Objective-C
    #import "NotificationService.h"
      // Step 1 : Importing WEServiceExtension
      #import <WEServiceExtension/WEServiceExtension-Swift.h>

      @interface NotificationService ()
      // Step 2 : Creating Object of service Extension
      @property (nonatomic, strong) WEXPushNotificationService *serviceExtension;

      @end

      @implementation NotificationService

      // Step 3 : Pass necessary information to WebEngage
      - (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
          if (_serviceExtension == NULL){
              _serviceExtension = [[WEXPushNotificationService alloc]init];
          }
          [_serviceExtension didReceiveNotificationRequest:request
                                        withContentHandler:contentHandler];
      }

      - (void)serviceExtensionTimeWillExpire {
          // Called just before the extension will be terminated by the system.
          // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
          [_serviceExtension serviceExtensionTimeWillExpire];
      }

      @end
    ```

- ### **_Step 4 :_** Configure ServiceExtension-Info.plist

  Here's how you can go about it:

  - Open the `Info.plist` file for `NotificationService`
  - Add `App Transport Security Settings` key under `Information Property List` in `NotificationService-Info.plist` file.
  - Set `Allow Arbitrary` Loads to `YES` under `App Transport Security Settings` - Not required if you are sure that image URLs provided on `WebEngage` dashboard will always use `https`.
  <br><br>
    <p align="center">
    <img src="./assets/appGroup/4.png" alt="Screenshot 1" width="1000">
    </p>
    <h5 align="center">Screenshot 1</h5>

- ### **_Step 5 :_** Create App Groups for all Targets

  App Groups allow your app and the WebEngageNotificationServiceExtension to communicate when a notification is received, even if your app is not active. This is required for Confirmed Deliveries.

  - Select your `Main App Target` > `Signing & Capabilitie`s > `+ Capability` > `App Groups`.
  - Within `App Groups`, click the `+` button.
  - Set the App Groups container to be `group.YOUR_BUNDLE_IDENTIFIER.WEGNotificationGroup` where `YOUR_BUNDLE_IDENTIFIER` is the same as your Main Application "`Bundle Identifier`".
  - Press `OK` and repeat for the **`NotificationService`** Target.
  - #### **_Screenshots_**
    <br><br>
      <p align="center">
      <img src="./assets/appGroup/1.png" alt="Screenshot 1" width="1000">
      </p>
      <h5 align="center">Screenshot 1</h5>
      <br><br>
      <p align="center">
      <img src="./assets/appGroup/2.png" alt="Screenshot 1" width="1000">
      </p>
      <h5 align="center">Screenshot 2</h5>
      <br><br>
      <p align="center">
      <img src="./assets/appGroup/3.png" alt="Screenshot 1" width="1000">
      </p>
      <h5 align="center">Screenshot 3</h5>

---

- ### **_Step 6 :_** Build and Test

  - Build your project to ensure that the library integrates successfully.

  - Test your Service Extension to ensure that it functions as expected with the integrated library.

---

- ### Migration from Older Service Extension

  - If you've been using the old service extension and want to switch to the new one, just stick to these instructions in the documentation:

  - Below are the steps to migrate from the older Service Extension to the new Service Extension:

    - Remove `pod 'WebEngageBannerPush'` from the Target `NotificationService` in the podfile.
    - Then Perform `pod install`
    - Follow Step 2 [Import and Use the WebEngage inside Service Extension](#step-3--import-and-use-the-webengage-inside-service-extension)
    - After successfully completing `step 2`, let's move to the code section:

      - #### For Swift Users :

        - Open the `NotificationService.swift` file.
        - Replace `import WebEngageBannerPush` with `import WEServiceExtension`.
        - Done

      - #### For Objective-C Users:
        - Open the NotificationService.h file.
        - Remove the import statement `#import <WebEngageBannerPush/WEXPushNotificationService.h>`.
        - Replace `WEXPushNotificationService` with `UNNotificationServiceExtension`.
        - Open the `NotificationService.m` file.
        - Replace the code as given in Step [Objective C](#objective-c)

## License

WEServiceExtension is available under the MIT license. See the LICENSE file for more info.

###
