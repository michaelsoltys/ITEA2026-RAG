---
theme: default
background: https://source.unsplash.com/collection/94734566/1920x1080
class: text-center
highlighter: shiki
lineNumbers: false
info: |
  ## Taming the Beast: Secure RAG for T&E Report Automation
  ITEA Test Instrumentation Workshop 2026
  April 28–30, 2026 · Las Vegas, Nevada
drawings:
  persist: false
transition: slide-left
title: "Taming the Beast: Secure RAG for T&E Report Automation"
mdc: true
---

# Taming the Beast

**Secure Retrieval-Augmented Generation for T&E Report Automation in Classified Environments**

Sam Bright · Michael Soltys

GBL Systems Corporation

ITEA Test Instrumentation Workshop · April 28–30, 2026 · Las Vegas, NV

Track 6 · Siena Room · Wed April 29 · 1:30–2:00 PM

<!--
Michael opens. Welcome everyone. We're Michael Soltys and Sam Bright from GBL Systems. This talk is about Retrieval-Augmented Generation — RAG — as a production AI capability for Department of War Test and Evaluation programs. Michael will cover the why and the how: what RAG is, how it works, the architecture for production deployment, and the security controls required for CUI and classified data. Then Sam will walk through a real Navy case study — RustyAI — and show how few-shot prompting turns RAG from a Q&A chatbot into an automated report generator.
-->

---

# Why RAG? The Problem with Standalone LLMs

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### <span style="color: #6b21a8;">Three Critical Failure Modes</span>

- **Knowledge staleness** — test procedures, MIL-STDs, and specs evolve continuously; LLM weights are frozen at training time
- **Hallucination** — models generate plausible but incorrect outputs in safety-critical reporting
- **Non-traceability** — outputs cannot be traced to authoritative sources, violating DoW documentation standards

</div>

<div>

### <span style="color: #6b21a8;">Fine-Tuning Is Not the Answer</span>

- High retraining compute costs, must repeat with new data
- Degrades performance outside the fine-tuned domain
- No source attribution for auditability
- Increased vendor lock-in with a single LLM

</div>

</div>

<div class="text-2xl italic text-left mt-6" style="color: #2E7D32; border-left: 4px solid #2E7D32; padding-left: 16px;">
RAG combines a librarian with a language model: the librarian searches, the model writes.
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
Let's start with why we need RAG at all. Large Language Models are powerful, but they have three critical failure modes for T&E work. First, knowledge staleness — your test procedures, system specs, and MIL-STDs are constantly updating, but the model's weights are frozen. Second, hallucination — in safety-critical reporting, a plausible-sounding but wrong answer can be dangerous. Third, non-traceability — DoW documentation standards require cited, auditable evidence, and a standalone LLM can't tell you where its answer came from.

Fine-tuning doesn't solve these problems. It's expensive, it degrades the model on tasks outside the fine-tuned domain, and it still can't access new information. The simplest mental model: RAG combines a librarian with a language model. The librarian finds the right documents; the model reads them and writes the answer.
-->

---

# How RAG Works

<div class="grid grid-cols-2 gap-6 mt-4">

<div>

### <span style="color: #6b21a8;">The Four-Stage Pipeline</span>

1. **Document Ingestion** — Parse, normalize, and chunk T&E artifacts (test plans, MIL-STDs, specs, reports)
2. **Embedding & Indexing** — Encode chunks into dense vectors; store with metadata (classification, date, system ID)
3. **Query-Time Retrieval** — Embed the user's query; find top-*k* most similar chunks via cosine similarity
4. **Augmented Generation** — Inject retrieved chunks into the LLM context; generate a grounded, cited response

</div>

<div>

### <span style="color: #6b21a8;">Key Insight: Semantic Search</span>

Embeddings encode **meaning**, not keywords:

- *"the dog chased the ball"*
- *"a puppy ran after a sphere"*

These map to **nearby points** in vector space — enabling retrieval that keyword search cannot achieve.

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded mt-4 text-center">
RAG accuracy: <strong>107–177% improvement</strong> over zero-shot LLM baselines on domain QA tasks
</div>

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
Here's how RAG works at a high level. It's a four-stage pipeline. First, you ingest your documents — test plans, MIL-STDs, specifications, previous reports — and chunk them into manageable pieces. Second, you embed each chunk into a dense vector representation and store it in a vector database with metadata. Third, when a user asks a question, you embed the query and find the most semantically similar chunks. Fourth, you inject those chunks into the LLM's context window and generate a response grounded in that evidence.

