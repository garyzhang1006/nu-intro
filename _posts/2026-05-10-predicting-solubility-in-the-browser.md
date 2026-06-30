---
layout: post
title: "Solu: predicting molecular solubility in the browser"
date: 2026-05-10 10:00:00
description: "RDKit-JS plus ONNX for fully client-side cheminformatics ML"
tags: "machine-learning chemistry onnx web"
categories: "projects"
---

I built a small tool called Solu for a hackathon (DSH Hacks V1, theme AI x STEM education). It predicts a molecule's water solubility from its structure and then tries to explain why, and the prediction runs entirely in the browser. No server, no API call, no large language model in the prediction path. You type or pick a molecule and it answers locally.

## How it works

The pipeline is short. You enter a SMILES string (or pick one of 14 examples), RDKit-JS compiled to WebAssembly draws the 2D structure and computes nine interpretable descriptors: Crippen LogP, molecular weight, topological polar surface area, hydrogen-bond donors and acceptors, rotatable bonds, aromatic rings, fraction of sp3 carbon, and ring count. Those nine numbers feed a gradient-boosting model trained in Python with scikit-learn, exported to ONNX, and run client-side through ONNX Runtime Web. The model is deterministic, so the same molecule always gives the same answer.

I trained on the Delaney/ESOL dataset, a published set of 1,128 measured aqueous solubilities. On a held-out 20% test set the shipped gradient-boosting model gets RMSE 0.75 log units and R2 0.88, compared to RMSE 1.04 for the classic linear ESOL equation on the same split. That improvement from 1.04 to 0.75 is the one number I actually care about, because it is measured on data the model never saw.

There is also a "why" panel. A separate interpretable linear surrogate breaks the prediction into per-property contributions, so you can see that, say, high LogP pushed a molecule toward insoluble. The goal was teaching, not just a number.

## The part that was actually hard

The model trains in Python but runs in the browser, and those are two different RDKit builds. If the two builds compute a descriptor even slightly differently, the browser prediction drifts away from the trained model and nobody notices. This is exactly what bit me: the definition of the hydrogen-bond-acceptor count changed between RDKit versions. The fix was unglamorous but necessary, pinning Python rdkit==2025.3.4 to match RDKit-JS 2025.03.4.

To keep it honest I added parity gates. One checks RDKit-JS descriptors against RDKit-Python to 1e-5 (rounding only). Another checks ONNX output against scikit-learn. A third runs the full browser chain, RDKit-JS into ONNX Runtime Web, and confirms it reproduces the Python prediction bit-for-bit, diff 0.0. With those gates, browser predictions are provably identical to the trained model rather than approximately identical.

## What I learned

The interesting engineering was not the model, it was making "train here, run there" trustworthy. A gradient-boosting model on nine descriptors is unremarkable; the descriptors agreeing across two language ecosystems is where the bugs hide. There is also an optional tutor card (Claude Sonnet behind a small local proxy) that explains a prediction using structurally nearby real measured molecules, but I kept it strictly optional so the core tool stays fully offline and deterministic.

Code: [github.com/garyzhang1006/solu](https://github.com/garyzhang1006/solu)
