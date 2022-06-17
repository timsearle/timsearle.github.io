---
layout: post
title:  "Adding support for Apple App Site Association files to Jekyll"
date:   2022-06-05 00:00:00
categories: apple
tags: ios
---

It's pretty common for an iOS app these days to support universal links, iCloud credentials, App Clips and other functionality related to the [Associated domains](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains) entitlement. The tricky part can sometimes be that you _don't_ have a website or hosting to host the required `apple-app-site-association` file for the Apple CDN to pull.

This blog is actually running on a static site generator called Jekyll, and it's hosted by GitHub Pages. There's an excellent [guide](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll) from GitHub if you'd like to do something similar - I'm also using it to satisfy the App Store privacy policy requirement too.

For the AASA file, I had two requirements:

* Upload a JSON file, named `apple-app-site-association` to the `.well-known` directory
* Expose this file via my domain [searle.dev](https://searle.dev) at that location via Jekyll - this enables the Apple CDN to locate the file, and cache it, based on the domain(s) you specify in your app's entitlements.

It turned out to be _really_ simple, all that was needed was to create the folder and file in my root directory and then the key part - specify in my `_config.yml` file to include that location:

```yml
include: 
  - .well-known
```

There was some misleading information out there that lead me away from this simple approach initially - this works. You can find the commit [here](https://github.com/timsearle/timsearle.github.io/commit/b04b67860db4d1b080c3ca7bee466d71b03113ea)