The key insight is that embeddings capture meaning, not just keywords. Two sentences with completely different words but the same meaning will be near each other in vector space. Studies show 107 to 177 percent accuracy improvement when RAG is applied versus zero-shot LLM baselines.
-->

---

# Naive vs. Advanced RAG

<div class="grid grid-cols-3 gap-3 mt-3">

<div class="border-2 border-blue-500 p-3 rounded">

### <span style="color: #6b21a8;">Naive RAG</span>

Single-pass retrieve-then-generate

- Prone to low-precision retrieval
- Context misalignment
- No quality filtering

</div>

<div class="border-2 border-yellow-500 p-3 rounded">

### <span style="color: #6b21a8;">Advanced RAG</span>

Multi-stage processing pipeline

- Query rewriting & expansion
- Re-ranking (3.4x precision improvement)
- Post-retrieval compression
- Relevance filtering

</div>

<div class="border-2 border-green-500 p-3 rounded">

### <span style="color: #6b21a8;">Agentic RAG</span>

LLM orchestrator decides autonomously

- When retrieval is needed
- Multi-hop sub-queries
- Iterative retrieval rounds
- Already in DoD AI RCC pilots

</div>

</div>

<div class="bg-blue-100 dark:bg-blue-900 p-2 rounded mt-3 text-center text-base">
Production T&E deployments require <strong>Advanced RAG</strong> at minimum — naive RAG is not sufficient
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
RAG implementations have evolved through several generations. Naive RAG does a simple single-pass retrieve-then-generate, but it's prone to retrieving the wrong chunks and misaligning context. Advanced RAG adds query rewriting, re-ranking, and relevance filtering. Re-ranking alone provides a 3.4x improvement in retrieval precision. Agentic RAG is the emerging frontier where the LLM autonomously decides when to retrieve, formulates sub-queries, and integrates multiple retrieval rounds. For production T&E, you need Advanced RAG at minimum.
-->

---

# Chunking & Hybrid Search: Getting Retrieval Right

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### <span style="color: #6b21a8;">Chunking Strategy Matters</span>

| Chunk Size | Faithfulness | Relevancy |
|-----------|-------------|-----------|
| 256 tokens | 95.56% | **97.78%** |
| 512 tokens | **97.59%** | 96.67% |
| 2048 tokens | 80.37% | 91.11% |

- **Sliding window** with overlap outperforms fixed chunking
- **Semantic-boundary** chunking (paragraph/section) preferred for structured T&E documents

</div>

<div>

### <span style="color: #6b21a8;">Hybrid Search</span>

Combines dense vector search + sparse BM25 keyword search:

$$S_h = \alpha \cdot S_s + S_d$$

At optimal $\alpha = 0.3$:
- **mAP: 47.14** (vs. 30.13 BM25 alone)
- **nDCG@10: 72.50**

Essential for T&E terminology: MIL-STD designators, system nomenclature, test procedure IDs

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
Two critical retrieval engineering decisions. First, chunking strategy: 512-token chunks achieve the highest faithfulness at 97.59%, while 2048-token chunks drop to just 80%. The sliding window approach with overlap prevents boundary information loss.

Second, hybrid search. Pure vector search excels at semantic matching but misses exact terminology. BM25 keyword search captures precise terms but lacks semantic understanding. Combining both — with optimal weighting at alpha 0.3 — substantially outperforms either alone. This is essential for T&E, where you need to match exact designators like MIL-STD numbers alongside semantic queries.
-->

---

# Production Architecture: Five Layers

<div class="grid grid-cols-5 gap-2 mt-4">

<div class="border-2 border-blue-500 p-3 rounded text-sm">

### <span style="color: #6b21a8;">L1: Ingest</span>

SharePoint, SIPR file shares, PDFs, TDPs

OCR, table extraction

Metadata enrichment

Deduplication

</div>

<div class="border-2 border-yellow-500 p-3 rounded text-sm">

### <span style="color: #6b21a8;">L2: Index</span>

Semantic chunking (256–1024 tokens)

