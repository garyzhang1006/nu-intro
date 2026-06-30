---
layout: post
title: "Building EcoRise: a hardened AI leaderboard for climate action"
date: 2026-06-15 10:00:00
description: "engineering an eval-driven, privacy-first AI product students can actually trust"
tags: "llms product evaluation privacy"
categories: "projects"
---

EcoRise started as a simple idea I describe to friends as "Kahoot for the planet": a leaderboard where students log real environmental actions and schools compete on climate impact. The hard part was never the leaderboard UI. It was making the points trustworthy. Once points rank people publicly, points effectively become money, and anything that looks like money attracts cheating, races, and edge cases. Most of my engineering time went into hardening, not features.

## Treating points like money

The core of the backend is a transactional, idempotent `point_events` ledger. Every award is an entry, idempotency keys stop double-counting, and the ledger is the single source of truth instead of a mutable score column. Around that I added membership authorization so you can only act inside your own leaderboard, anti-cheat quests, and foreign keys plus indexes so the database itself enforces the invariants. One bug I am glad I caught was a race in the leaderboard that could surface fake or partially written data; fixing it meant making the read path consistent with the ledger rather than trusting a cached aggregate.

The stack is React 19 with Vite on the front, Node and Express with SQLite (better-sqlite3) on the back. Auth is a JWT in an httpOnly cookie with CSRF protection. I wrote 20 integration tests that exercise the awarding and authorization paths, because those are exactly the places where a subtle mistake hands someone free points.

## The vision model and a real trained CNN

Logging an action needs evidence, so EcoRise verifies submitted photos. I use a Claude vision model for general eco-image understanding, but I did not want to lean entirely on a hosted model for the most common case, sorting trash. So I trained an ONNX CNN on a dataset of 3527 images. It reaches precision 0.97 with a false positive rate of 0.07. The false positive rate mattered more to me than raw accuracy, because a model that wrongly approves bad submissions is a model that lets people farm points.

## What the adversarial reviews taught me

The single most useful process change was running three adversarial code reviews against the project using a council of GPT-5.5 reviewers. They were instructed to attack the system, and they found assumptions I had stopped questioning, mostly around authorization gaps and AI gating. That loop is why the hardening went as deep as it did.

Two honest caveats remain. The repository main history still contains an old committed `.env` and `node_modules`, so any real keys need rotation before this is treated as production. And the live demo runs in demo mode with guest auto-login, which is convenient for showing the idea but is not the security posture I would ship to a real classroom.

Building EcoRise reset my intuition about what "AI app" means. The model work was maybe a fifth of the effort. The rest was making a system where a number on a screen actually deserves to be believed.

Code: [github.com/wwhaiming/EcoRise](https://github.com/wwhaiming/EcoRise)
