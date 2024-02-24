#!/bin/bash

heading="# About"
front_matter="---
layout: page
title: \"About\"
permalink: /about/
---"

# Remove heading
sed -i "/$heading/d" about.md

# Inject front matter
printf '%s\n%s\n' "$front_matter" "$(cat about.md)" >about.md
