# ITEA 2026 All/Multi-Domain Operations Forum — Abstract

**Title:** Vendor-Agnostic AI as a Multi-Domain Operations Enabler: Test, Integration, and Mission Engineering Across the Kill Web

**Submission Track (primary):** Command and Control with AI/ML
**Submission Track (secondary):** Digital engineering and mission engineering

**Classification:** Distribution A — Approved for Public Release

**Word Count:** 419 / 500

---

## Abstract

Multi-domain operations (MDO) compose kill chains from sensors, processors, decision aids, and effectors that span services, classification levels, and operational domains. When each node in such a chain runs on a different vendor's machine learning stack — proprietary training frameworks, custom model formats, vendor-specific inference runtimes, single-cloud orchestration — the chain becomes brittle by construction. Models trained for an Army Project Convergence experiment cannot be re-hosted for Navy Project Overmatch without months of porting; cross-classification deployment stalls; and joint test events lose reproducibility because no two services can re-run the same model on the same data.

This presentation argues that vendor-agnostic AI is not an acquisition preference but a structural requirement of Combined Joint All-Domain Command and Control (CJADC2), and that the Test and Evaluation community is uniquely positioned to enforce it. We examine how proprietary ML stacks fragment the kill web, then present a set of mission engineering primitives — OCI-compliant containers, ONNX model interchange, Infrastructure-as-Code, and vendor-neutral experiment tracking — that restore portability across services, clouds, and classification enclaves.

Our central contribution is a T&E reproducibility framework for multi-domain ML capabilities. We show how the same primitives that prevent acquisition lock-in also enable cross-service test reproducibility: any model packaged under this framework can be re-hosted, re-evaluated, and re-integrated by a different service's test organization without dependency on the original vendor. We illustrate the framework with three multi-domain test contexts: the Chief Digital and AI Office's Global Information Dominance Experiments (GIDE), Air Force Advanced Battle Management System (ABMS) onramps, and Navy Project Overmatch integration trials. Each shows that vendor-agnostic packaging shortens cross-service integration timelines and improves T&E reproducibility, while vendor-locked deployments produce per-service test silos that cannot be aggregated into joint mission threads.

We connect the technical framework to current acquisition policy. Secretary Hegseth's November 2025 acquisition reforms mandate at least two qualified sources for critical program content explicitly to prevent vendor lock-in; CJADC2 imposes the same requirement in operational form. The two pressures converge on the same engineering primitives, which we argue should be codified in Joint T&E guidance.

The presentation contributes (1) a kill-web failure taxonomy classifying how vendor lock-in breaks specific MDO mission threads, (2) a mission engineering primitives reference architecture, (3) a T&E reproducibility framework for cross-service ML capabilities, and (4) policy alignment recommendations for Joint Test and Evaluation organizations. Audience: T&E practitioners, Program Managers, mission engineers, and acquisition officials engaged in multi-domain integration. The work provides actionable guidance for incorporating vendor-agnostic packaging into joint test planning, contract language, and mission engineering reference designs.

---

## Submission Details

- **Submission Deadline:** ~~May 1, 2026~~ **Extended to May 15, 2026** (per ITEA email April 29, 2026)
- **Forum Dates:** July 14–16, 2026
- **Location:** Alabama School of Cyber Technology and Engineering (ASCTE), 299 Wynn Dr., Huntsville, AL
- **Theme:** "Testing for the Arsenal of Freedom"
- **Forum URL:** https://itea.org/event/all-multi-domain-operations-forum/

## Differentiation from Prior Versions

To avoid duplication with the ITEA Journal long version (under review, June 2026 edition) and the Defense Acquisition Magazine short version, this MDO abstract:

- Opens with **kill-web breakage**, not acquisition theory
- Centers **CJADC2** as the structural driver (new framing)
- Introduces a **T&E reproducibility framework** as the unique contribution (not in any prior version)
- References **Project Convergence, ABMS, Project Overmatch** alongside GIDE (expanded multi-service coverage)
- Compresses **Hegseth policy** to one paragraph (deep treatment lives in the ITEA Journal version)
- Frames technical solutions as **mission engineering primitives** rather than procurement hygiene
