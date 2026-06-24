---
theme: default
background: https://source.unsplash.com/collection/94734566/1920x1080
class: text-center
highlighter: shiki
lineNumbers: false
info: |
  ## Vendor-Agnostic AI as a Multi-Domain Operations Enabler
  ITEA 2026 All/Multi-Domain Operations Forum
  July 14–16, 2026 · Huntsville, Alabama
drawings:
  persist: false
transition: slide-left
title: "Vendor-Agnostic AI as a Multi-Domain Operations Enabler: Test, Integration, and Mission Engineering Across the Kill Web"
mdc: true
---

# Vendor-Agnostic AI as an MDO Enabler

**Test, Integration, and Mission Engineering Across the Kill Web**

Sam Bright · Michael Soltys

GBL Systems Corporation

ITEA All/Multi-Domain Operations Forum · July 14–16, 2026 · Huntsville, AL

"Testing for the Arsenal of Freedom"

---

# Vendor Lock-In Degrades the Kill Web

### When Every Node Runs a Different ML Stack

- **Army (Project Convergence)** — proprietary training frameworks, custom model formats
- **Navy (Project Overmatch)** — vendor-specific inference runtimes
- **Air Force (ABMS)** — single-cloud orchestration

### Three Failure Modes That Degrade MDO Mission Threads

- **Porting latency** — a model trained for Project Convergence cannot be re-hosted for Project Overmatch without months of work
- **Cross-classification stall** — proprietary runtimes do not transfer across classification enclaves
- **Test silos** — joint test events lose reproducibility because no two services can re-run the same model on the same data

Vendor lock-in is not an acquisition inconvenience — it is a **structural source of fragility in the kill web**

---

# CJADC2 Requires Interoperability — AI Lock-In Prevents It

### The CJADC2 Mandate

Combined Joint All-Domain Command and Control integrates sensors, processors, decision aids, and effectors spanning **all five domains**: land, air, sea, space, and cyberspace.

| Domain | Example Capability | Lock-In Risk |
|--------|--------------------|--------------|
| Land   | Autonomous target acquisition (Project Convergence) | Proprietary PyTorch + Azure inference |
| Air    | ABMS sensor fusion | Vendor-specific ONNX runtime fork |
| Sea    | Project Overmatch kill-chain automation | Single-cloud AWS inference stack |
| Space  | SDA sensor mesh | Proprietary model format |
| Cyber  | AI-driven threat detection | Platform-tied model serving |

### The Core Tension

AI/ML compresses the sensor-to-shooter timeline — but **only if models can be re-hosted, re-evaluated, and re-integrated** across services without dependency on the original vendor.

Vendor-agnostic AI is not an acquisition preference — it is a **structural requirement of CJADC2**

---

# The Mission Engineering Primitives

### Four Technical Building Blocks That Restore Portability

**1. OCI-Compliant Containers**

Package ML models and inference environments in Open Container Initiative images. Any OCI-compliant runtime (Docker, Podman, containerd) on any cloud or enclave can execute the workload.

**2. ONNX Model Interchange**

The Open Neural Network Exchange format decouples training frameworks from inference runtimes. Train in PyTorch or TensorFlow; deploy anywhere ONNX Runtime runs — including air-gapped enclaves.

**3. Infrastructure-as-Code**

Terraform or Pulumi definitions make deployment environments fully reproducible. A test configuration authored for AWS GovCloud can be instantiated on Azure Government or an on-premise enclave with parameter changes, not a rewrite.

**4. Vendor-Neutral Experiment Tracking**

MLflow or DVC capture hyperparameters, training data references, dependency specifications, and environmental configurations — enabling migration of development workflows between vendors without losing institutional knowledge.

These primitives apply at the same layer where vendor lock-in enters — and they compose into a **T&E reproducibility framework**

---

# The T&E Reproducibility Framework

### Packaging for Cross-Service Re-Evaluation

A model packaged under this framework can be **re-hosted, re-evaluated, and re-integrated** by a different service's test organization without dependency on the original vendor.