Embedding models (cloud or air-gapped)

Vector DB: Milvus, Weaviate, pgvector

Hybrid search

</div>

<div class="border-2 border-green-500 p-3 rounded text-sm">

### <span style="color: #6b21a8;">L3: Retrieve</span>

Query expansion & HyDE

Re-ranking

Metadata filtering (classification)

Context formatting

</div>

<div class="border-2 border-purple-500 p-3 rounded text-sm">

### <span style="color: #6b21a8;">L4: Generate</span>

IL4: GPT-4o, Gemini, Claude

IL5: Ask Sage (FedRAMP High)

IL6: Dedicated SIPRNet enclaves

Prompt engineering

</div>

<div class="border-2 border-red-500 p-3 rounded text-sm">

### <span style="color: #6b21a8;">L5: Govern</span>

Immutable audit trail

RAGAS metrics

AI CI/CD pipeline

Human-in-the-loop review

</div>

</div>

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded mt-3 text-center text-lg">
A production DoW RAG system is a <strong>multi-layer data platform</strong> — not an ad hoc chatbot
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
A production RAG system is not a chatbot — it's a multi-layer data and AI platform. Layer 1 handles document ingestion from SharePoint, file shares, PDFs, and technical data packages, with OCR and metadata enrichment. Layer 2 handles embedding and indexing in a vector database — Milvus is the most comprehensive option, satisfying all four key criteria including billion-scale support. Layer 3 orchestrates retrieval with query expansion, re-ranking, and classification-aware metadata filtering. Layer 4 handles LLM generation, with model selection varying by impact level — IL4 through IL6. Layer 5 provides observability, CI/CD, and governance, including mandatory audit trails and human-in-the-loop review. Treating RAG as an ad hoc feature is the primary cause of failed deployments.
-->

---

# Deployment Across Classification Levels

<div class="grid grid-cols-2 gap-6 mt-2">

<div class="text-sm">

### <span style="color: #6b21a8;">JWCC Cloud On-Ramps</span>

Four enterprise providers — AWS, Azure, Google, Oracle — supporting IL2 through IL6

| Level | Environment | Requirements |
|-------|-------------|-------------|
| **IL4** | NIPRNet | Multi-tenant, CAC auth, FIPS 140-2 |
| **IL5** | NIPRNet Sensitive | Dedicated enclave, US-citizen personnel, 421+ NIST controls |
| **IL6** | SIPRNet | SECRET clearances, TEMPEST shielding, air-gapped inference |
| **DDIL** | Tactical Edge | Containerized RAG on vessels, FOBs |

</div>

<div class="text-sm">

### <span style="color: #6b21a8;">GenAI.mil: The Mandate</span>

- **Dec 2025:** CDAO launches GenAI.mil — Pentagon-wide generative AI platform
- **Jan 2026:** DoN mandates transition for all commands; **deadline April 30, 2026**
- July 2025 CDAO frontier-AI contracts, up to $200M each: **Google, OpenAI, xAI** (*Anthropic excluded since March 2026*)
- Gemini for Government first; RAG with uploaded docs, web grounding, deep research
- **3 million** warfighters, civilians, and contractors served

<div class="bg-blue-100 dark:bg-blue-900 p-2 rounded mt-2 text-center">
RAG is now an <strong>institutional requirement</strong>, not an optional capability
</div>

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
The Joint Warfighting Cloud Capability provides four enterprise cloud on-ramps supporting deployment from IL2 through IL6. Containerized RAG stacks can even be deployed on tactical edge environments — naval vessels and forward operating bases.

And here's the mandate. In December 2025, the Pentagon's CDAO launched GenAI.mil — a Department-wide generative AI platform built on CDAO's July 2025 frontier-AI contracts of up to $200 million each. In January 2026 the Department of the Navy mandated transition for all commands by April 30, 2026. Google's Gemini for Government is the first model available on the platform, with OpenAI and xAI also on contract. Anthropic was also awarded a contract last July, but since the March 2026 supply chain risk designation — which we'll come back to in a moment — Anthropic is excluded from DoW use. GenAI.mil is serving roughly 3 million warfighters, civilians, and contractors. The point: RAG-enabled AI is now an institutional requirement, not an optional capability.
-->

---

# Security Controls for CUI and Classified RAG

