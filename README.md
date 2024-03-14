# WEServiceExtension

[![Version](https://img.shields.io/cocoapods/v/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)
[![License](https://img.shields.io/github/license/WebEngage/WEServiceExtension.svg)](http://cocoapods.org/pods/WEServiceExtension)
[![Platform](https://img.shields.io/cocoapods/p/WEServiceExtension.svg?style=flat)](http://cocoapods.org/pods/WEServiceExtension)
[![LastUpdated](https://img.shields.io/github/last-commit/WebEngage/WEServiceExtension.svg)](https://cocoapods.org/pods/WEServiceExtension)

---

**Push notification service extensions** in iOS are needed to make notifications more interesting by adding images, videos, or interactive buttons. They also ensure that sensitive tasks, like processing user data, are done securely without affecting the app's performance.

<!-- Start table -->

### Table of Content

<details>
    <summary>Click to Expand</summary>

- [How to add Service Extension ?](#how_to_add_service_extension)
- [How to integrate WebEngage into Service Extension ?](#how-to-integrate-webengage-into-service-extension)
  - [Using Swift Package Manager]()
  - [Using Cocoapods]()
  </details>
  <!-- End table -->

<!-- Start Of Step 1 -->

### How to add Service Extension ?

#### Step 1:

In Xcode, navigate to `File` > `New` > `Target` and select `Notification Service Extension` then `Next`

<!-- ![2](./assets/2.png) -->

<!-- ![3](./assets/3.png) -->

#### Step 2

Enter the Product Name as `NotificationService`, and click Finish.

<!-- ![4](./assets/4.png) -->

#### Step 3

Click Activate on the prompt shown to activate the service extension. Xcode will now create a new top-level folder in your project with the name `NotificationService`.

<!-- ![5](./assets/5.png) -->

<!-- End of Step 1 -->

<hr>

<!-- Start of  -->

### How to integrate WebEngage into Service Extension ?

There are two ways to do this.

1. [Using Swift Package Manager]()
2. [Using Cocoapods]()

### Using Swift Package Manager

#### Step 1:

Select your `Project` > `Package Dependencies` > `+` button.
Enter Package URL: `https://github.com/WebEngage/WEServiceExtension.git` in the search bar.

```
https://github.com/WebEngage/WEServiceExtension.git
```

<!-- ![p1](./assets/p1.png) -->
<!-- ![p2](./assets/p2.png) -->
<!-- ![p3](./assets/p3.png) -->

#### Step 2:

Under `Add to Target` select `NotificationService` (Your Service Extension Target).

<!-- ![p4](./assets/p4.png) -->

#### Step 3:

Click `Add Package`.

<!-- ![p5](./assets/p5.png) -->
<!-- ![p6](./assets/p6.png) -->

## License

WEServiceExtension is available under the MIT license. See the LICENSE file for more info.

<!-- End Of ******************************** -->