```
┌─────────────────────────────────────────────────┐
│  ML Capability Package (service-agnostic)        │
│                                                  │
│  ┌─────────────┐  ┌─────────────┐               │
│  │ ONNX Model  │  │  MLflow     │               │
│  │ (framework- │  │  Experiment │               │
│  │  neutral)   │  │  Record     │               │
│  └─────────────┘  └─────────────┘               │
│  ┌─────────────┐  ┌─────────────┐               │
│  │ OCI         │  │  IaC        │               │
│  │ Container   │  │  Terraform  │               │
│  │ Image       │  │  Definition │               │
│  └─────────────┘  └─────────────┘               │
└─────────────────────────────────────────────────┘
         ↓                    ↓                ↓
   Army ATEC            Navy NAVAIR      Air Force AFOTEC
   (re-host)          (re-evaluate)     (re-integrate)
```

**Result:** Any T&E organization can reproduce the test, not just the originating vendor

---

# Kill-Web Failure Taxonomy

### How Vendor Lock-In Breaks Specific MDO Mission Threads

| Failure Class | MDO Thread Affected | Root Cause |
|---------------|---------------------|------------|
| **Framework Lock** | Army-to-Navy model transfer (Convergence → Overmatch) | PyTorch checkpoint cannot run on vendor B's serving stack |
| **Runtime Lock** | Air-to-Space sensor fusion (ABMS → SDA) | Vendor fork of ONNX runtime breaks spec compliance |
| **Cloud Lock** | GIDE cross-command AI sharing | Model artifact tied to AWS SageMaker lineage format |
| **Enclave Lock** | IL4 → IL6 capability promotion | Container image built with commercial-cloud libraries, no air-gapped equivalent |
| **Observation Lock** | Joint after-action review | Experiment metadata in vendor-proprietary format; cannot replay on peer service infrastructure |

### The Common Thread

Every failure class produces the same outcome: **per-service test silos** that cannot be aggregated into joint mission threads.

---

# Three Multi-Domain Test Contexts

### GIDE: Global Information Dominance Experiments (CDAO)

- Multi-domain AI-enabled decision superiority experiments across combatant commands
- **Vendor lock-in impact:** AI models authored for GIDE-N cannot be re-run at GIDE-N+1 if the vendor has changed serving infrastructure; experiment baselines break
- **Framework fix:** OCI images + MLflow records as the GIDE artifact standard

### ABMS: Advanced Battle Management System (Air Force)

- Sensor-to-shooter network across air and space domains
- **Vendor lock-in impact:** Proprietary inference runtimes in ABMS onramps prevent Army and Navy sensor adapters from contributing ML components without full vendor re-engagement
- **Framework fix:** ONNX as the interchange format for all ABMS AI nodes

### Project Overmatch (Navy)

- Kill-chain automation in the maritime domain
- **Vendor lock-in impact:** Models ported from Project Convergence require months of re-integration; joint test windows missed
- **Framework fix:** IaC definitions as the Overmatch re-hosting specification

Vendor-agnostic packaging **shortens cross-service integration timelines** and produces reproducible joint test records

---

# Policy Convergence: WAS + CJADC2

### Two Mandates, One Engineering Answer

**Secretary Hegseth's Warfighting Acquisition System (Nov 7, 2025)**

- Renamed Defense Acquisition System → "Warfighting Acquisition System"
- Core mandate: *"Maintain at least two qualified sources for critical program content"* specifically to prevent vendor lock-in
- "Speed to capability delivery is now our organizing principle"
- Commercial-first, modular, performance-based contracting

**CJADC2 Operational Requirements**

- Joint interoperability across all five domains and coalition partners
- No single service's ML stack can be the authoritative runtime for joint capabilities
- Cross-classification portability from NIPRNet IL4 through SIPRNet IL6

### The Convergence Point

Both mandates require the same engineering primitives: OCI containers, ONNX interchange, IaC, vendor-neutral tracking.

WAS policy + CJADC2 architecture + T&E reproducibility framework = **a single codifiable standard for Joint T&E guidance**