<div class="grid grid-cols-2 gap-6 mt-2">

<div class="text-sm">

### <span style="color: #6b21a8;">Regulatory Framework</span>

- **DoDI 8510.01** — RMF for all DoW IT (including RAG)
- **NIST SP 800-53 Rev 5** — Control catalog (AC, AU, SC, SI, RA families)
- **NIST SP 800-171 Rev 3 / CMMC L2–3** — Contractors processing CUI
- **NIST AI RMF 1.0 + AI 600-1** — GenAI-specific guidance
- **DoD Zero Trust Strategy** — 152 ZT activities across 5 phases

</div>

<div class="text-sm">

### <span style="color: #6b21a8;">RAG-Specific Controls</span>

- **Classification-aware ingestion** — Parse and store markings as vector metadata; separate indexes by level
- **ABAC at query time** — Users only retrieve chunks at/below their clearance
- **Encryption** — AES-256 at rest (FIPS 140-2), TLS 1.3 in transit, mTLS service-to-service
- **Embedding confidentiality** — Dedicated inference nodes; vector similarity attacks are real
- **CAC/PIV authentication** — All RAG endpoints

</div>

</div>

<div class="text-lg italic text-left mt-3" style="color: #2E7D32; border-left: 4px solid #2E7D32; padding-left: 16px;">
Zero Trust: every identity continuously verified, no implicit trust for in-network components
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
Security is not optional. RAG systems handling CUI and classified data must comply with a comprehensive regulatory framework — RMF, NIST 800-53, CMMC, Zero Trust, and the new AI-specific guidance. RAG introduces specific security requirements: classification-aware ingestion with markings stored as vector metadata, attribute-based access control at query time so users only retrieve documents at their clearance level, FIPS-validated encryption at rest and in transit, and embedding vector confidentiality since similarity attacks can leak information. Every endpoint must be behind CAC authentication.
-->

---

# AI-Specific Threats to RAG Systems

<div class="grid grid-cols-3 gap-3 mt-2 text-sm">

<div class="border-2 border-red-500 p-2 rounded">

### <span style="color: #6b21a8;">Knowledge Base Poisoning</span>

PoisonedRAG attack: **5 malicious texts** in a **2.68M**-document corpus achieved a **97% attack success rate** — paraphrasing and perplexity detection proved **insufficient**

**Mitigations:**
- Provenance verification
- Integrity hashing
- Access-controlled ingest

</div>

<div class="border-2 border-yellow-500 p-2 rounded">

### <span style="color: #6b21a8;">Prompt Injection</span>

Adversarial content in retrieved documents instructs the LLM to override system prompts

**Mitigations:**
- Input sanitization at ingestion
- Prompt shields
- Output validation

</div>

<div class="border-2 border-blue-500 p-2 rounded">

### <span style="color: #6b21a8;">Model Inversion & Hallucination</span>

- Embedding queries can leak information
- Hallucinations persist even with good context

**Mitigations:**
- Audit logs on all queries
- Groundedness scoring
- Mandatory human review

</div>

</div>

<div class="bg-red-100 dark:bg-red-900 p-2 rounded mt-2 text-center text-base">
Defenses must be <strong>layered</strong>: provenance verification, integrity hashing, access-controlled ingest, adversarial audits
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
RAG introduces AI-specific threats that traditional security frameworks don't fully address. The most alarming: PoisonedRAG demonstrated that injecting just five malicious texts into a knowledge base of 2.68 million documents achieved a 97% attack success rate. That's not a typo — five documents out of nearly three million. Existing defenses like paraphrasing and perplexity detection proved insufficient. This means defenses must be layered: document provenance verification, integrity hashing, access-controlled ingest pipelines, and periodic adversarial audits.
-->

---

# The Anthropic Lesson: Why Vendor Independence Matters

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### <span style="color: #6b21a8;">What Happened (Feb–Mar 2026)</span>

- July 2025: Claude approved for classified networks
- Feb 27, 2026: President directed all agencies to cease using Anthropic
- Mar 5, 2026: DoW issued supply chain risk designation
- GSA removed Anthropic from USAi.gov
- Navy commands began removing Claude models

</div>

<div>

### <span style="color: #6b21a8;">The Architecture Lesson</span>

