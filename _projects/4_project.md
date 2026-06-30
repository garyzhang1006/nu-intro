---
layout: page
title: EcoRise
description: a gamified AI leaderboard for real-world environmental action — "Kahoot for the planet"
img: assets/img/6.jpg
importance: 3
category: work
---

EcoRise turns environmental action into a classroom game. Students log real-world eco-actions, an AI verifies them, and schools climb a live leaderboard — "Kahoot for the planet."

Key pieces:

- **Trained vision model** — a custom ONNX trash-classifier CNN (3,500+ images, precision 0.97) checks photo evidence, paired with an LLM Eco-Coach for conversational guidance and school "hidden-footprint" insights grounded in EPA / Our World in Data factors.
- **"Points = money" integrity** — a transactional, idempotent point-events ledger with anti-cheat quests, membership authorization, and AI gates, so the leaderboard can't be gamed.
- **Privacy by design** — a FERPA/COPPA engine that enforces a consent gate before any AI call, minimizes and auto-purges image data, supports teacher review with exact point reversal, and keeps a tamper-evident audit log plus full account export and delete.
- **Evaluated, not vibes** — an in-app report card built from a real eval harness: retrieval Recall@k / MRR, deterministic numeric claim-verification, and refusal-precision tracking.

Built with React + Vite, Node/Express, and SQLite, with JWT (httpOnly cookie) + CSRF auth. Hardened through adversarial model-vs-model code reviews; 86 backend integration tests passing.

Live demo: [ecorise-demo.onrender.com](https://ecorise-demo.onrender.com) · Source: [github.com/wwhaiming/EcoRise](https://github.com/wwhaiming/EcoRise)
