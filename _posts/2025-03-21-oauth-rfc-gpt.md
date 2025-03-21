---
layout: post
lang: en
author: "Tim Searle"
title:  "A Custom GPT for OAuth & OIDC"
date:   "2025-03-21 00:00:00"
tags:
  - "oauth"
  - "identity"
  - "chatgpt"
---

If you’ve ever felt lost navigating OAuth specs, or any IETF RFCs for that matter, you’re not alone. For the last few years, I’ve been working on an identity migration project that has been heavily tied to OAuth and OpenID Connect. Ensuring that our system and its integrations comply with, or extend, the OAuth and OpenID Connect standards has been one of our key north stars and informs almost all of our design decisions.

There are over 25 individual specifications, covering everything from core OAuth 2.0 and Bearer Tokens to extensions like Token Exchange and JSON Web Tokens, and these documents are owned and maintained by multiple organisations - the IETF and the OpenID Foundation. These specifications are incredibly detailed and can be difficult to understand, particularly for those who are new to the standards. A lot of these RFCs are actually extensions of the original specifications, and it can be difficult to actually locate the specification most aligned to your requirement/need. 

For example, a defined token revocation mechanism is not mentioned at all in the OAuth 2.0 Authorization Framework [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749), but is instead defined within an extension of that specification, OAuth 2.0 Token Revocation [RFC 7009](https://datatracker.ietf.org/doc/html/rfc7009). 

I needed a better way to navigate all of this.

Enter [ChatGPT](https://chatgpt.com). 

It was clear to me that ChatGPT had been trained on the full IETF archive of RFCs. These documents are plain text (ASCII) and follow a well-defined and consistent structure, which plays to an LLM’s strengths in parsing and retrieving text-based information.

However, finding the right spec was becoming a time sink. After weeks of juggling ChatGPT answers and subsequent Google searches, I found myself continually having to refine my queries. ChatGPT often gave plausible-sounding replies that were inaccurate, which meant I had to double-check everything against multiple RFCs anyway. Sigh.

I found myself continually needing to craft the appropriate prompt, asking for specificity and accuracy to be prioritised over "helpfulness" and to ensure that it always cited the relevant IETF RFC number and section.

This constant back and forth and repetitive re-prompting led me to decide to try the [OpenAI custom GPT functionality](https://openai.com/index/introducing-gpts/).

## Introducing the OAuth RFC Assistant

My focus when creating the custom GPT was quite simple, I needed to ensure the following requirements:

- Always cite the RFC number and section.
- Never make assumptions or extrapolate beyond what the RFC states.

![OAuth RFC Assistant](/assets/images/oauth-assistant.png)

After several months of using the assistant and tweaking the prompts - I'm really pleased to share the [OAuth RFC Assistant](https://chatgpt.com/g/g-6731ea7a6678819082e7127e495a3b3a-oauth-rfc-assistant) for others to use!

And I love it. 

Members of my team and other developers in the identity space have also found it really useful. It’s accelerated our decision-making and made the standards much more digestible.

## Prompting Takeaways

Here are a few lessons learned while crafting the appropriate prompts to drive the behaviour of the custom GPT:

- Test how it handles incorrect or trick questions - ask it leading questions you know to be incorrect to ensure it doesn't make assumptions. Effectively - validate your error cases! We all know how easy it is to lead the witness with ChatGPT.

> **Me:** Why does every grant type always require a client secret?
> 
> **OAuth RFC Assistant:** Not every OAuth 2.0 grant type requires a client secret—this depends on the type of client and the grant type being used. The requirement for a client secret is governed by RFC 6749 (OAuth 2.0) and is primarily determined by whether the client is classified as confidential or public.

- Give it clear constraints it must operate within - always cite the RFC number and section. This forces the GPT to derive an answer with a clear structure which minimises (but does not remove) hallucinations. This is very helpful for when you have a rough idea of a concept, but no idea what the formal RFC is.

![On-behalf-of](/assets/images/on-behalf.png)

- Tell it specifically what you want it to do when it doesn't know the answer.

> **Prompt**: If a detail is not mentioned in an RFC or OIDC specification, the assistant will explicitly state that the information is unavailable, unspecified, or unknown.

- Give hints about the format you expect in the answer.

> **Prompt**: It highlights compliance levels (e.g., MUST, SHOULD) as defined in the documents without ambiguous interpretations.

## Summary

This **tool** has been a real accelerator for my team - but it's so important to remember that this is all it is. It's a tool. I still always use its answers to expedite a dive into the appropriate RFC and section to validate the information. It’s a great way to get a quick answer and to navigate hundreds of documents (and thousands of lines of standards), but it’s not a replacement for building out subject-matter expertise that comes from engaging with the RFCs directly.

Please give the [OAuth RFC Assistant](https://chatgpt.com/g/g-6731ea7a6678819082e7127e495a3b3a-oauth-rfc-assistant) a try, and let me know how you get on and if you have any feedback!