---

# Deploying Across Classification Enclaves

### The Enclave Portability Problem

| Level | Environment | Vendor Lock-In Risk |
|-------|-------------|---------------------|
| **IL4** | NIPRNet | Cloud-specific model serving (SageMaker, Vertex AI) |
| **IL5** | NIPRNet Sensitive | US-citizen-only enclaves; some commercial ML tooling unavailable |
| **IL6** | SIPRNet | Air-gapped; commercial cloud inference completely unavailable |
| **DDIL** | Tactical Edge | Disconnected; model must run containerized on organic compute |

### Framework Solution Per Level

- **IL4 → IL5 promotion:** IaC definition parameterizes cloud provider; ONNX model unchanged
- **IL5 → IL6 promotion:** OCI image carries its own runtime; no internet dependency
- **IL6 → DDIL:** Slim OCI image + quantized ONNX model fits on edge compute (Jetson, GPU-equipped tactical servers)

The same four primitives that prevent acquisition lock-in **also enable cross-enclave capability promotion**

---

# Recommendations for Joint T&E Guidance

### Codifying Vendor-Agnostic Standards

**1. Mandatory Artifact Standard**

All ML capabilities submitted for Joint T&E events must include: ONNX model export, OCI container image, IaC deployment definition, MLflow experiment record. No proprietary-only artifacts accepted.

**2. Cross-Service Re-Evaluation Requirement**

Every AI capability in a joint test event must be re-hostable by at least one peer-service T&E organization within 30 days, using only the submitted artifact package.

**3. Contract Language**

Incorporate dual-source and open-artifact requirements into AI/ML task order language. Data rights provisions must ensure government ownership of model weights and training metadata.

**4. PAE Integration**

Portfolio Acquisition Executives (established under WAS) should treat vendor-agnostic packaging as a gate criterion for AI capability advancement across program phases.

These four recommendations directly implement the WAS dual-source mandate in the AI/ML domain

---

# What T&E Practitioners Can Do Now

### Immediate Actions (0–90 Days)

- **Audit current AI/ML contracts** for vendor lock-in provisions; identify capabilities with no second source
- **Require ONNX exports** in all new AI/ML task orders as a deliverable line item
- **Stand up a multi-vendor inference evaluation** on a single test dataset to establish a reproducibility baseline

### Near-Term (90–180 Days)

- **Adopt MLflow** (or equivalent open tracker) as the experiment record standard for all AI T&E events
- **Draft IaC templates** for the two or three most common enclave configurations (IL4 GovCloud, IL5 dedicated, IL6 on-premise GPU)
- **Include cross-service re-host** as a T&E success criterion alongside traditional performance metrics

### Policy Track (Ongoing)

- **Engage PAEs** to incorporate vendor-agnostic packaging criteria into AI/ML source selection
- **Submit to Joint T&E community** for codification in joint test guidance
- **Align with CJADC2 architecture boards** to standardize the artifact format across services

The T&E community is uniquely positioned to champion vendor-agnostic AI — through test criteria, contract language, and cross-service reproducibility standards

---
layout: end
class: text-center
---

# Closing: T&E as a Driver of MDO Resilience

### The Problem

Proprietary ML stacks introduce fragmentation that degrades kill-web coherence — making it harder for Army, Navy, and Air Force AI to share models across services, clouds, and classification enclaves.

### The Framework

OCI containers · ONNX interchange · Infrastructure-as-Code · Vendor-neutral experiment tracking

Any model packaged under this framework is re-hostable, re-evaluable, re-integrable — by any service, in any enclave.

### The Policy Hook

WAS dual-source mandate + CJADC2 interoperability requirement = the same four engineering primitives, already mandated, waiting to be applied.

### The Ask

Codify vendor-agnostic packaging in Joint T&E guidance. Make it a test criterion, not a preference.

T&E practitioners are well positioned to help build the arsenal of freedom.

**Sam Bright · Michael Soltys**  
GBL Systems Corporation

Distribution A — Approved for Public Release
