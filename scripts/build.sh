#!/bin/bash

# Dynamically pull in About.md
curl -s -o about.md https://raw.githubusercontent.com/timsearle/timsearle/main/README.md

heading="# About"
front_matter="---
layout: page
title: \"About\"
permalink: /about/
---"

# Remove heading
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i "" "/$heading/d" about.md
else
  sed -i "/$heading/d" about.md
fi

# Inject front matter
printf '%s\n%s\n' "$front_matter" "$(cat about.md)" >about.md

# Build site
bundle exec jekyll build --baseurl "$BASE_URL"
