# WEServiceExtension

[![Version](https://img.shields.io/cocoapods/v/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)
[![License](https://img.shields.io/github/license/WebEngage/WEServiceExtension.svg)](http://cocoapods.org/pods/WEServiceExtension)
[![Platform](https://img.shields.io/cocoapods/p/WEServiceExtension.svg?style=flat)](http://cocoapods.org/pods/WEServiceExtension)
[![LastUpdated](https://img.shields.io/github/last-commit/WebEngage/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)

---

## Installation

WEServiceExtension is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following below :

## Notification Service Extension Setup

### Add Notification Service Extension

#### Step 1:

In Xcode, navigate to `File` > `New` > `Target` and select `Notification Service Extension` then `Next`

<img src="./assets/1.png" alt="plot">
<center><i>1</i></center>
<img src="./assets/2.png" alt="plot">
<center><i>2</i></center>
<img src="./assets/3.png" alt="plot" width="400px">
<center><i>3</i></center>

#### Step 2:

Enter the Product Name as `NotificationService`, and click Finish.

<img src="./assets/4.png" alt="plot" width="400px">
<center><i>4</i></center>

#### Step 3:

Click Activate on the prompt shown to activate the service extension. Xcode will now create a new top-level folder in your project with the name `NotificationService`.

<img src="./assets/5.png" alt="plot" width="400px">
<center><i>5</i></center>
<br/>
<center><i>If you not activated by accident, you can switch back to debug your app target (middle-top next to the device selector).</i></center>

---

### Add WebEngage Service Extensions (WEServiceExtension) to the respective Targets

---

Steps to add WebEngage Notification Service(WEServiceExtension)

#### Step 1:

Select your `Project` > `Package Dependencies` > `+` button.
Enter Package URL: `https://github.com/WebEngage/WEServiceExtension.git` in the search bar.

<img src="./assets/p1.png" alt="plot">
<center><i>1</i></center>
<img src="./assets/p2.png" alt="plot">
<center><i>2</i></center>
<img src="./assets/p3.png" alt="plot">
<center><i>3</i></center>

#### Step 2:

Under `Add to Target` select `NotificationService` (Your Service Extension Target).

<img src="./assets/p4.png" alt="plot">
<center><i>4</i></center>

#### Step 3:

Click `Add Package`.

<img src="./assets/p4.png" alt="plot">
<center><i>5</i></center>
<img src="./assets/p5.png" alt="plot">
<center><i>6</i></center>

## License

WEServiceExtension is available under the MIT license. See the LICENSE file for more info.
