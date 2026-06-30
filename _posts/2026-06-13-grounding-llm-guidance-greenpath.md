---
layout: post
title: "GreenPath: grounding LLM immigration guidance with JSON contracts"
date: 2026-06-13 10:00:00
description: "strict JSON-contract AI features layered over official government sources"
tags: "llms product json-schema"
categories: "projects"
---

When I started GreenPath, a web app that helps people navigate the U.S. green card process, the obvious failure mode was clear from the first prototype. An LLM will happily produce confident, fluent text about immigration pathways, and some of it will be wrong. For a domain where a wrong priority date or a misread eligibility rule has real consequences, "sounds right" is not good enough. The whole project became an exercise in fencing the model in.

## Four assistants, each with a JSON contract

GreenPath is not one chatbot. It is four narrow assistants, each backed by a system prompt that ends in a strict JSON contract: a pathway advisor that takes intake answers and returns the most likely green card pathway, a stage-by-stage Q&A guide, a document review that checks forms for errors before submission, and an interview simulator that runs a USCIS-style practice interview.

The contract matters more than the prose around it. Instead of letting the model free-write, each prompt forces the output into a fixed JSON shape that the front end knows how to parse and render. That gives me a seam I can test. A free-text answer is hard to assert against. A JSON object with named fields is something I can validate, diff, and catch when it drifts. It also lets the UI stay dumb and stable: the HTML parsers expect one shape, so I can swap the model underneath without touching them.

That swap happened more than once. The backend went from Anthropic to Groq's Llama to OpenAI's gpt-4o-mini over the project's life, mostly for cost reasons. Because every provider's response gets normalized back to the same `{content:[{type:text}]}` envelope before parsing, none of those moves required rewriting the feature code. The contract was the stable interface; the model was a swappable detail.

## Grounding, and keeping the key off the client

A JSON contract stops malformed output, but it does not stop confident hallucination. The second layer is grounding. Immigration answers route through a proxy that injects real reference data, so questions about priority dates lean on the actual Visa Bulletin rather than the model's memory. A query like "EB-2 India" comes back anchored to a real wait estimate from that data, not an invented one. Across the four features I keep one rule absolute: these are guidance tools, never legal advice, and every answer points back to USCIS.gov or an accredited attorney.

The hardest lessons were not about prompting at all. Early builds called the LLM directly from the browser with the API key embedded in the page, which is convenient and completely wrong. Moving to a serverless proxy that holds the key server-side fixed the exposure but added its own traps, like a stale duplicate file hijacking which build got served. And a key once committed to git history stays compromised no matter how clean the current tree looks; rotation is the only fix.

To check the contracts actually hold, I wrote an eval harness that imports the production prompts and runs them live against the model. The point was never a vanity score. It was a regression net, so that the next time I change a prompt or switch providers, I find out immediately if the JSON stops parsing.

GreenPath was built for the USAII Global AI Hackathon. Source: [github.com/wwhaiming/greenpath](https://github.com/wwhaiming/greenpath)
