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

But for OpenClaw’s utility to be maximised, it needs to have a large amount of access granted to some of the most sensitive credentials and services its owner possesses.

## So, can we trust them?

Personally, I keep a mental separation between OpenClaw's security vulnerabilities and the general security model of AI assistants. Yes, there's vulnerabilities and [plenty of them](https://github.com/openclaw/openclaw/security/advisories), but these are generally coding, control flow and logic problems. These will be solved by researchers, by SAST, DAST and SCA tools, and as the models improve, the issues will occur less frequently - but none of these mitigations change the part of the threat model I am most concerned with in the current generation of AI assistants we're using.

AI assistants currently operate through having some ability to act on your behalf, and invariably, they do this by having direct access to your long-lived credentials, your tokens, your API keys, your browser sessions, your email, and more.

In a world of prompt injection, malicious skills, and deep supply chain attacks targeting software like OpenClaw, these high-value items become the real goals, enabling account takeovers and data exfiltration.

## The problem

So, how can we apply some basic identity concepts, not just for OpenClaw, but for any AI personal assistants, and what would a more secure architecture look like?

We can split this problem into two areas, and in the Identity space, that is always going to be authentication and authorisation.

### Authentication

When we talk about authentication, we always mean “who are you?”, and in the context of AI assistants we currently see two common patterns:

- They impersonate their owner
- They have their own dedicated identity (delegation)

Starting with impersonation, why is this an issue? The assistant is just acting as **me**. It’s indistinguishable from me interacting with these services. This means it can perform any task, with no approvals, and most importantly, in response to a prompt feedback loop.

Some people have attempted to solve this with the second pattern. They give their assistant its own accounts, with dedicated credentials, to segregate the identity from their own.  This is often referred to as “Delegation”. 

[1Password have written an interesting article](https://1password.com/blog/its-openclaw) where they’re committing to solve this problem by adding broader support for these agentic identities.

1Password allows for more guarded access to credentials, it stops them being stored on disk in plain text, and you could even enforce interactive access to those credentials. Ostensibly, this gives you some level of protection but it then _limits_ what an AI assistant is able to do on your behalf. 

Without a solid authorisation model in addition to the second identity, it can’t handle my emails, or my appointments if it does not have ongoing, secure, access to them. 

Forwarding emails to it is not great, it’s not the autonomous and proactive AI assistant we all want.

I don’t think these two patterns are mutually exclusive. So, how can they both interact? And most importantly, what are they allowed to do?

### authorisation

In the Identity space, when we talk about “what can you do?”, we’re talking about authorisation.

In the above section we talked about impersonation, and a segregation of duties with a specialised agentic identity. In both scenarios, how can we gate what the assistant can do?

We could use markdown files, we could use system prompts, we could use a permissions model around tool calls (similar to that of Claude Code, Codex and Copilot CLI). We could even wait for the models to improve their prompt injection resilience and intrinsically trust them more - but these are all only operating “locally”, at a pre-API call phase, and do not solve the root issue that the agent must have access to the raw credentials in order to be able to perform the tasks it is trying to do.

Once an AI assistant decides to make a tool call, and it has the credentials, that’s the end of the road for the security model - it already has the ability to perform its task, and potentially cause damage - we need authorisation policies defined both within the assistant itself and also on the third-party services.

## An ideal flow

So what do I actually want? Let’s use a high-privileged, sensitive journey, with a clear real-world analogy.

I’m emailed an invoice, and I want my assistant to pay it on my behalf. This requires:

- Access to my mailbox
- Access to a payment service

Would I want my assistant to automatically pay this? Of course not. In the same way if I had a human assistant I would not want them to immediately pay an invoice just because it landed in my inbox. 

So what controls do we need?

- Assistant needs its own user/machine identity.
- Assistant needs read-access to **my** emails. E.g., perhaps IMAP-only, but ideally these scopes are handled at the email service layer, not just the protocol. Think how a personal assistant has access to their client’s emails today.
- The assistant needs a policy that determines whether they are allowed to perform the privileged/sensitive action, such as paying any invoices received
- If the policy is met, the assistant needs to be able to obtain authorisation **from me** to perform the action
- The payment service must verify that the assistant making the request is authorised to act on the behalf of the account principal (me)

To solve this, we need improvements to both the AI assistant’s permissions/policy model, but primarily, the services we’re interacting with need to provide some “AI Assistant-native” authorisation capabilities.

## AI Assistant Native Integrations

What we’re talking about requires third-parties to plan, design and build for these use cases. And we need this fast.

If companies do not provide these solutions, people will find workarounds, and these workarounds will have a worse risk-posture. 

Assistants used to be the preserve of the wealthy, and special tooling was not needed for them to perform sensitive actions, trust-levels were higher - soon hundreds of millions of people will have them, and the entire identity and access model for these services needs to be upgraded.

### OAuth and OpenID Connect

I want to be really clear, we are not innovating new ground here - this journey is well-supported by the [OpenID Connect Client-Initiated Backchannel Authentication (CIBA)](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) flow, and the [RFC 8693 - OAuth 2.0 Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693) specification.

**We do not need to create new standards, what we need is greater adoption.**

CIBA allows an AI assistant to create some sort of “intent” that it wants to action, the assistant can then send that intent to the authorisation server. The authorisation server can then send me a request to authenticate via an out-of-band channel - think push notification - for me to approve the request.

Once the token is issued, the AI assistants personal identity, and my authorisation, can be exchanged for the new token.

OAuth 2.0 Token Exchange results in an access token that is a composite identity of two participants:

- Actor (`act`): AI Assistant
- Subject (`sub`): User

So we need these services to not only allow us to create more fine-grained access to their respective services via their APIs, we also need them to understand that we are authorising additional actors on our accounts that can have their own permissions around highly privileged actions.

So, the specs are written, the technology exists, what’s stopping us here?

## What needs to happen?

Services providers need to transition from the expectation that one account equals one identity - “everyone” will be using these assistants and we need to be able to allow delegated access for the assistant to act on our behalf within our banking, email, travel planning, shopping systems and more.

The big tech companies who build our phones and our social media need to treat AI assistants as a first-class identity that can interact with our accounts.

The whole system needs an overhaul, because people aren't going to be running these assistants on their Raspberry Pis or Mac Minis. They aren’t going to be threat-modelling their setup. They want magic.

This isn’t going to be optional. This is the same journey banks went through with the Open Banking push. The banks that got there first with adopting the FinTech regulations, are the ones that are winning today. The ones that didn’t are being screen-scraped by spurious software and are putting their customers and their data at risk.

Users need simple, low-friction approval flows, that fit into their day-to-day life. Think push notifications, not config files.

What happens if services don’t do this?

20 years ago, we made a transition, no matter how small your business is, you need to have a website or be using an online service for customer acquisition, otherwise you will struggle and your service will suffer.

Now? If an AI assistant can’t securely interact with, or see, your service - you **will** struggle and your service **will** suffer.