# WEServiceExtension

## Installation

WEServiceExtension is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following below :

## Notification Service Extension Setup
### Create Notification Service Extension
#### Step 1:
In Xcode, navigate to `File` > `New` > `Target` and select `Notification Service Extension`.

#### Step 2:
Click Next, fill out the Product Name as `NotificationService`, and click Finish.

#### Step 3:
Click Activate on the prompt shown to activate the service extension. Xcode will now create a new top-level folder in your project with the name `NotificationService`.

### Add WebEngage Extensions to the respective Targets
Navigate to `Project` > `Package Dependencies` and click on the Add (`+`) button.

Steps to add WebEngage Notification Service
#### Step 1:
Search for https://github.com/WebEngage/WEServiceExtension.git in the search bar.
#### Step 2:
Under `Add to Target` select `NotificationService` (Your Service Extension Target).
#### Step 3:
Click `Add Package`.


## License

WEServiceExtension is available under the MIT license. See the LICENSE file for more info.
