# RAG Slides — Speaker Notes & Q&A Reference

Companion notes for `slides_rag_itea2026.md` (ITEA TIW 2026, Track 6, Wed Apr 29, 2:30–3:00 PM).

These notes provide deeper context for terms and concepts in the slides — useful for fielding audience questions or refreshing memory mid-talk.

---

## MIL-STD (Military Standard)

**What it is:** The U.S. Department of Defense's series of standardization documents that define uniform engineering, manufacturing, and procurement requirements across the military services.

**Key facts:**
- Issued by the DoD to ensure interoperability, reliability, and reproducibility across vendors and services
- Each is numbered: MIL-STD-810 (environmental — vibration, shock, thermal, humidity), MIL-STD-461 (electromagnetic interference), MIL-STD-1553 (avionics data bus), MIL-STD-882 (system safety)
- Mandatory for items procured under DoD contracts; vendors certify compliance during T&E
- Hierarchy: Federal Standards → MIL-STDs → MIL-HDBK (handbooks) → MIL-PRF (performance specs) → MIL-DTL (detail specs)
- Catalog: ASSIST at quicksearch.dla.mil

**Why it matters in this deck:**
- **Slide 5:** "MIL-STD designators" as an example of T&E terminology where exact keyword matching matters — MIL-STD-810 must hit that exact alphanumeric code, not just semantic neighbors. Argument for hybrid search.
- **Slide 14:** TEMPs and test execution reports routinely cite MIL-STDs as the basis for test methods — prime candidates for RAG-automated drafting.

---

## Cosine Similarity

**What it is:** A measure of how similar two vectors are by the **angle between them**, not their magnitude. Output ranges from -1 (opposite) → 0 (unrelated) → 1 (identical direction).

**Formula:**

$$\text{cosine similarity}(A, B) = \frac{A \cdot B}{\|A\| \, \|B\|}$$

The dot product divided by the product of the magnitudes — gives cos(θ), where θ is the angle between vectors.

**Why it matters for RAG (slide 3):**

1. **Magnitude-invariant.** A long document chunk and a short one with the same topic have very different vector lengths — but their *direction* in embedding space carries the meaning. Cosine ignores length, focuses on direction.
2. **Embeddings encode meaning as direction.** Modern models are trained so that semantically similar texts point the same way in 768–3,072-dim space.
3. **Cheap to compute at scale.** With normalized vectors (unit length), cosine reduces to a simple dot product — heavily optimized in vector DBs.

**Intuition:**
- *"the dog chased the ball"* and *"a puppy ran after a sphere"* — different words, similar direction → cosine ~0.85
- *"the dog chased the ball"* and *"the company filed bankruptcy"* — different directions → cosine ~0.1

**If asked "why not Euclidean distance?":**
Euclidean is sensitive to magnitude. Two semantically identical chunks of different lengths would look far apart in Euclidean but aligned in cosine. For normalized embeddings (which most modern models produce), cosine and Euclidean are mathematically equivalent ranked-orderings — but cosine is the convention.

---

## Top-*k* Most Similar Chunks

**What it is:** The **k highest-scoring matches** returned from the vector DB when searching for a query, where **k** is a tunable number (typically 3–20).

**Mechanically:**
1. Embed the query → one vector
2. Compare against every chunk in the DB using cosine similarity
3. Sort all chunks by score (highest first)
4. Return only the top k — discard the rest

**Why it matters:** LLMs have finite context windows. You can't (and shouldn't) stuff 2.68M documents into a prompt. Pick k = 5 or 10; only those chunks get injected for generation.

**The k tradeoff:**

| k too small (k=2) | k too large (k=50) |
|-------------------|--------------------|
| Miss relevant context | Inflates token costs |
| Risk of "I don't know" | Slower inference |
| Cheaper, faster | Dilutes signal with noise |
| | LLM gets confused by irrelevant chunks |

**Production sweet spot for T&E:** k = 5 to 10, then a re-ranker trims further to top 3 most relevant.

**Connection to slides:**
- **Slide 3:** "find top-k most similar chunks" — basic mechanic
- **Slide 4:** Naive RAG uses raw top-k. Advanced RAG retrieves larger top-k (say 20), then re-ranks with cross-encoder to true best 3–5. That's the **3.4× precision improvement**.
- **Slide 6 (L3 Retrieve):** Re-ranking lives in the Retrieve layer.

**If asked "how do you pick k?":** Empirically — measure faithfulness/groundedness on a held-out evaluation set (RAGAS framework). Start at k=5, test k=3 and k=10, pick what scores best.

---

## Zero-Shot

**What it is:** Asking an LLM to perform a task **without giving it any examples** — just the instruction and the input.

**The spectrum:**

| Term | What you give the model |
|------|------------------------|
| Zero-shot | Instruction only — no examples |
| One-shot | Instruction + 1 example |
| Few-shot | Instruction + 3–5 examples |
| Fine-tuned | Examples baked into the weights via training |

**Examples:**

*Zero-shot:*
> "Classify this test report as Pass, Fail, or Inconclusive: [report text]"

*Few-shot (same task):*
> "Classify these test reports as Pass, Fail, or Inconclusive.
> Example 1: 'All KPPs met thresholds.' → Pass
> Example 2: 'Three deficiencies blocking IOC.' → Fail
> Example 3: 'Insufficient sample size.' → Inconclusive
> Now classify: [new report text]"

**Why it matters in this deck:**
- **Slide 3:** "107–177% improvement over zero-shot LLM baselines" — RAG (with retrieved context) versus an LLM answering with no context and no examples.
- **Slide 13:** "15–25 percentage points PPV improvement from zero-shot to few-shot" — same RAG architecture, same retrieved chunks, but 3–5 example report sections in the prompt boosts output measurably.

