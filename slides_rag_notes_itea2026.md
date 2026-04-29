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
