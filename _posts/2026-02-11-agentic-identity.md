---
layout: post
lang: en
author: "Tim Searle"
title: "Do you trust your assistant?"
date: "2026-02-14 00:00:00"
tags:
  - "ai"
  - "oauth"
  - "identity"
---

I recently deployed OpenClaw myself for some fun experimentation. Yes, it's been littered with vulnerabilities, there are security researchers all over it, and there's been a lot of sensationalist hype online - but it is an important piece of software. 

It's a glimpse into the direction we're heading toward - mainstream AI personal assistants that can dynamically achieve _anything_, and perhaps the [”death of apps”](https://searle.dev/2026/02/14/death-of-apps.html).

## Configuring OpenClaw

Although I was terrified by the coverage of the security issues, I just _had_ to run this thing and form my own opinions. I actually ended up configuring my OpenClaw instance so aggressively constrained it was _almost_ useless.

- Dedicated Raspberry Pi 4 Model B
- Inbound connectivity only over SSH
- A dedicated Linux user for OpenClaw with no interactive login, no SSH, no sudo, and read/write access restricted to specific directories
- Docker requires sudo that the dedicated user cannot obtain; OpenClaw runs as root inside the container, but user namespace remapping ensures a container escape would land as the powerless dedicated user, not root
- Strict outbound port filtering with [ufw](https://wiki.ubuntu.com/UncomplicatedFirewall) (only DNS, HTTP/S, and NTP allowed)
- No access to any accounts, browser sessions, secrets, et al.

Initially, I was going to go further, and begin allow-listing every outbound hostname that OpenClaw wanted to interact with, and extensively analysed the outbound `ufw` logs, but realised this would just not be valuable. None of this protects against OpenClaw connecting to some allow-listed host, and pumping out data, keys and credentials out, due to a prompt injection or compromised skill or tool.

I was terrified to give it access to tools, to systems, worried about the [one-click exploits](https://x.com/theonejvo/status/2016510190464675980) that had been flagged. 

But for OpenClaw’s utility to maximised, it needs to have a large amount of access granted to some of the most sensitive credentials and services its owner possesses.

## So, can we trust them?

Personally, I keep a mental separation between OpenClaw's security vulnerabilities and the general security model of AI assistants. Yes, there's vulnerabilities and [plenty of them](https://github.com/openclaw/openclaw/security/advisories), but these are generally coding, control flow and logic problems. These will be solved by researchers, by SAST, DAST and SCA tools, and as the models improve, the issues will occur less frequently - but none of these mitigations change the part of the threat model I am most concerned with in the current generation of AI assistants we're using.

AI assistants require authorisation to act on your behalf, and invariably, they do this by having direct access to your long-lived credentials, your tokens, your API keys, your browser sessions, your email, and more.

And in a world where prompt injection, malicious skills, and deep supply chain attacks that specifically target software like OpenClaw - these high-value items become the real goals - account takeovers and data exfiltration.

## A basic model

So, how can we apply some basic identity concepts to AI personal assistants, and what would a more secure architecture look like?

Let’s think this through, and see how could we solve this, not just for OpenClaw, but for any future AI assistants that breaks into the mainstream.

We can split this problem into two areas, and in the Identity space, that is always going to be authentication and authorization.

### Authentication

One problem is that the assistant is just acting as **me**. It’s indistinguishable from me interacting with these services. This means it can perform any task, with no approvals, and most importantly, in response to a prompt feedback loop.

Some people have tried to tackle this by giving their assistant their own accounts, with dedicated credentials, to segregate the  identity from their own. Ostensibly, this gives you some level of protection but it then _limits_ what OpenClaw is able to do on your behalf. It can’t handle my emails, or my appointments if it does not have access to them - and forwarding emails to it doesn’t _feel_ great, it’s not the autonomous and proactive AI assistant we all want.

What we need here is the ability for an AI Assistant identity to truly act on my behalf. There needs to be an authentication event both from myself and the agent, and a composite grant created as a result that represents us **both** and what we can do.

We’re not innovating new ground here - this journey is well-documented in [RFC 8693 - OAuth 2.0 Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693).

I want the following:

- Provision an AI assistant with its own identity
- Prior to performing a privileged action, the assistant will need to request for my authorization - in order to understand that I have authorised the task, we’ll want an authentication event. Think push notification.
- The downstream service we are interacting with to understand that I have formally delegated the task to the agent.

I mentioned authorization just now, so what does that look like?

### Authorization

We need to be able to formally govern the AI assistant's ability to make tool calls through policies. These policies will determine what the assistant can do, or what authentication challenge they may need to request of the “owner” prior to making a call.

We already see "authorization" scenarios like this with Claude Code, Copilot CLI, Codex, where they prompt for permission before performing certain commands, storing your preferences as a policy. But we need more than this.

[1Password have written an interesting article](https://1password.com/blog/its-openclaw) where they’re committing to solve the problem.
[Some people are creating whole new identities for their agents](TODO 1Password Blog), with their own 1Password vault, segregating duties between the owner and the assistant - this is great, but it still doesn't stop the assistant doing things on your behalf that you do not want them to do as a result of prompt injection. So what we're really looking at here is a whole new identity layer, and expectation for third-party systems - think Open Banking levels of standardisation but across the entire digital landscape.

I want to be able to:

- Provision an AI assistant with its own identity
- Generate short-lived, scoped access tokens on my own accounts that are delegated to my assistant, that must be provided a composite identity - TODO: OAuth on behalf of flow
- I want to receive a simple, low-friction push notification, when the agent wants to perform sensitive tasks that I define with a OPA Rego policy inline with my risk tolerance, that when I accept, that's considered an authentication event, that the tool physically cannot progress without my input.
- I do not want the AI agent to ever have direct access to credentials - I want it to interact through another service, where the policies are enforced and token exchanges can occur.

The progress being made by Peter Steinberger and his OpenClaw contributors is incredible - everything is moving so fast, but what I find most exciting here is that although the entire AI assistant security model is brand new and needs to be carefully reasoned about, I think we can actually build the entire using pre-existing standards and technologies. The model Open Banking APIs must follow for you to make a bank transfer now, or grant access to your transactions, is an ideal model.

The hard part is how do we get all third-party providers meeting these standards - Peter Steinberger said something very interesting about everything needs an API or other people will build them for you, you can see this through his vast suite of tools he's bundled with OpenClaw - the downside here is that if we're needing to rely on session hijacks/headless browsers, or similar, it makes the authorisation model much harder. 

I think AI personal assistants are the future. I think tools like OpenClaw are incredible. But the whole system needs an overhaul, because people aren't going to be running these on their Raspberry Pis or Mac Minis.

I can see a world where AI assistants and what they can easily and securely integrate with will determine the markets "demand" angle, services that do not integrate securely with AI assistants will slowly fade to insignificance, the same way how 20 years ago, we made a transition to businesses, no matter how small, even if you're a sole trader plumber, you need to have a website or be on a service, otherwise you will struggle to gain the demand for your service.