**Key insight:** Zero-shot tests raw model capability. Few-shot tests how well you can steer it with prompt engineering alone — no retraining, no fine-tuning, no GPU time. That's why few-shot + RAG is so powerful for T&E: domain-specific structured outputs without fine-tuning cost.

**If asked "isn't zero-shot bad then?":** Not bad — just unguided. Great when the task is generic ("summarize this") and the model already knows what good output looks like. Fails when specialized — like producing a TEMP section in the right format with the right citations. That's where few-shot earns its keep.

---

## Vector Databases

**What it is:** A database optimized for storing and querying high-dimensional vectors (embeddings). Different from row/column DBs because the primary operation is "find the nearest k vectors to this query vector" — not "find rows where x = y."

**The big four (most common in DoW deployments):**

| DB | Best for | Notes |
|----|----------|-------|
| **Milvus** | Billion-scale, on-prem, GovCloud | What RustyAI uses (slide 11). Open-source, Docker Compose, scales to 100M+ vectors. Hybrid search, ABAC metadata filtering, GPU acceleration. |
| **Weaviate** | Mid-scale, schema-rich | Open-source, GraphQL API, built-in hybrid-search modules. |
| **pgvector** | Already running PostgreSQL | A Postgres extension. Wins when team already operates Postgres. Scales to ~10M vectors comfortably; struggles past that. |
| **Qdrant** | Rust-based, low-latency | Open-source, fast, simple deployment. Strong filtering. |

**Managed cloud options:**

| DB | Notes |
|----|-------|
| Pinecone | Fully managed SaaS. Easy to start, but vendor lock-in concern. FedRAMP Moderate. |
| Amazon OpenSearch (k-NN) | AWS GovCloud, FedRAMP High. Search-engine-first; vector bolted on. |
| Azure AI Search | Azure Government. Hybrid search built in. |
| Vertex AI Vector Search | Google Cloud, used by GenAI.mil's Gemini for Government. |

**The four criteria justifying Milvus (slide 6):**
1. Scale — billion-vector support without sharding pain
2. Hybrid search — dense + sparse (BM25) in one query
3. Metadata filtering — for ABAC / classification-aware retrieval (slide 8)
4. Deployment flexibility — on-prem, air-gapped enclaves (IL5/IL6), and cloud

Milvus hits all four. Pinecone hits 1–3 but fails 4 (cloud-only). pgvector hits 3–4 but fails 1.

**Vendor lock-in angle (ties to earlier talk):** Milvus is Apache 2.0, governed by LF AI Foundation. Run on AWS GovCloud today, Azure Government tomorrow, SIPRNet enclave next year — without rewriting. Compare to Pinecone-only stack: if they have a supply-chain incident à la Anthropic (slide 10), you're stuck.

**Quick recommendation:**
> "For DoW workloads we default to Milvus — scales to billions of vectors, runs anywhere from a developer laptop to an air-gapped IL6 enclave, avoids vendor lock-in. If your team already runs Postgres heavily and your corpus is under 10 million chunks, pgvector is a reasonable simpler choice."

---

## Re-ranking

**What it is:** A **second-pass refinement** in RAG: after the vector DB returns top-*k* candidates by cosine similarity, a more expensive but more accurate model re-scores those candidates and reorders them.

**The two-stage architecture:**

```
User query
    ▼
[1] Vector DB retrieval (FAST, APPROXIMATE)
    Cosine similarity over millions of chunks
    → returns top 20 candidates in ~50ms
    ▼
[2] Re-ranker (SLOW, PRECISE)
    Cross-encoder scores each candidate against the query
    → returns top 5 by quality in ~200ms
    ▼
LLM context window
```

**Why two stages:**
- Stage 1 uses **bi-encoders** — query and chunk embedded *independently*, then compared. Fast, but only as good as embeddings.
- Stage 2 uses **cross-encoders** — query and each candidate fed into a model *together* so it can pay attention to specific word interactions. More accurate, but couldn't be done over millions of chunks (fresh model pass per chunk).

Bi-encoder filters to 20, cross-encoder ranks those 20. Best of both worlds.

**Concrete example:**
Query: *"What are the acceptance criteria for KPP-3 in the AEGIS Block IX TEMP?"*

Vector retrieval returns 20 chunks scoring 0.78–0.92, including:
- Chunk about *AEGIS Block IX requirements* (general)
- Chunk listing *KPP-3 thresholds* (the actual answer)
- Chunk on *Block VIII KPP definitions* (close but wrong block)
- Chunk on *acceptance criteria methodology* (procedural, not answer)

Cosine ranks them roughly equally. The **re-ranker** notices the query specifically asked for *KPP-3 + Block IX + acceptance criteria* and pushes the actual answer to the top.

**Why slide 4 cites "3.4× precision improvement":** Comes from comparing top-1 retrieval precision with vs. without a re-ranking stage on standard benchmarks.

**Common re-rankers:**

| Model | Notes |
|-------|-------|
| Cohere Rerank | Commercial hosted API. Highly accurate, used in many production systems. |
| bge-reranker (BAAI) | Open-source, runs locally. Standard for air-gapped/IL6. |
| ColBERT | Late interaction architecture. Strong but more complex to deploy. |
| Cross-encoder MS MARCO | Classic baseline; many open-source variants. |

**Connection to slides:**
- **Slide 4:** "Re-ranking (3.4× precision improvement)" — what makes Advanced RAG advanced
- **Slide 6 (L3 Retrieve):** Re-ranking lives in Retrieve layer
- **Slide 11 (RustyAI):** Haystack supports re-rankers as drop-in pipeline components — swap Cohere for bge-reranker without rewriting

