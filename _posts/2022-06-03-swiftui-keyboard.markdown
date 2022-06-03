---
layout: post
title:  "Navigating Text Fields in SwiftUI"
date:   2022-06-03 00:00:00
categories: apple
---

As part of my recent development efforts on [Altilium](https://apps.apple.com/gb/app/altilium/id1560227798), I wanted to remove my dependency on using the [SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect) library to access the underlying `UITextField` that back the SwiftUI `TextField`. The reason I was using the library was because, at the time (iOS 14), there was no first-party support in SwiftUI for either adding a `Toolbar` to the keyboard or customising the focus state of the `TextField` in the form.

I'm not going to regurgitate Paul Hudson's excellent articles - so for more detailed information please see:

* [Toolbar Support](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-a-toolbar-to-the-keyboard)
* [Focus State Handling](https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield)

This article is to quickly demonstrate a generalised solution I've come up with to adding quick keyboard toolbar based navigation to a form - a must-have for any app that utilisies the `.numberPad` or `.decimalPad` keyboard styles.

I've built a simple `View` subclass that takes the current `FocusState` from your parent view (where your `TextField`'s live) and the array of all the available field types you have on that particular view:

```swift
protocol InputField: Hashable, CaseIterable {
    var index: Int { get    }
}

struct TextFieldNavigationView<FieldType: InputField>: View {
    var focusedField: FocusState<FieldType?>.Binding
    let allFields: [FieldType]
    
    var body: some View {
        Group {
            Spacer()
            Button {
                if let f = focusedField.wrappedValue {
                    focusedField.wrappedValue = allFields[f.index - 1]
                }
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(focusedField.wrappedValue?.index == 0)
            Button {
                if let f = focusedField.wrappedValue {
                    focusedField.wrappedValue = allFields[f.index + 1]
                }
                
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(focusedField.wrappedValue == allFields.last)
        }
    }
}
```

This view simply enables or disables a chevron icon in the toolbar based on how many fields are before or after - utilising the `CaseIterable` protocol and the `allCases` property. So, what does an implementation on your form look like?

```swift
    enum MyCustomInputField: Int, InputField {
        case testing1
        case testing2
        case testing3
        
        var index: Int {
            rawValue
        }
    }
 ```

 This enum conforms to the `InputField` protocol we previously defined, and adds cases for each of the text fields I have on one of my screens, I'm using the `Int` as a backing type to easily provide the index, but this can easily be defined in a custom manner within the `index` property itself.

 We then use the advice from Paul Hudson's articles and harness the `.focused` and the `toolbar` view modifier. It's worth noting, you only need one view modifier for the `.toolbar` on the parent of your `TextField`, e.g.

 ```swift
 
 @FocusState var field: MyCustomerInputField?

 /// ...

 ScrollView {
 	VStack {
		TextField("Testing 1", text: $foo)
			.focused($field, equals: .testing1)
		TextField("Testing 2", text: $bar)
			.focused($field, equals: .testing2)
		TextField("Testing 3", text: $test)
			.focused($field, equals: .testing3)
 	}
 	.toolbar {
		ToolbarItemGroup(placement: .keyboard) {
            TextFieldNavigationView<MyCustomInputField>(
            	focusedField: $field, 
				allFields: MyCustomInputField.allCases
			)
		}
 }

 ```

![SwiftUI Demo Video](/assets/swiftui-keyboard-demo.mp4){: height="300" }

And that's all there is to it! Let me know your thoughts on [Twitter](https://twitter.com/timsearle_)