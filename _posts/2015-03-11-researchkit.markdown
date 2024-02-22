---
layout: post
author: Tim Searle
title:  "ResearchKit"
date:   2015-03-11 22:39:58
categories: 
  - apple
---

[ResearchKit](https://www.apple.com/researchkit/) is Apple's latest philanthropic contribution to the technology world. 

The simple premise is that hundreds of millions of people have a powerful computer in their pocket that has the untapped ability of rapidly increasing the reach and efficacy of medical studies in ways currently not possible.

The framework, which Apple plan to open-source, will become available to developers in April 2015. It is being peddled as platform-agnostic following Apple's belief that anyone should be able to collaborate and contribute to the next potential medical breakthrough.

It will have full integration with Apple's health tool, HealthKit. HealthKit is currently being used in over 900 applications currently live on the App Store - this figure is being pushed as a great achievement by Apple. 900 apps is disappointing and misleading. At a glance, the market for health related apps is extremely bloated and several big contenders still have not integrated with HealthKit. 

Medical studies will be able to have full access to a consenting user's HealthKit data and mine numerous amounts of useful health related metrics; pedometer data, calorific intake and heart rates. Perhaps this increased integration with HealthKit will encourage more apps to use the service - which will greatly enrich the data it stores and the experience for its users.

ResearchKit already has five applications supporting research studies that cover a broad range of conditions. Unfortunately the apps are currently restricted to limited  [App Store](https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewFeature?id=973253773&mt=8&ls=1) locations, but users from the USA can opt-in to these studies *today* and begin contributing their own metrics and start performing a range of specialist in-app tests. The diseases and conditions being covered currently are:

* Asthma
* Parkinson's Disease
* Diabetes
* Breast Cancer
* Cardiovascular Disease

Mobile applications are used by millions of individuals on a daily basis. Medical studies do not currently have this exposure. The greater the sample size you have for a source of data on any topic, the more relevant and useful that data will be. As described during the video portion of the keynote, breast cancer researchers sent out over 10,000 letters to potential study participants and only received a little over 300 responses. [Bloomberg](http://www.bloomberg.com/news/articles/2015-03-11/apple-researchkit-sees-thousands-sign-up-amid-bias-criticism) reported that Stanford University woke up the day after the event to find over 11,000 sign-ups to their cardiovasulcar disease application. This is an incredible feat and truly shows the good intentions behind this framework.

___

The technical goal of ResearchKit is to make it simple for medical researchers to create mobile applications that expose the iPhone's various sensors in a structured format in order to measure and track study participants.

Based around the concept of customisable 'Modules', the developer can work with the researcher to construct an application suitable for gathering relevant information. The 'out-of-the-box' modules available are:

* **Surveys** - a simple Q+A based, customisable interface. The survey module is also fully localized, allowing a developer just to provide a localized strings file for the questions and answers.

*  **Informed Consent** - Consent templates that cover a variety of scenarios allow for researchers to ensure that their participants are fully-aware and in agreement to what information they will be sharing with the study. (*Ostensibly these templates will have to be customised heavily in order to allow for all the intricacies and ethical concerns regarding starting a medical study).*

* **Active Tasks** - Beyond the collection of "passive" data from the device's HealthKit and co-motion processor sources, developer's can utilise Active Tasks to retrieve data from the device's sensors. Categorised under four headings: *motor activities, fitness, cognition, voice*.

These modules are completely customisable and developers will also be able create their own. Due to the open-source nature of the framework I am envisioning collaboration between medical authorities, researchers and developers to enhance and augment the existing modules into a much larger and broad *platform* as time passes.

Neither Apple, nor ResearchKit itself provides any sort of mechanism to transmit data between the app itself and the backend - the onus is on the developer to implement this mechanism. This clearly reaffirms what Apple mentioned during the *Spring Forward* and their stance on data privacy that Apple will never see the user's data.

As mentioned, the framework currently is not available publicly to developers so it isn't possible to go into a more detailed analysis, so rather than regurgitating it please do read the [Technical Overview](https://developer.apple.com/researchkit/researchkit-technical-overview.pdf) for further detail.

___

Numerous ethical and validity concerns have been raised by journalists who have been testing the available applications since the announcement of ResearchKit. It's been [reported](http://www.theverge.com/2015/3/10/8177683/apple-research-kit-app-ethics-medical-research) that users have been able to modify their age during the study, fabricate information and erroneuously complete tests. The quality of the data that will be obtained by researcher's deploying ResearchKit-based apps is yet to be seen - will researcher's be able to filter out non-sensical data, anomalies, mistakes and perhaps most importantly, intentional sabotage by online trolls? 

It is currently unclear how researchers can recruit new participants into their research studies - if the current App Store marketing process is used to draw parallels the future is not bright. It is fantastic that Stanford have benefitted greatly from the exposure of the Apple event, but how will small, independent research groups 'advertise' their ResearchKit apps and follow suit and recruit 10,000 participants?

In conclusion, Apple have undeniably, but perhaps naively, broadened their involvement in their customer's personal health. Through ResearchKit they have enabled a standard approach for researchers around the world to increase their sample size, increase the amount of they receive from that sample and yet again allow the prospect of Big Data to have a larger impact on our day-to-day lives.