**If asked "do we always need it?":** Prototyping no — naive retrieval works. Production T&E feeding into compliance-bound report? Yes — precision gain pays for the latency. Mandatory human-in-the-loop review (slide 16) is the safety net regardless, but re-ranking dramatically reduces noise the analyst sifts through.

---

## Chunking

**What it is:** **Splitting documents into smaller pieces** before embedding them.

**Why chunk at all:**
1. **Embedding models have token limits.** Most max out at 512–8,192 tokens. A 200-page MIL-STD won't fit.
2. **Granularity matters for retrieval.** If you embed a whole 50-page test plan as one vector, you can only retrieve "this document is relevant" — not "*this paragraph* on page 23 answers your question."

**Mechanic:**
```
Original document (50 pages, 30,000 tokens)
        ▼
Chunking strategy splits it into ~60 pieces of 512 tokens each
        ▼
Each chunk → embedding model → vector → vector DB
        ▼
At query time, only the 5 most relevant chunks get retrieved
```

**Strategies:**

| Strategy | How it works | When to use |
|----------|--------------|-------------|
| Fixed-size | Split every N tokens, no awareness of structure | Simplest. Risk: cuts mid-sentence. |
| Sliding window | Fixed-size, but each chunk overlaps previous by 10–20% | Preserves context across boundaries. Slide 5: "outperforms fixed chunking." |
| Semantic-boundary | Split on paragraph or section breaks, respecting structure | Best for structured docs like TEMPs and MIL-STDs. Slide 5's "preferred for structured T&E." |
| Recursive | Try paragraphs first; if too long, sentences; then words | Pragmatic default in LangChain/LlamaIndex. |
| Document-aware | Use document's own structure (headings, tables) | Highest quality. Docling helps here (slide 11). |

