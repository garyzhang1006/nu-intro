---
layout: post
title: "Exos: classifying exoplanets from Kepler and TESS data"
date: 2026-04-28 10:00:00
description: "an ONNX exoplanet classifier and what the light-curve data taught me"
tags: "machine-learning astronomy onnx"
categories: "projects"
---

When NASA's Kepler telescope watched a star dim slightly and repeatedly, it could mean a planet crossing in front of it, or it could be two stars eclipsing each other, instrument noise, or a quirk in the data. Telling a real transit from a false alarm is a genuine triage problem that astronomers spend real effort on. I built Exos, a small machine learning model that does that triage in the browser, on real NASA data, and pairs it with an AI tutor that explains the reasoning.

## The data and the leakage trap

I trained on two NASA Exoplanet Archive catalogs: the Kepler cumulative KOI table and the TESS TOI table. Combined, that is 17,492 objects of interest, of which 10,253 are labeled CONFIRMED or FALSE POSITIVE (4,070 planets, 6,183 false positives). The still-unconfirmed candidates are held out as "unknowns" you can test.

The biggest mistake I had to avoid was label leakage. The KOI table ships with NASA's own false-positive flags, which encode the human verdict. A model that sees those columns just memorizes the answer and learns no physics. So I dropped them and trained only on 11 physical measurements: orbital period, transit depth and duration, inferred planet radius, equilibrium temperature, insolation, signal-to-noise, impact parameter, and the host star's temperature, gravity, and radius.

Merging TESS in was the part I underestimated. TESS reports period, duration, depth, planet radius, temperatures, and host-star properties, but it does not report Kepler's model SNR or impact parameter. Rather than drop those two features or those rows, I left them as NaN for TESS and median-imputed them alongside everything else. The two missions also use different disposition codes, so I wrote a small map (CP and KP to confirmed, FP and FA to false positive, PC and APC to candidate) onto the same schema.

## The model and what it learned

The shipped classifier is a gradient-boosting model in scikit-learn, 400 trees at depth 3, exported to ONNX so it runs client-side with ONNX Runtime Web. No server is needed to make a prediction. On a held-out 20% test split it reaches 0.902 accuracy, 0.963 ROC-AUC, and 0.881 F1, with 5-fold cross-validated AUC of 0.958. I also fit a logistic regression on standardized features as an interpretable surrogate; it is weaker (0.858 AUC) but it drives a "why" panel that shows which measurements pushed each call.

What I find convincing is that the model still works without the answer key. It learns the actual physics: an inferred radius of tens of Earth-radii is star-sized and means false positive, a grazing transit with high impact parameter is suspect, low signal-to-noise often means noise. You can drag the planet-radius slider up and watch a confirmed verdict flip.

The AI tutor (GPT-4o-mini, behind a tiny Python proxy that keeps the key server-side) is deliberately narrow. It is given the model's verdict and the real numbers and told to explain the transit method, never to re-decide. The right role for an LLM here is to explain a trustworthy model, not to be the model.

Code: [github.com/garyzhang1006/exos](https://github.com/garyzhang1006/exos)