Organizations locked to a single LLM provider faced **immediate operational disruption**

Systems with **abstraction layers** transitioned to GPT-4o, Gemini, or open-source alternatives with **minimal changes**

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded mt-4 text-center">
Treat the LLM as a <strong>replaceable component</strong> behind a standardized interface
</div>

</div>

</div>

<div class="text-xl italic text-left mt-4" style="color: #2E7D32; border-left: 4px solid #2E7D32; padding-left: 16px;">
Frameworks like LangChain and Haystack enable vendor-agnostic design: swap a model identifier, not the pipeline
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">MS</div>

<!--
The Anthropic supply chain risk designation in early 2026 is a real-world proof point. In July 2025, Claude was the first frontier model approved for classified networks. By March 2026, the DoW formally designated Anthropic a supply chain risk and Navy commands were removing Claude models. Organizations that had built their RAG pipelines around a single LLM provider faced immediate disruption. But organizations that designed with abstraction layers — using frameworks like LangChain or Haystack — could swap to alternative models by changing a model identifier, not rewriting the pipeline. The lesson: treat the LLM as a replaceable component behind a standardized interface.
-->

---

# Case Study: RustyAI — Cloning Navy's Corrosion SME

<div class="grid grid-cols-2 gap-6 mt-4">

<div>

### <span style="color: #6b21a8;">The Mission</span>

A senior Navy corrosion engineer is approaching retirement — decades of specialized knowledge with no succession plan.

**Goal:** capture and replicate that expertise before it walks out the door.

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded text-center text-xl font-bold mt-4">
~30 GB &nbsp;|&nbsp; ~20,000 Files
</div>

Emails · technical handbooks · presentations · engineering reports

**Outcome:** AI assistant that answers in the SME's **own style**, with their depth of expertise.

</div>

<div class="text-sm">

### <span style="color: #6b21a8;">The Platform: RustyAI</span>

Four-tier deployment on AWS GovCloud (us-gov-west-1):

<div class="text-xs">

| | |
|------|-------|
| **Frontend** | Streamlit + Nginx (TLS 1.3) |
| **Application** | Haystack RAG framework |
| **Data** | Milvus + MinIO + Etcd |
| **Inference** | Amazon Bedrock (Titan + Claude) |

</div>

**Ingestion:** Docling (OCR + VLMs) on NVIDIA L4 — **2 hr → 20 min**; Markdown chunks → Titan embeddings → Milvus

<div class="bg-blue-100 dark:bg-blue-900 p-2 rounded mt-3 text-center">
XML-delimited prompts w citation require. for DoW traceability
</div>

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
Let me take you through a real deployment that makes all of this concrete. The War Department faces a quiet crisis: a generation of specialized engineers is approaching retirement, and their knowledge — built up over decades of hands-on work — isn't written down anywhere. It lives in email threads, annotated handbooks, and experience. Our mission was to clone that expertise into an AI system before it was lost. We ingested roughly 30 gigabytes of material across 20,000 files — emails, technical handbooks, presentations, engineering reports. The result is an assistant that doesn't just answer corrosion questions; it answers them the way that specific engineer would.

The platform we built to deliver this is called RustyAI — a production RAG system on AWS GovCloud for a Navy warfare center. Four tiers: Streamlit frontend behind Nginx with TLS 1.3, Haystack for RAG orchestration, Milvus as the vector database, and Amazon Bedrock for embeddings and generation. For document ingestion we use Docling, an open-source library using OCR and vision-language models to convert unstructured content to Markdown — GPU acceleration cut processing from two hours to twenty minutes. The prompts are XML-delimited with explicit citation requirements, so every response traces back to source documents.
-->

---

# RustyAI: Lessons Learned

<div class="mt-6">

<div class="border-l-4 border-blue-500 pl-3 py-2 mb-3">
<strong>1. GPU acceleration is not optional at scale</strong> — the order-of-magnitude speedup determines whether corpus updates complete within operationally acceptable windows
</div>

<div class="border-l-4 border-yellow-500 pl-3 py-2 mb-3">
<strong>2. Right-size your vector DB</strong> — Milvus Lite (Python library, t3.small) scales to millions of vectors; Standalone (t3.xlarge) scales to 100M+ for enterprise workloads
</div>