**Size tradeoff (slide 5's table):**

| Chunk size | Faithfulness | Why |
|------------|--------------|-----|
| 256 tokens | 95.56% | Highly focused, but risk losing context |
| **512 tokens** | **97.59%** sweet spot | Self-contained, precise |
| 2048 tokens | 80.37% | Retrieval pulls in irrelevant text alongside answer |

U-shape: too small → lose context; too large → lose precision.

**Why overlap matters:** If you split *"...test was conducted at sea state 4. The acceptance threshold required..."* exactly between sentences, the chunk about acceptance thresholds loses "sea state 4" context. 10–20% overlap preserves continuity.

**RustyAI specifics (slide 11):** 5,000-character chunks (≈1,000–1,250 tokens) on Markdown output from Docling.

**If asked "what about 1,000-page TEMPs?":** Don't change chunk size — produce more chunks. 1,000-page TEMP at 512 tokens → ~8,000 chunks. Modern vector DBs handle billions; 8K is nothing.

**If asked "doesn't chunking lose document-level context?":** Partially yes. That's why metadata is stored with each chunk: source document, page number, section heading, classification level (slide 8). LLM can cite *"per AEGIS-TEMP §4.2.3, p. 87"* even though it only saw a 512-token chunk. Advanced architectures retrieve a chunk's *neighbors* automatically — called **parent document retrieval**.

---

## BM25

**What it is:** **Best Matching 25** — the classic keyword-based ranking algorithm that powers most traditional search engines (Elasticsearch, Lucene, OpenSearch, Solr). 25th iteration of a research project at City University London in the 1990s; still gold standard for sparse keyword retrieval 30 years later.

**What it does:** Scores how well a query matches a document based on:
1. **Term frequency** — does the document contain the query words, and how often?
2. **Inverse document frequency** — are those words rare across the corpus? (Rare = more informative)
3. **Document length normalization** — longer documents naturally have more terms; BM25 dampens that bias.

**Formula:**

$$\text{score} = \text{IDF}(q) \cdot \frac{f(q,d) \cdot (k_1 + 1)}{f(q,d) + k_1 \cdot (1 - b + b \cdot \frac{|d|}{\text{avgdl}})}$$

Sum across all query terms. Constants `k_1` (~1.5) and `b` (~0.75) are tunable. Well-understood, fast, deterministic.

**Why BM25 still matters in the era of embeddings:**

| Query | Vector wins | BM25 wins |
|-------|-------------|-----------|
| *"How are surface vessels tested at sea?"* | ✓ paraphrase of "naval ship sea trials" | ✗ different words |
| *"MIL-STD-810H Method 514.8"* | ✗ embeddings blur exact codes | ✓ exact token match |
| *"What does KPP-3 require?"* | ~ partial | ✓ KPP-3 unique |
| *"AEGIS Block IX TEMP"* | ~ partial | ✓ exact identifiers |

For T&E this is critical. Corpus is full of MIL-STD numbers, NSN codes, system designators (AN/SLQ-32, EA-18G), procedure IDs, acronyms. Pure semantic search misses these. BM25 nails them.

**Hybrid search (slide 5):**

$$S_h = \alpha \cdot S_s + S_d$$

Weighted combination:
- $S_s$ = sparse score (BM25)
- $S_d$ = dense score (cosine on embeddings)
- $\alpha = 0.3$ = optimal weighting found empirically

Compute both scores per candidate chunk, blend with 30% BM25 and 70% dense. Outperforms either alone:
- mAP **47.14** (hybrid) vs. **30.13** (BM25 alone) — 56% lift
- nDCG@10 **72.50**

**"Sparse" vs "dense":**
- **Sparse vectors** = mostly zeros (one dim per word in vocabulary, ~50K dims, only ~10–20 nonzero per document). BM25 operates on sparse representations.
- **Dense vectors** = every dim has a value (768–3,072 dims, all nonzero). Embeddings are dense.

**Historical context:** Created by Stephen Robertson and Karen Spärck Jones in 1994. Powers Elasticsearch, Lucene, Solr, most search bars on the internet. Modern vector DBs like Milvus and Weaviate include BM25 alongside dense retrieval *because they had to* — pure vector search loses too much in production.

**If asked "is BM25 going away?":** No. Foundational. Every serious RAG system in 2026 is hybrid. Only systems skipping BM25 are toy demos. Real-world queries are a mix of semantic intent and exact identifiers; one technique can't handle both.

**Q&A-ready punch line:**
> "BM25 is what your search bar has used for thirty years. Embeddings are what makes RAG smart. Hybrid search uses both — because in T&E, the analyst's question is 'tell me about KPP-3 acceptance criteria,' and you need semantic understanding for 'acceptance criteria' AND exact-match for 'KPP-3.'"

---

## Is BM25 Connected to Regular Expressions?

**No** — BM25 is *not* connected to regex. Different paradigms entirely.

| | BM25 | Regex |
|---|------|-------|
| What it does | Statistical ranking — scores documents by relevance | Pattern matching — finds substrings matching a literal pattern |
| Output | A relevance score (number) per document | Match / no-match (boolean), or extracted substrings |
| Fuzzy? | Yes — handles partial overlap, term frequency, rarity | No — strict pattern match |
| Order matters? | No — bag-of-words approach | Yes — characters must appear in sequence |
| Speed | Index-based, O(log n) at query time | Linear scan, O(n) per document |

**Concrete contrast:**
- *BM25 query:* "vendor lock-in" against "Avoiding vendor lock-in in AI procurement requires platform independence" → high score because both words present, "lock-in" is rare in corpus.
- *Regex query:* `vendor.{0,5}lock` would match "vendor lock" or "vendor in lock" but not "locked into vendors". Exact pattern, no relevance notion.

**What they share:** Both classical (pre-ML) text-processing tools. Both work on raw text without embeddings. Sometimes combine in pipelines:
- Regex pre-filters: extract MIL-STD numbers with `MIL-STD-\d+[A-Z]?` before indexing
- Then BM25 + dense embeddings handle relevance ranking

**The "exact-match" framing that may have caused the confusion:**
- **Regex** = exact *pattern* match (literal characters, with wildcards)
- **BM25** = exact *word* match (tokenized terms, with statistical weighting)
- **Embeddings** = semantic match (meaning-based, no word-overlap requirement)

BM25 does match exact tokens — but it's still scoring *relevance*, not pattern-matching. When slide 5 says "essential for T&E terminology: MIL-STD designators, system nomenclature, test procedure IDs" — that's BM25 leveraging the fact that "MIL-STD-810" appears as a discrete token in the document, not regex finding it as a character pattern.

---

## "Treating RAG as an Ad Hoc Feature Is the Primary Cause of Failed Deployments"

This is the takeaway warning at the end of slide 6 (Production Architecture). It means: **the #1 reason RAG projects fail in production isn't the AI — it's that teams treat RAG like a chatbot you bolt onto an existing app, when it's actually a multi-layer data platform that needs the same engineering rigor as any production database system.**

**What "ad hoc" means here:** Something assembled informally, on the fly, without architecture. The classic failure pattern:

> "Let's add an LLM chatbot — we'll just dump our docs into a folder, run them through OpenAI's embeddings API, store them in Pinecone, and have the LLM answer questions. Should take a sprint."

Six months later: hallucinations slipping into reports, classification levels leaking, no audit trail, corpus stale because nobody owns the ingestion pipeline, original developer left and system is undocumented, security team blocking production.

**The five things that get skipped in ad hoc builds (and that slide 6's five layers force you to address):**

1. **No ingestion governance (L1).** Documents added by ad-hoc upload, no metadata, no classification awareness, no deduplication. → ABAC fails, classification leaks.

2. **No re-ingestion strategy (L1).** "It worked when I built it." When MIL-STDs get revised or new test plans drop, nothing updates. Corpus rots. Analyst gets answers from 3-year-old docs.

3. **No retrieval quality engineering (L3).** Naive RAG only — no re-ranking, no query expansion, no metadata filtering. Results are 60–70% relevant and the LLM hallucinates the rest.

4. **No observability (L5).** When an analyst gets a wrong answer, nobody can reproduce it: no logs of which chunks were retrieved, which prompt was used, which model version. → Cannot debug, cannot improve, cannot pass an ATO.

5. **No human-in-the-loop (L5).** RAG output goes straight into a draft report with no review gate. → One bad answer in a TEMP and the whole program loses confidence.

**Real-world failure modes this captures:**
- **The Anthropic incident (slide 10).** Teams that built RAG ad hoc with hardcoded Claude API calls had to scramble. Teams with proper L4 abstraction (LLM as replaceable component) swapped a model identifier and moved on.
- **PoisonedRAG attack (slide 9).** Without proper L1 ingestion governance — provenance verification, integrity hashing — five malicious documents in 2.68M can compromise the system.
- **Failed DoD GenAI pilots.** GAO and DefenseScoop coverage of failed AI pilots consistently cite *governance*, *data quality*, and *integration with existing IT* as failure modes — not model accuracy.

**Why this lands the slide:** Slide 6 shows five distinct layers (Ingest, Index, Retrieve, Generate, Govern). Point of showing them as separate boxes: each needs ownership, design decisions, and ongoing maintenance. Skip a layer or merge it ad hoc into another, that's the failure point.

Compare to a typical web service: nobody would say "we'll just bolt on a database." You'd architect the schema, plan migrations, set up monitoring, build access controls. RAG needs the same treatment — teams who don't fail not because RAG is hard but because they didn't engineer it like the data platform it is.

**Q&A-ready answer:** If someone asks "why do RAG projects fail?":
> "They fail because teams treat RAG as 'add a chatbot to our app' rather than 'build a data platform with five distinct layers.' The model isn't the hard part — the ingestion governance, retrieval quality, and observability are. Skip any of those and you'll have a demo that works in your office and a production system that fails an ATO."

---

## Are the RAG-Specific Controls Quantum-Safe?

**Mostly no** — the slide 8 controls are largely **quantum-vulnerable** as written.

**Per-control assessment:**

| Control | Quantum-vulnerable? | Why |
|---------|---------------------|-----|
| TLS 1.3 (in transit) | 🔴 Yes — key exchange | Uses ECDHE/RSA for handshake. Shor's algorithm breaks both. Symmetric session keys after handshake are fine. |
| mTLS service-to-service | 🔴 Yes — cert auth | Cert signatures (RSA/ECDSA) broken by Shor's. |
| AES-256 at rest (FIPS 140-2) | 🟢 Effectively safe | Grover's algorithm halves security to ~128 bits — still beyond practical reach. AES-128 *would* be the worry. |
| CAC/PIV authentication | 🔴 Yes | CAC cards use RSA-2048 — broken by Shor's. Biometric components unaffected. |
| Classification-aware ingestion | 🟢 Logic-only | Policy/metadata, not crypto. Underlying AES-256 storage holds up. |
| ABAC at query time | 🟢 Logic-only | Policy enforcement; quantum doesn't break policy logic — only the auth crypto underneath. |
| Embedding confidentiality | 🟡 Indirect | Vector inversion attacks aren't quantum-enabled, but quantum-enhanced ML could improve them. |

**The "harvest now, decrypt later" threat:** Adversaries can record encrypted RAG traffic today and decrypt it once cryptographically relevant quantum computers exist (estimates: 2030–2040, uncertain). For classified/CUI data with multi-decade disclosure horizons, what's encrypted today still matters in 2040.

**DoW mandate:** **NSA's CNSA 2.0** (Commercial National Security Algorithm Suite 2.0) requires migration to post-quantum cryptography by **2035**. Hard deadline, not optional. Software signing required by 2025; broad systems by 2030; full migration by 2035.

**NIST PQC standards (relevant in 2026):**

| Algorithm | FIPS | Purpose |
|-----------|------|---------|
| ML-KEM (Kyber) | 203 (Aug 2024) | Key encapsulation — replaces ECDHE |
| ML-DSA (Dilithium) | 204 (Aug 2024) | Digital signatures — replaces ECDSA/RSA |
| SLH-DSA (SPHINCS+) | 205 (Aug 2024) | Hash-based signatures — backup |
| HQC | TBD (selected Mar 2025) | Code-based KEM backup |

**Quantum-resistant slide 8 replacements:**

| Old | Quantum-safe replacement |
|-----|--------------------------|
| TLS 1.3 (ECDHE+RSA) | TLS 1.3 with **hybrid X25519+ML-KEM** ciphersuites (already deployed by Cloudflare, Google, AWS in 2024–2026) |
| mTLS with RSA certs | mTLS with **ML-DSA** certs |
| CAC RSA-2048 | PIV migration per NIST SP 800-208 / CNSA 2.0 timeline |
| AES-256 | AES-256 (no change needed) |

**RAG-specific cost concern:** PQC keys/signatures are **10–100× larger** than RSA/ECDSA. For RAG systems doing millions of mTLS handshakes per day (every chunk retrieval, every embedding service call), bandwidth and CPU overhead is non-trivial. Practical deployments use **hybrid** schemes (classical + PQC) that pay both costs but provide both backstops.

**Q&A-ready answer:**
> "Symmetric encryption — AES-256 at rest — is fine under quantum. The vulnerabilities are in public-key components: TLS 1.3 handshakes, mTLS certificates, and CAC/PIV authentication. CNSA 2.0 mandates migration to NIST's post-quantum standards — ML-KEM and ML-DSA — by 2035, with hybrid deployments rolling out today. So a 2026 production RAG system should be using hybrid PQC TLS already if it handles classified data with a long disclosure horizon. The architecture in slide 8 stays the same; the crypto primitives swap out underneath."

---

## USAi.gov

**What it is:** The GSA's centralized generative AI sandbox for federal agencies — a no-cost, secure platform giving government users access to multiple commercial AI models through a single onboarding process.

**Quick facts:**
- **Launched:** August 14, 2025 by GSA
- **URL:** usai.gov
- **Cost:** Free for federal agencies
- **Initial term:** 6-month trial; agencies onboard via MOUs
- **Strategic basis:** White House "America's AI Action Plan"

**Three integrated components:**
1. **Unified chatbot interface** — federal employees access leading LLMs through one UI
2. **Programmatic API access** — for operational/automated use (data processing, RPA integration, production pipelines)
3. **Evaluation tooling** — co-developed with CAISI (Center for AI Standards and Innovation) to benchmark federal AI use

**Models available at launch:** Six commercial frontier models from Amazon, Microsoft, Google, Meta, OpenAI, and ~~Anthropic~~ (removed Feb–Mar 2026 — slide 10's reference).

**Slide 10 context:** *"GSA removed Anthropic from USAi.gov"* — after President Trump's Feb 27, 2026 directive to cease federal use of Anthropic and the Mar 5 supply chain risk designation, GSA pulled Claude from USAi alongside the Pentagon DoW removal. Civilian counterpart to the DoD action. Claude went from available to *all* federal agencies (military and civilian) to none.

**USAi.gov vs GenAI.mil — parallel platforms with different scopes:**

| | USAi.gov | GenAI.mil |
|---|----------|-----------|
| Operator | GSA | Pentagon CDAO |
| Audience | All federal agencies | DoW workforce |
| Classification | Unclassified / FOUO | IL2 through IL6 |
| Launch | Aug 14, 2025 | Dec 9, 2025 |
| First model live | Multi-vendor sandbox | Google Gemini for Government |

A federal civilian employee uses USAi.gov; a DoW warfighter uses GenAI.mil. Sit alongside each other in the broader America's AI Action Plan.

**Why it matters for the talk:** USAi.gov is mentioned briefly on slide 10, but evidence that *vendor lock-in concerns are not theoretical*. A single supply-chain decision pulled Claude out of two major federal AI procurement vehicles simultaneously (USAi for civilian, GenAI.mil for DoW) within days. Any agency that hard-coded Claude through either platform faced disruption; agencies using abstraction layers swapped to OpenAI / Gemini and continued.

---

## Doesn't RAG Hallucinate Too?

**Slide 2 risk:** Listing "hallucination" as a failure mode of standalone LLMs implies RAG fixes it. RAG **reduces** hallucinations significantly but does **not eliminate** them. The deck addresses this on slide 9, but if an audience member only catches slide 2, they may walk away with the wrong impression. Worth preempting verbally.

**Why RAG still hallucinates:**

1. **Misinterpretation of retrieved context** — chunk says X; model summarizes it as ≈X
2. **Faulty cross-chunk synthesis** — combines two facts into a third that's not supported
3. **Parametric fallback** — when retrieval is poor or incomplete, the model leans on its training data; that's where hallucinations originate
4. **Citation hallucination** — even when the answer is correct, the cited source may be misattributed or fabricated
5. **Plausible filler** — when the retrieved chunks don't fully answer the question, the model extrapolates rather than saying "I don't know"

**What the literature shows:**
- RAG reduces hallucination rates roughly **50–70%** vs zero-shot LLMs
- Well-designed production RAG still shows **5–15%** hallucination rate
- Higher under adversarial conditions (PoisonedRAG, prompt injection — slide 9)

**How the deck handles it (internally consistent):**
- **Slide 2:** Frames hallucination as a failure mode of *standalone* LLMs (technically correct)
- **Slide 9 ("AI-Specific Threats"):** Explicitly says *"Hallucinations persist even with good context"* with mitigations: groundedness scoring, mandatory human review
- **Slide 6 (Production Architecture, L5 Govern):** Human-in-the-loop review is mandatory — *because* hallucinations persist
- **Slide 16 (Evaluation Framework):** RAGAS faithfulness + ARES + human review as the safety net

**Q&A-ready answers:**

If asked *"doesn't RAG also hallucinate?"*:
> "Yes — RAG reduces hallucinations roughly 50–70% by grounding outputs in retrieved sources, but doesn't eliminate them. That's why slide 6's architecture has Layer 5 — Govern — including mandatory human-in-the-loop review. We're not claiming RAG produces compliant T&E reports unattended; we're claiming it produces high-quality first drafts that an analyst reviews and signs off on. The analyst is the safety net for residual hallucinations."

If asked *"how do you measure hallucination rate?"*:
> "RAGAS provides three automated metrics — context relevance, answer faithfulness, answer relevance. Faithfulness specifically scores whether the answer is supported by retrieved context. ARES adds few-shot LLM judges validated against human preferences. Both run automatically; both feed into your evaluation set on every pipeline change. But — and this is the deck's core safety message — automated metrics don't replace the human review gate."

**Verbal preempt for slide 2 (added to presenter notes):**
> "Quick caveat to preempt a common question: RAG dramatically reduces hallucinations by grounding outputs in retrieved sources, but it doesn't eliminate them entirely. We'll come back to this on slide 9 when we cover AI-specific threats — and the architecture on slide 6 includes mandatory human-in-the-loop review precisely because hallucinations persist."

---

## What Does "Embed the User's Query" Mean? (Slide 3)

**The mechanic:** Running the user's text question through an embedding model that converts it into a high-dimensional numerical vector — the same kind of vector created for every chunk during ingestion. That query vector is then compared against all stored chunk vectors via cosine similarity to find the most semantically similar chunks.

```
User types: "What are the acceptance criteria for KPP-3?"
        ▼
[Embedding model — same one used at ingestion]
        ▼
[0.0234, -0.187, 0.652, 0.041, ..., -0.298]
   ← 768 to 3,072 floats, depending on model →
        ▼
Query vector compared to chunk vectors via cosine similarity
```

**Why a learned model, not a simple lookup:** The embedding model is a neural network specifically trained to map text to a vector space where semantically similar text ends up near each other. Not a hash function, not word-count. Captures paraphrase: *"acceptance criteria for KPP-3"* ≈ *"what does KPP-3 require for sign-off"*. Without it, you'd be stuck with literal keyword matching.

**Common embedding models in DoW deployments:**

| Model | Provider | Dims | Notes |
|-------|----------|------|-------|
| Titan Text Embeddings V2 | Amazon Bedrock | 1,024 | RustyAI uses this (slide 11). Works on AWS GovCloud. |
| text-embedding-3-large | OpenAI | 3,072 | Highest accuracy commercially. Via GenAI.mil. |
| bge-large-en-v1.5 | BAAI (open-source) | 1,024 | Standard for air-gapped IL5/IL6 deployments. |
| voyage-3 | Voyage AI | 1,024 | Specialized for retrieval; strong on technical text. |
| gte-large | Alibaba (open-source) | 1,024 | Common alternative for on-prem. |

**The critical constraint — same model both sides:** The embedding model used at query time must be the same one used during ingestion. Different models produce vectors in different mathematical spaces — cosine similarity becomes meaningless when comparing across spaces. Practical consequences:

- **Switching embedding models = re-embedding the entire corpus.** For RustyAI's 30 GB / 20,000 files, this is a significant operation (slide 11's ingestion pipeline exists for exactly this).
- **Versioning matters.** Treating `titan-v2.5` as "the same as titan-v2" silently corrupts retrieval quality.
- **Vendor lock-in lurks here.** If locked into Titan or OpenAI for embeddings, you can't easily swap LLMs. Open-source alternatives like bge-large keep this layer portable — relevant to the vendor lock-in talk.

**What it costs:**
- Latency: typically 50–200 ms per query
- OpenAI `text-embedding-3-large`: ~$0.13 per million tokens; a typical 10–50 token query is fractions of a cent
- At ingestion scale (millions of chunks), embedding compute can dominate cost

**Symmetric vs asymmetric retrieval:** Most production RAG uses *symmetric* embedding — one model encodes both queries and chunks. Some advanced setups use *asymmetric* models (a query encoder + passage encoder trained as a pair, like ColBERT or DPR) for higher precision. Not worth the complexity unless optimizing for the last 5% of accuracy.

**Q&A-ready punch line:**
> "Embedding the query means converting the user's question into the same kind of numerical vector we stored for every chunk in the database. The embedding model — like a multilingual translator for meaning — turns text into a 1,024-dimensional point in vector space. Cosine similarity finds the chunks closest to that point. The model has to be the same one used during ingestion, otherwise the vectors don't live in the same space."

---

## What is "Single-Pass" Retrieve-Then-Generate? (Slide 4)

**The definition:** Retrieval and generation happen **exactly once, in sequence, with no iteration**. The system doesn't refine, ask follow-up questions, or re-retrieve. Just one straight shot from query to answer.

```
User query
    ▼
Embed query
    ▼
Vector DB returns top-k chunks   ← retrieval happens once
    ▼
LLM generates answer using those chunks   ← generation happens once
    ▼
Output to user
```

**Why single-pass fails in production:**

1. **Bad query reformulation.** *"What's the latest on KPP-3?"* — "latest" is meaningless to the embedding model. Semantically similar chunks could span any year. Single-pass picks one and generates.

2. **Multi-hop questions break.** *"Compare AEGIS Block IX acceptance criteria to Block X."* Needs two retrievals plus synthesis. Single-pass tries with whatever came back from one cosine search — incomplete.

3. **Ambiguous queries.** *"What does the test report say about the deficiency?"* — which deficiency? Which test report? Single-pass picks chunks on raw vector similarity and hopes. No clarification, no follow-up.

4. **Empty/weak results.** If retrieval returns chunks scoring 0.3 (weak match), single-pass still generates using those weak chunks — producing a confident-sounding hallucination instead of "I don't have enough information."

**The progression on slide 4:**

| Approach | What changes |
|----------|--------------|
| Single-pass (Naive) | One retrieval, one generation. Done. |
| Multi-pass with query rewriting | LLM rewrites query first ("latest KPP-3" → "KPP-3 acceptance criteria 2024 2025"), then retrieves. Smarter. |
| HyDE (Hypothetical Document Embeddings) | LLM generates a hypothetical answer first, embeds *that*, retrieves chunks similar to it. Counterintuitive but works. |
| Multi-query retrieval | LLM generates several query variations, retrieves chunks for each, merges. |
| Re-ranking | One retrieval, then a second-stage scoring pass over top 20. Still one retrieval but two-stage scoring. |
| Agentic RAG | LLM decides whether to retrieve, formulates sub-queries, iterates. Many retrieval passes, dynamically. |

**Where the line is:** "Single-pass" specifically means **one retrieval against the index**. Re-ranking is sometimes called a "second pass" but it's a second *scoring* pass, not a second *retrieval* — the chunks were pulled in the first cosine search.

**Why it's the strawman of slide 4:** Naive RAG is what people build after a 30-minute tutorial. It works for demos but fails in production. The slide's role: *"if you take only this away, build at least Advanced RAG, not Naive."* Hence the call-out: *"Production T&E deployments require Advanced RAG at minimum."*

**Q&A-ready punch line:**
> "Single-pass means one shot — retrieve once, generate once. The simplest possible RAG architecture. Works for hello-world demos but breaks down on multi-hop questions, ambiguous queries, or anything where the first retrieval doesn't perfectly capture intent. That's why production T&E deployments need at least Advanced RAG with query rewriting and re-ranking."

---

## Post-Retrieval Compression (Slide 4)

**The definition:** The step *between* retrieval and generation: after the vector DB returns top-*k* chunks, **filter, distill, or trim** them before passing to the LLM. Goal: reduce noise so the LLM has only the most relevant content in its context window.

**Why it matters:**

1. **Lost in the middle** — LLMs systematically attend less to content in the middle of long contexts. A relevant sentence buried in chunk 6 may be ignored. (Liu et al. 2023.)
2. **Cost** — every token costs money. Sending 5,120 tokens when only ~500 are relevant is wasteful at scale.
3. **Latency** — generation latency scales roughly linearly with input length. Smaller context → faster responses.
4. **Hallucination amplifier** — irrelevant content can confuse the model into incorporating off-topic facts.
5. **Distraction** — a chunk with 5 sentences but only 1 relevant has 4 sentences of noise.

**Compression techniques:**

| Technique | What it does |
|-----------|--------------|
| Sentence-level filtering | Score sentence-by-sentence relevance; keep only relevant sentences |
| LLM-based extractive compression | Smaller LLM reads each chunk and extracts the relevant span |
| Token pruning (e.g., LLMLingua) | Score every token's importance; drop low-importance tokens — 5–20× compression |
| Contextual compression (e.g., Cohere) | Compression model takes (query + chunk), returns compressed chunk |
| Dropping low-score chunks | After re-ranking, drop chunks below threshold rather than always sending full top-*k* |

**Concrete example:**

User query: *"What are the acceptance thresholds for KPP-3 in AEGIS Block IX?"*

Retrieved chunk 4 (raw, ~200 words):
> "AEGIS Block IX entered formal test in March 2024. The test program included three phases... The systems engineering team led by Dr. Patel established weekly review cycles... **KPP-3 acceptance threshold for engagement range is 200 nautical miles, as defined in TEMP §4.2.3.** Funding for Block IX totaled $2.4B across FY24-26..."

After compression:
> "KPP-3 acceptance threshold for engagement range is 200 nautical miles, as defined in TEMP §4.2.3."

200-word chunk → 20-word answer-bearing sentence. Across 10 chunks, context shrinks ~10×.

**Tools in production:**

| Tool | Origin | Notes |
|------|--------|-------|
| LLMLingua / LongLLMLingua | Microsoft Research | Token-level pruning. 5–20× compression with minimal quality loss. |
| Cohere Compress | Cohere | API-based contextual compression. Commercial. |
| LangChain `ContextualCompressionRetriever` | LangChain | Wraps base retriever with LLM compressor. Common pragmatic choice. |
| LlamaIndex `SentenceTransformerRerank` + filter | LlamaIndex | Re-rank then filter low-score sentences. |
| Cross-encoder relevance scoring | Open-source | Score sentences vs query; threshold-filter. |

**Distinguishing compression from neighbors on slide 4:**
- **Re-ranking** = reorder top-20 candidates by quality (which 5 are best?)
- **Compression** = shrink content of those top chunks (what's the key passage in each?)
- **Relevance filtering** = drop chunks that don't pass a score threshold (skip irrelevant entirely)

A full pipeline uses all three: retrieve top 20 → re-rank to top 10 → drop below threshold → compress survivors → send to LLM.

**Cost/quality tradeoff:** Compression adds latency and complexity. Aggressive compression risks dropping the answer-bearing content. Production T&E systems typically use **moderate** compression — sentence-level filtering on top 5 chunks rather than aggressive token pruning. Losing critical TEMP context costs much more than a few extra tokens.

**Q&A-ready punch line:**
> "Post-retrieval compression is the step between retrieval and generation where you trim retrieved chunks down to just the relevant sentences before passing them to the LLM. Cuts cost and latency, and helps with the 'lost in the middle' problem where LLMs ignore content buried in long contexts. The tradeoff: aggressive compression risks dropping the answer-bearing content. For T&E we lean conservative — sentence-level filtering rather than token pruning."

---

## Cost Levers in L4 (Generate) — Slide 6

**Important framing note:** Slide 6's L4 box lists *what models are available* at each classification level (IL4: GPT-4o/Gemini/Claude; IL5: Ask Sage; IL6: dedicated SIPRNet enclaves). It is *not* a cost-tiering recommendation. Cost decisions are a separate axis from classification.

**Two distinct cost levers exist — keep them separate when answering questions:**

### Lever 1 — Classification level (IL4 → IL5 → IL6)

Cost increases as IL goes up. Going to higher classification doesn't make models cheaper; it makes everything more expensive.

| IL | Why it costs what it costs |
|----|----------------------------|
| IL4 | Cheapest. Commercial models on shared cloud, pay-per-token. ~$0.005 per 1K tokens for GPT-4o. |
| IL5 | More expensive. Ask Sage (FedRAMP High) charges premium for compliance overhead. |
| IL6 | Most expensive. Dedicated SIPRNet enclave — pay for infrastructure even when idle. Air-gapped, no sharing. |

This is a *constraint* you accept based on data sensitivity, not a lever you pull for cost reduction.

### Lever 2 — Model tier within a classification level

This is the cost lever you actually control. Within any IL level, choose how capable a model to use per query.

| Tier | Examples | Relative cost | Use for |
|------|----------|--------------|---------|
| Heavy | GPT-4o, Claude Sonnet 4, Gemini 1.5 Pro | High | Synthesis, multi-doc reasoning, complex T&E reports |
| Mid | Claude Haiku, Gemini Flash | Medium | Standard Q&A, summarization, simple extraction |
| Light | GPT-4o-mini, smaller embeddings models | Low | Classification, routing, metadata extraction |

10–20× cost difference between heavy and light. The lever: **don't use a heavy model when a light one works**. RAG pipelines have multiple LLM calls per query (re-ranking, query rewriting, generation, output validation). Using light models for supporting calls and heavy only for final generation cuts cost 70–80%.

### Why this matters for the "Test for Less" theme

L4 is where the theme is most actionable mid-talk. A T&E program that's already classification-constrained to IL5 or IL6 can't pull Lever 1 — but they can still pull Lever 2 within those constraints. That's a directly applicable Test for Less argument for the audience.

### Common confusion to avoid

It's tempting to say "pick GPT-4o for IL4 and a heavier model for IL6" — *this is wrong*. GPT-4o is itself a frontier model. Higher IL doesn't mean heavier model is required; it means the available *catalog* of models shrinks (fewer commercial options at IL6). Within whatever catalog is available at your IL, tier by task complexity.

### Verbal addition for slide 6 (added to presenter notes)

> "Layer 4 is generation, where model selection varies by impact level. Within any tier there's a second cost decision: tier the model to the task. Use a small fast model for classification and routing, save the heavy reasoning model for final synthesis. For high-volume T&E pipelines, that's where Test for Less actually compounds."

### Q&A-ready answer

If asked *"is RAG expensive to run?"*:
> "There are two cost dimensions. The classification level you're operating at — IL4 to IL6 — sets a floor: IL6 with dedicated enclaves is the most expensive simply because you're paying for the infrastructure. But within any level, you have a meaningful cost lever in model tiering: use a small fast model for classification, routing, and re-ranking calls, and save the frontier model for final synthesis. RAG pipelines typically have 5–10 LLM calls per query; if you tier them properly, you can cut cost 70–80% without quality loss. That's directly aligned with this workshop's Test for Less theme."
