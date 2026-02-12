---
layout: post
lang: en
author: "Tim Searle"
title: "Selling shovels"
date: "2026-02-11 00:00:00"
tags:
  - "ai"
  - "oauth"
  - "identity"
---

Back in 2016, I was (mis)quoted as saying Siri App integrations would be the ["death of apps"](https://www.campaignlive.co.uk/article/apple-breaks-down-walled-garden-opening-siri-maps-developers/1398495#:~:text=The%20death%20of%20apps&text=Citing%20specific%20Apple%20iOS%20features,no%20longer%20by%20specific%20downloads.%22), but the intent behind the words was captured. In a recent interview with Peter Steinberger, the creator of AI assistant, [OpenClaw](https://openclaw.ai), he stated that 80% of apps will disappear because AI assistant will be able to handle the majority of features that users expect of their app. TODO: Add link.

I recently deployed OpenClaw myself for some fun experimentation. Yes, it's littered with vulnerabilities (TODO link), security researchers are all over it, and there's been a lot of sensantionalist hype online - but it is a really important piece of software. It's a glimpse into the direction we're heading toward - mainstream AI personal assistants that can dynamically achieve _anything_, and yes perhaps, the "death of apps".

## Security Vulnerabilities

Personally, I prefer to keep a mental separation between OpenClaw's security vulnerabilities vs the overall security model AI assistants. Yes, there's vulnerabilities and [plenty of them](TODO), but these are generally coding problems, control flow and logic problems. These will be solved by researchers, by SAST, DAST and SCA tools, and as the models improve they'll occur less frequently - but none of these tools changed the part of the security threat model I was most concerned with in the current generation of AI assistants we're using.

These agents require authorisation to act on your behalf, and invariably, that they do this by having access to your long-lived credentials, your tokens, your API keys, access to vital personal information, services, emails, your browser sessions etc.

And in a world where prompt injection, malicious skills, and deep supply chain attacks specifically tagreting software like OpenClaw - these become the real targets - account takeovers and data exfiltration.

## Configuring OpenClaw

Although I was terrified at the prospect of security issues, I just _had_ to run this thing and form my own opinions. I actually ended up configuring my OpenClaw instance so aggressively constrained it was _almost_ useless.

- Dedicated Raspberry Pi Model 4 B
- Inbound connectivity to the Pi only over SSH
- An independent Linux user for OpenClaw with no interactive login, no SSH, no sudo, and only write/read to specific volumes
- Docker daemon requires sudo, (that agent cannot obtain), Docker container that OpenClaw runs within as root, but with a user mapping to ensure if it escaped the container it would end up on the powerless user, not root.
- Strict outbound port filtering with `ufw`

TODO: Insert simple diagram to break up the blog post

I could've gone further and allow-listed every egress hostname that OpenClaw wants to interact with, and extensively analysed the outbound `ufw` logs, but ultimately, none of this protects against OpenClaw connecting to some allow-listed host, and pumping data, keys, credentials out to it due to a prompt injection or compromised skill or tool.

Once this was done - I was now terrified to give it access to tools, to systems, worried about the one-click exploits that had been flagged, and how to prevent data exfiltration. This got me thinking about applying some basic Identity concepts to AI personal assistants and how this might look.  

## A vision for the future

How could we solve this? Not just for OpenClaw, but for all future AI assistants that all the big tech incumbents and start-ups are likely furiously working to make them accessible to the mainstream.

Well - ultimately, we need to govern the AI assistant's ability to make tool calls through policies, using mechanisms like step-up authentication, remote authorization.

We see "authorization" concepts like this already with Claude Code, Copilot CLI, Codex, where they prompt for permission before performing certain commands, storing your preferences as a policy. But we need more than this.

[Some people are creating whole new identities for their agents](TODO 1Password Blog), with their own 1Password vault, segregating duties between the owner and the assistant - this is great, but it still doesn't stop the assistant doing things on your behalf that you do not want them to do as a result of prompt injection. So what we're really looking at here is a whole new identity layer, and expectation for third-party systems - think Open Banking levels of standardisation but across the entire digital landscape.

I want to be able to:

- Provision an AI assistant with its own identity
- Generate short-lived, scoped access tokens on my own accounts that are delegated to my assistant, that must be provided a composite identity - TODO: OAuth on behalf of flow
- I want to receive a simple, low-friction push notification, when the agent wants to perform sensitive tasks that I define with a OPA Rego policy inline with my risk tolerance, that when I accept, that's considered an authentication event, that the tool physically cannot progress without my input.
- I do not want the AI agent to ever have direct access to credentials - I want it to interact through another service, where the policies are enforced and token exchanges can occur.

The progress being made by Peter Steinberger and his OpenClaw contriobutoirs is incredible - everything is moving so fast, but what I find most exciting here is that although the entire AI assistant security model is brand new and needs to be carefully reasoned about, I think we can actually build the entire using pre-existing standards and technologies. The model Open Banking APIs must follow for you to make a bank transfer now, or grant access to your transactions, is an ideal model.

The hard part is how do we get all third-party providers meeting these standards - Peter Steinberger said something very interesting about everything needs an API or other people will build them for you, you can see this through his vast suite of tools he's bundled with OpenClaw - the downside here is that if we're needing to rely on session hijacks/headless browsers, or similar, it makes the authorisastion model much harder. 

I think AI personal assistants are the future. I think tools like OpenClaw are incredible. But the whole system needs an overhaul, because people aren't going to be running these on their Raspberry Pis or Mac Minis.

I can see a world where AI assistants and what they can easily and securely integrate with will determine the markets "demand" angle, services that do not integrate securely with AI assistants will slowly fade to insignifance, the same way how 20 years ago, we made a transition to businesses, no matter how small, even if you're a sole trader plumber, you need to have a website or be on a service, otherwise you will struggle to gain the demand for your service.