<div class="border-l-4 border-purple-500 pl-3 py-2 mb-3">
<strong>3. TLS everywhere, even internal</strong> — GovCloud environments block unencrypted traffic and non-standard ports
</div>

<div class="border-l-4 border-red-500 pl-3 py-2 mb-3">
<strong>4. Modular frameworks pay off</strong> — Haystack's component architecture allowed individual pipeline stages to be replaced without affecting the overall system
</div>

<div class="border-l-4 border-green-500 pl-3 py-2 mb-3">
<strong>5. Data conversion is key</strong> — scanned PDFs of handbooks, Excel spreadsheets, and videos are all similarly converted to a structured format before ingestion
</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
Five practical lessons. First, GPU acceleration isn't optional — the difference between two hours and twenty minutes determines whether you can keep your corpus current. Second, right-size your vector database — Milvus Lite on a small instance works for prototyping; scale to Standalone for enterprise workloads. Third, TLS everywhere, even for internal traffic — GovCloud blocks unencrypted ports. Fourth, modular frameworks like Haystack pay off: you can swap individual components without rewriting the pipeline — which is exactly what saved us when the Anthropic situation unfolded. And fifth, data conversion is the ceiling on your project — scanned PDFs, spreadsheets, and videos all need to land in a consistent structured format before ingestion. Real-world data gets messy fast.
-->

---

# Few-Shot Prompting: From Q&A Tool to Report Generator

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### <span style="color: #6b21a8;">The Conceptual Shift</span>

A baseline RAG system **answers questions**

A few-shot-prompted RAG system **produces structured deliverables**

The difference is entirely in the **prompt engineering layer** — retrieval and generation architecture unchanged

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded mt-4">
<strong>PPV improvement:</strong> 15–25 percentage points from zero-shot to few-shot
</div>

</div>

<div>

### <span style="color: #6b21a8;">Prompt Architecture</span>

1. **System prompt** — Role, output constraints, chain-of-thought
2. **Few-shot block** — 3–5 complete example report sections with annotated context
3. **Query block** — Analyst's request
4. **Context window** — Top-*k* retrieved chunks

<div class="bg-green-100 dark:bg-green-900 p-3 rounded mt-4">
Retrieved context provides <strong>factual grounding</strong>; few-shot examples specify <strong>format and reasoning style</strong>
</div>

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
Here's where RAG gets really powerful for T&E. A baseline RAG system answers questions. But add few-shot prompting — 3 to 5 example report sections in the prompt — and the same system produces structured, formatted deliverables. The retrieval architecture doesn't change at all; you just change the prompt. Studies show 15 to 25 percentage point improvements in positive predictive value from zero-shot to few-shot configurations. The synergy is clear: retrieved context provides the facts, few-shot examples provide the format.
-->

---

# T&E Report Types Amenable to RAG Automation

<div class="grid grid-cols-2 gap-4 mt-5">

<div class="border-2 border-blue-500 p-4 rounded text-sm">

### <span style="color: #6b21a8;">Templated Reports</span>

- **TEMP sections** — Background, test objectives, resource requirements
- **Test Execution Reports** — Structured findings with condition/deviation/severity
- **Test Incident Reports** — Deficiency with corrective action fields
- **MOP/MOE dashboards** — Metrics tables from raw test data

</div>

<div class="border-2 border-yellow-500 p-4 rounded text-sm">

### <span style="color: #6b21a8;">Multi-Document Synthesis</span>

- **Interim Fielding Assessments** — Operational effectiveness/suitability across multiple test events
- **Deficiency Reports / FRACAS** — Condition/cause/corrective action from historical databases
- **After-Action Reviews** — Synthesize across hundreds of T&E artifacts simultaneously

</div>

</div>

<div class="grid grid-cols-3 gap-4 mt-3">

<div class="bg-green-100 dark:bg-green-900 p-3 rounded text-center">
<strong>95%</strong> savings on ATO documentation (Ask Sage)
</div>

<div class="bg-blue-100 dark:bg-blue-900 p-3 rounded text-center">
<strong>60–80%</strong> reduction in initial draft time
</div>

<div class="bg-purple-100 dark:bg-purple-900 p-3 rounded text-center">
<strong>100K+ users</strong> on DoW GenAI platforms
</div>

</div>

