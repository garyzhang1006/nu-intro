---
layout: page
title: Learned mesh-based physics simulation
description: graph neural networks that predict fluid dynamics on unstructured meshes
img: assets/img/12.jpg
importance: 2
category: work
---

Research project on learning physics simulators with graph neural networks. A GNN trained on mesh-based fluid simulations (cylinder flow with Karman vortex shedding) predicts the next state from the current one, replacing an expensive numerical solver at inference time.

Current focus:

- **Rollout drift** — autoregressive prediction accumulates error; small per-step MSE still blurs fine vortex structure over long rollouts.
- **Adversarial training** — adding a GAN discriminator and temporal consistency losses to keep long rollouts sharp instead of regressing to the mean.
- **Interactive visualization** — a browser tool with Delaunay mesh rendering, switchable scalar fields (velocity, pressure, vorticity), ground-truth vs. prediction comparison, and a per-node inspector.

<!-- EDIT ME: add a screenshot or animation of the viz to assets/img/ and reference it here. -->
