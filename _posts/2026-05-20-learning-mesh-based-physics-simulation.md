---
layout: post
title: "Learning mesh-based physics simulation with graph neural networks"
date: 2026-05-20 10:00:00
description: "notes on graph network simulators for fluid dynamics on unstructured meshes"
tags: "machine-learning physics graph-neural-networks simulation"
categories: "research"
---

I have been spending time with mesh-based physics simulation, specifically the line of work that started with DeepMind's MeshGraphNets. The idea is appealing: instead of running a slow numerical solver on every time step, you train a graph neural network to predict the next state of a simulation mesh directly. I worked mostly on top of the open-source [DonsetPG/graph-physics](https://github.com/DonsetPG/graph-physics) framework, which reimplements that approach in PyTorch, and I want to write down what the method actually looks like and where I got stuck.

## How the model is set up

The mesh is the graph. Each node carries a small feature vector (for the CylinderFlow case, two velocity components plus a node-type label), and each edge carries relative geometry: the displacement between its two nodes and the distance, so three edge features. The model is an encode-process-decode network. An encoder lifts node and edge features into a hidden space (size 32 in the config I used), then a fixed number of message-passing layers (5 here) update node and edge states by passing information along edges, and a decoder reads out the predicted change in velocity for the next step. The node-type label matters more than I expected: inflow, outflow, wall, and obstacle nodes are treated differently, and the loss is masked so the model is only graded on the node types it should actually be predicting.

The detail that took me longest to appreciate is training noise. The model predicts one step at a time but is used autoregressively to roll out long trajectories, so small errors compound. Adding Gaussian noise to the inputs during training (sigma around 0.02) forces the network to learn to correct itself, which is what keeps a rollout from drifting into nonsense after a few dozen steps. It is a simple trick that does a lot of work.

## Trying an adversarial variant

The supervised one-step loss tends to produce predictions that are smooth but slightly washed out, losing fine structure in the wake behind the cylinder. I forked the framework to test whether an adversarial term would help. The simulator becomes a generator, and I added a per-node discriminator built from the same message-passing blocks, conditioned on the same input graph. Because the discriminator outputs a logit per node rather than one score for the whole mesh, it is essentially a patch-GAN transposed onto a mesh, so the adversarial gradient localizes to regions that look unphysical. Training uses manual optimization in Lightning with two separate optimizers.

I want to be honest about the limits here. I do not have a GPU or the full dataset locally, so the adversarial variant is unit-tested but not yet trained at scale, and I cannot claim it improves rollout accuracy. The fork is a working hypothesis, not a result.

## A visualization to build intuition

To understand message passing rather than just run it, I also built a single-file interactive page that draws a real Delaunay mesh, animates information propagating across edges, and lets you inspect node features and compare fields. The physics there is an analytic emulation of a Karman wake, not a trained model, so it is a teaching tool, not an evaluation.

Fork: [github.com/garyzhang1006/graph-physics-gan](https://github.com/garyzhang1006/graph-physics-gan)
