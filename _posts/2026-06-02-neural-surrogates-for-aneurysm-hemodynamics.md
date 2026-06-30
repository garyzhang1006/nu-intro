---
layout: post
title: "Predicting aneurysm blood flow with learned surrogates"
date: 2026-06-02 10:00:00
description: "what I am working on in the UPenn lab: 2D/3D hemodynamics surrogates on vessel meshes"
tags: "machine-learning physics cfd biomedical"
categories: "research"
---

For the last few months I have been working in a lab at UPenn on predicting blood flow inside aneurysms. The goal is a learned surrogate: instead of running a full CFD simulation for every new vessel geometry and inflow waveform, train models that produce the velocity field directly. This post is about the 2D version of the problem, where I have spent most of my time trying to understand the architecture and fix its training.

## Decomposing the flow

The core idea is not to predict the raw velocity field node by node and timestep by timestep. That is a lot of correlated output. Instead, for each trajectory the velocity field is decomposed into three pieces:

`U(x, t) = u_mean(x) + V(x) @ A(t)^T`

Here `u_mean(x)` is the time-mean velocity at each mesh node, `V(x)` is a small per-node POD mode basis (we keep the top 4 modes), and `A(t)` is the set of time-varying coefficients that turn those static modes into a moving flow. Classical POD gets these from an SVD of the simulated field. The surrogate replaces each piece with a learned model so it can generalize to geometries it never simulated.

So there are three models. A geometry-aware spatial neural operator predicts the mode basis `V` per node. A recurrent model (a coefficient LSTM) predicts the time coefficients `A` from the inflow waveform. And a MeshGraphNet-style operator predicts the time-mean field `u_mean`, learning a residual over a blurred prior rather than the field from scratch.

## What the geometry forces you to do

The thing that surprised me is how much of the design is about the sac. A vessel is mostly tube-like fluid, but the aneurysm sac is a small fraction of the nodes where the interesting recirculation happens, so a plain mean-squared loss just ignores it. The pipeline carries signed distance features (distance to the wall, signed distance to the sac neck) and splits nodes into vessel, neck, and sac regions, weighting the loss by inverse frequency so the rare sac nodes actually count. The conditioning is sac-aware too: it pools features separately over the whole graph and over sac-only nodes.

## The part that was hard

My main assignment was the training curves, which looked off. The mean model showed roughly a 2.75x train-to-validation gap with a validation loss that climbed while training loss kept dropping, and the coefficient model plateaued in validation long before training did. Textbook overfitting. The fixes were unglamorous and incremental: cut model capacity (hidden width 256 to 128, fewer layers), raise regularization (more dropout, larger weight decay), and lean harder on the retrieval prior so the mean model has less to invent. That narrowed the gap. The sac region is still the hardest part of the field, and data augmentation is the next lever I want to try.

Code: [rmallela26/aorta_modeling](https://github.com/rmallela26/aorta_modeling)
