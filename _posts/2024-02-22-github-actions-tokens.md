---
layout: post
author: Tim Searle
title:  "Accessing private GitHub repositories within GitHub Actions"
date:   2024-02-22 00:00:00
tags: 
  - ios 
  - ruby
  - github-actions
---

Generally, [GitHub Actions](https://docs.github.com/en/actions) is incredibly simple when interacting with private repositories, either through the `GITHUB_TOKEN` or through creation a Personal Access Token. However, when the tools that your GitHub Action interacts with require to authenticate, injecting that personal access token can become challenging.

Here I show two easy ways to enable your GitHub Actions to interact with private repositories for:

- [Bundler](https://bundler.io)
- [Swift Package Manager](https://www.swift.org/documentation/package-manager/)

In both of these examples, it's incredibly important to use GitHub Action's secrets to store the personal access token, and then inject that token into the environment of the job that requires it. This ensures it is redacted in any runner logs and not visible in plain text.

## Cloning Private Repositories through Ruby

There's an obscure variable that Bundler uses to authenticate with GitHub, `BUNDLE_GITHUB__COM`:

Specify the variable `BUNDLE_GITHUB__COM: x-access-token:${{ secrets.$SOME_PAT }}` in your `job`’s env` key and ensure the URL to clone the ruby gem is using https.

```ruby
gem 'private-dependency', git: 'https://github.com/your-org/private-repo'
```

```yml
name: "Deploy"  
  
on:  
  workflow_dispatch:  
  
jobs:  
  deploy-beta:
    name: "Deploy Beta"
    runs-on: ubuntu-latest
    timeout-minutes: 10
    env:  
      BUNDLE_GITHUB__COM: x-access-token:${{ secrets.PRIVATE_GITHUB_PAT }}  
      
    steps:  
    - name: "Checkout ${{ github.ref }} in ${{ github.repository }}"  
      uses: actions/checkout@v4
    - name: "Install dependencies"  
      run: |  
        bundle install
```

## Cloning Private Repositories through Swift Package Manager

When Xcode clones dependencies through Swift Package Manager, because it is using the machines git configuration, we can harness that and the [insteadOf](https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf) key to modify the remote URL. 

Use the following `step` in your GitHub Action to modify the git config remote URL:

```yml
- name: "Setup Authenticated URL"
  shell: bash
  env:
    GIT_AUTH_TOKEN: ${{ secrets.GIT_AUTH_TOKEN }}|
  run: |
    git config --global --add url."https://oauth2:${GIT_AUTH_TOKEN}@github.com/".insteadOf "https://github.com/"
    git config --global user.name "$GIT_AUTHOR_NAME"  
    git config --global user.email "$GIT_AUTHOR_EMAIL"  
    git config --global credential.username "$GIT_USERNAME"
```