<div class="text-xl italic text-center mt-3" style="color: #2E7D32;">
Analyst role shifts from <strong>drafter</strong> to <strong>reviewer</strong> — <em>Test for Less</em>
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
What kinds of T&E reports can RAG automate? Templated reports are the low-hanging fruit — TEMP sections, test execution reports, test incident reports, metrics dashboards. These have structured fields that are ideal for few-shot templating. Multi-document synthesis is where RAG really shines — interim fielding assessments that pull from multiple test events, deficiency reports that reference historical databases. No single analyst can synthesize across hundreds of artifacts simultaneously, but RAG can.

The numbers are real. Ask Sage reports 95% savings on ATO documentation generation. Enterprise RAG deployments see 60 to 80 percent reduction in initial draft time. And over 100,000 users are already on DoW GenAI platforms. The bottom line is that the analyst's role shifts from drafting to reviewing — focusing expertise on technical accuracy, edge cases, and judgment calls, which is the human value-add. That's the "Test for Less" efficiency gain this workshop is about.
-->

---

# Evaluation Framework

<div class="grid grid-cols-2 gap-8 mt-4">

<div>

### <span style="color: #6b21a8;">Automated Metrics</span>

**RAGAS Framework:**
- Context relevance
- Answer faithfulness
- Answer relevance

**ARES Framework:**
- Few-shot-seeded LLM judges
- Validated against human preference annotations

</div>

<div>

### <span style="color: #6b21a8;">T&E-Specific Metrics</span>

- **Citation coverage rate** — Are all claims traceable?
- **Format compliance rate** — Does output match the template?
- **Deficiency detection rate** — Compared to ground-truth test records

### <span style="color: #6b21a8;">Before Deployment</span>

- Red-team evaluation for prompt injection, poisoning, and exfiltration
- Regression testing on fixed evaluation sets at each pipeline update
- Human-in-the-loop review **mandatory** for all T&E deliverables

</div>

</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
How do you evaluate RAG-generated T&E reports? The RAGAS and ARES frameworks provide automated quality scoring before analyst review. For T&E specifically, you need citation coverage rate, format compliance rate, and deficiency detection rate compared to ground-truth records. Before any operational deployment, you must run red-team evaluation for prompt injection, poisoning, and exfiltration vulnerabilities, and implement regression testing at each pipeline update. And human-in-the-loop review is mandatory for all T&E deliverables — no exceptions.
-->

---
layout: end
class: text-center
---

# Closing: RAG Is Ready for T&E

<div class="grid grid-cols-3 gap-4 mt-4">

<div class="border-2 border-blue-500 p-3 rounded">

### <span style="color: #6b21a8;">The Capability</span>
107–177% accuracy gain
Multi-document synthesis at scale
Source attribution built in

</div>

<div class="border-2 border-yellow-500 p-3 rounded">

### <span style="color: #6b21a8;">The Mandate</span>
GenAI.mil required by April 30
CDAO AI RCC sprint methodology
DoD Zero Trust integration

</div>

<div class="border-2 border-green-500 p-3 rounded">

### <span style="color: #6b21a8;">The Path Forward</span>
Pilot on NIPRNet IL4 (90-day eval)
Security review for IL5/IL6 ATO
Few-shot template library for top 5 T&E deliverables

</div>

</div>

<div class="mt-5 text-2xl font-bold">
RAG is the highest-value, lowest-risk AI capability for T&E today
</div>

<div class="mt-3 text-lg">
It does not require retraining, does not export classified data to vendors, and deploys incrementally.
</div>

<div class="mt-4 text-xl">
<strong>Sam Bright · Michael Soltys</strong><br/>
GBL Systems Corporation
</div>

<div class="abs-br m-6 text-sm opacity-50 font-bold">SB</div>

<!--
To wrap up: RAG is the highest-value, lowest-risk AI capability available to DoW T&E programs today. It doesn't require retraining, doesn't demand classified training data be exported to a vendor, and can be deployed incrementally — start with unclassified documents on NIPRNet, then scale to CUI and SECRET. The mandate is here: GenAI.mil is required by April 30. The technology is mature. The architecture is proven. The path forward is a 90-day pilot on NIPRNet IL4, a security review for IL5/IL6, and a few-shot template library for your highest-frequency T&E deliverables. We're happy to take questions.
-->
