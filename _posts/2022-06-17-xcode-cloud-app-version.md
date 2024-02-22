---
layout: post
title:  "Automatic app version increments with Xcode Cloud using custom build scripts"
date:   2022-06-17 00:00:00
tags: 
  - ios 
  - xcode
---

### Using Swift to write custom build scripts in Xcode Cloud

Recently, as part of my release workflow with the new [Xcode Cloud](https://developer.apple.com/xcode-cloud/), I found myself wanting to ensure that the app version was automatically updated based on the version number specified in my git branch, for example, `release/1.2.0`. I was constantly running into the dreaded App Store Connect failure where your app version (`CFBundleShortVersionString`) was not greater than the previous release - because I kept forgetting to manually change it in my Info.plist!

To stop making this mistake I wanted to build the following:

1. Execute my release candidate workflow on Xcode Cloud when I push new commits to a branch matching the pattern `release/*`
2. Within the release candidate workflow, extract the version number from the git branch and update the Info.plist with the specified version

In a more concrete scenario - when I wish to generate my next release candidate for TestFlight from my work-in-progress, I can create a new branch with the appropriate version from my changes and then rely solely on Xcode Cloud to execute my app version script and automatically bump the build number.

Xcode Cloud supports [custom build scripts](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts). We can use these scripts to run specific tasks that augment our build pipelines - Xcode Cloud provides 3 entry points:

* `ci_post_clone`
* `ci_pre_xcodebuild`
* `ci_post_xcodebuild`

For this specific problem, we could use either `ci_post_clone` and `ci_pre_xcodebuild`, I opted for `ci_post_clone` as I want the pipeline to fail as early on as possible if it ran into issues with my script - this reduces build time and therefore cost and reducing the feedback cycle during development.

To get started, we create a directory in the root of our repository named `ci_scripts` and create an empty file inside it named `ci_post_clone.sh`

What language should we use for our script?

By default, Xcode Cloud uses `zsh`, but as you'd expect, I am far more comfortable writing Swift. Luckily, we're able to use Swift within these scripts by specifying the following [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at the top of the `ci_post_clone.sh` file, 

```
#!/usr/bin/env swift
```

> Note: the only behaviour I have in my `ci_post_clone` file is for the app versioning, but it's likely that you will be handling many scenarios within the 3 available entry point scripts, so it's important to consider this when structuring your script and the exit points and error points within it - you can read more in the documentation under the "Writing resilient scripts" section. 

Let's jump into the script bit-by-bit:

```swift
func appVersionBumpIfNeeded() throws {
    let dictionary = ProcessInfo.processInfo.environment
    
    // ...
```

We start with a simple function signature that throws - this will allow us to exit the script gracefully in the event of an error - and in future handle errors more easily. We also grab a reference to the `ProcessInfo` `environment` property to access the environment variables on the machine, we'll be using these to extract information and make conditional decisions.

```swift
    guard let branch = dictionary["CI_BRANCH"],
          branch.starts(with: "release/") else {
        return
    }
    
    let version = branch.replacingOccurrences(of: "release/", with: "")
    
    // ...
```

> There are a number of Xcode Cloud pre-defined environment variables available to you, these are all prefixed with `CI_` - the full reference can be found [here](https://developer.apple.com/documentation/xcode/environment-variable-reference)

We extract the branch name, and verify it starts with the prefix (and therefore workflow) we are interested in, if it doesn't we bail out with no error. We could also take a very thorough approach here and inspect the `CI_WORKFLOW` environment variable - but perhaps this is better handled by the caller and the top-level of the script.

```swift
    let version = branch.replacingOccurrences(of: "release/", with: "").replacingOccurrences(of: "ci_testing/", with: "")
    
    let components = version.components(separatedBy: ".")
    
    guard components.count <= 3 else {
        print("Version invalid length: \(version)")
        throw PostCloneErrors.invalidBranchVersion
    }
    
    let values = components.compactMap { Int($0) }
    
    guard components.count == values.count else {
        print("Version contains invalid characters: \(version)")
        throw PostCloneErrors.invalidBranchVersion
    }
```

The next part is all about validating the version number meets the format expected by [App Store Connect](https://help.apple.com/xcode/mac/current/#/devc092854f5).

1. Remove the branch name prefix `/release`
2. Extract the individual digits of the version, e.g. `1.2.3`
3. Verify there is at least 1 component and no more than 3
4. Verify each component is a valid integer and that the count matches the original number of components

If any of the above fails, we want to be throwing an error at this point for the caller to handle or for the script to bail out.

```swift
    let infoPlistURL = URL(fileURLWithPath: "path/to/Info.plist")
    let infoPlistData = try Data(contentsOf: infoPlistURL)
    let infoPlist = try PropertyListSerialization.propertyList(from: infoPlistData,
                                                               options: .mutableContainersAndLeaves,
                                                               format: nil) as? NSDictionary
    let mutableInfoPlist = infoPlist?.mutableCopy() as? NSMutableDictionary
    
    print("Updating version to: \(version)")
    
    mutableInfoPlist?["CFBundleShortVersionString"] = version
    
    let modifiedInfoPlistData = try PropertyListSerialization.data(fromPropertyList: mutableInfoPlist as Any, format: .xml, options: 0)
    try modifiedInfoPlistData.write(to: infoPlistURL)
```

Now that we know the version number matches a valid format, we need to write value that to the `CFBundleShortVersionString` key within the Info.plist file in your repository. We do not need to modify the `CFBundleVersion` at all, e.g. your build number - as this can be handled in your [Xcode Cloud workflow directly](https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds).

1. Read the contents of Info.plist file to a Data variable
2. Deserialize this into a property list and convert it to a NSMutableDictionary so that we can make modifications
3. Update the value for the key `CFBundleShortVersionString` to the `version` we captured earlier
4. Serialize the dictionary back into property list data
5. Write the modified data back to the same location, overwriting the previous plist

And that's it - I'll paste the full script below, you'll need to modify it for your project differences - let me know your thoughts on [Twitter](https://twitter.com/timsearle_) and if you've made any useful Swift scripts for Xcode Cloud.

```swift
#!/usr/bin/env swift
import Foundation

enum PostCloneErrors: Error {
    case invalidBranchVersion
    case invalidInfoPlistPath
}

func appVersionBumpIfNeeded() throws {
    let dictionary = ProcessInfo.processInfo.environment
    
    guard let branch = dictionary["CI_BRANCH"],
          branch.starts(with: "release/") else {
        return
    }
    
    let version = branch.replacingOccurrences(of: "release/", with: "")
    
    let components = version.components(separatedBy: ".")
    
    guard !components.isEmpty, components.count <= 3 else {
        print("Version invalid length: \(version)")
        throw PostCloneErrors.invalidBranchVersion
    }
    
    let values = components.compactMap { Int($0) }
    
    guard components.count == values.count else {
        print("Version contains invalid characters: \(version)")
        throw PostCloneErrors.invalidBranchVersion
    }
    
    let infoPlistURL = URL(fileURLWithPath: "/your/path/to/Info.plist")
    let infoPlistData = try Data(contentsOf: infoPlistURL)
    let infoPlist = try PropertyListSerialization.propertyList(from: infoPlistData,
                                                               options: .mutableContainersAndLeaves,
                                                               format: nil) as? NSDictionary
    let mutableInfoPlist = infoPlist?.mutableCopy() as? NSMutableDictionary
    
    print("Updating version to: \(version)")
    
    mutableInfoPlist?["CFBundleShortVersionString"] = version
    
    let modifiedInfoPlistData = try PropertyListSerialization.data(fromPropertyList: mutableInfoPlist as Any, format: .xml, options: 0)
    try modifiedInfoPlistData.write(to: infoPlistURL)
}

try appVersionBumpIfNeeded()

```

As mentioned earlier - there's definitely an opportunity at the callsite (`try appVersionBumpIfNeeded()`) to inspect the `CI_WORKFLOW` name and decide what sequence of functions you wish to call as part of your `ci_post_clone` script, e.g.

```swift
enum Workflow: String {
	case release
}

guard let workflow = Workflow(rawValue: ProcessInfo.processInfo.environment["CI_WORKFLOW"] ?? "") else {
	return
}

switch workflow {
	case .release:
		try appVersionBumpIfNeeded()
}
```

Best of luck!
