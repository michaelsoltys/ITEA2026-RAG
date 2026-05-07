# RAG Paper — Revisions for Keith Joiner (ITEA Journal)

**Source paper:** [`rag.tex`](rag.tex)
**Editor:** Dr Keith Joiner, Chief Editor, *ITEA Journal of Test and Evaluation*
**Acceptance email:** May 5, 2026 (see [`notes.md`](notes.md))
**Target edition:** June 2026
**Deadline:** end of May 2026 (Keith email, May 6, 2026)
**Scope guidance from Keith (May 6, 2026):** *"Don't go overboard with the literature linking; just enough to show your work aligns with sound research (which it does) and to give readers options for more detail."* → aim for ~4 of the 8 new references woven in lightly, not a full SLR-style treatment.

This file logs every change made to `rag.tex` and `rag.bib` in response to Keith's three asks:
1. Add literature coverage in the background using the references he provided.
2. In the discussion sections, add minor connections to where our themes mirror recent studies.
3. Generalize DoW-specific acronyms and policy documents into broad industry terms with the DoW ones in brackets.

## References Keith provided (all in `Sources-Keith/`)

| Bibkey (planned) | Author | Year | Venue | Role in revision |
|---|---|---|---|---|
| `gao2023` | Gao et al. | 2024 | arXiv:2312.10997 | already cited |
| `mdpi2025` | Karakurt & Akbulut | 2026 | Applied Sciences | already cited |
| `brown2025` | Brown, Roman, Devereux | 2025 | Big Data Cogn. Comput. 9(12):320 | new — SLR |
| `yu2025rag` | Yu et al. | 2025 | CCIS 2301 (Springer) | new — evaluation survey |
| `klesel2025` | Klesel & Wittmann | 2025 | BISE 67:551–561 | new — definition piece |
| `packowski2024` | Packowski, Halilovic, Schlotfeldt, Smith | 2024 | ICAAI / arXiv:2410.12812 | new — enterprise content design |
| `arslan2025` | Arslan, Munawar, Cruz | 2025 | CCIS (Springer) | new — Business-RAG / Llama+DeepSeek |
| `devalla2025` | Devalla | 2025 | Int. J. Computer Tech. 6(2) | new — microservice architectures |
| `wampler2026` | Wampler, Nielson, Seddighi | 2026 | arXiv:2601.05264 | new — RAG stack architecture & trust |
| `yu2025ekrag` | Yu et al. | 2025 | ACL 2025 KnowledgeNLP | new — enterprise RAG benchmark |

## Acronyms / DoW-specific terms to generalize

To be generalized on first mention with the form "international/industry term (DoW: acronym)":

- **ATO** → "system Authorization to Operate (DoW: ATO)"
- **STIG** → "security baselines (e.g., DoW DISA STIGs)"
- **IL4 / IL5 / IL6** → "government cloud impact levels (DoD IL4–IL6)"
- **NIPRNet / SIPRNet** → "unclassified / secret government networks (US: NIPRNet/SIPRNet)"
- **CUI** → "Controlled Unclassified Information (US government category)"
- **CMMC** → "supplier cyber-maturity certifications (DoW: CMMC)"
- **RMF** → "risk-management frameworks for IT accreditation (US: NIST SP 800-53 / DoD RMF)"
- **CDAO** → "defence AI offices (e.g., US CDAO)"
- **CAC / PIV** → "smart-card / hardware identity tokens (US Federal: CAC, PIV)"
- **DON** → "service-level CIO offices (e.g., US Department of the Navy)"
- **GenAI.mil** → keep, but explain as "the US DoW's enterprise GenAI platform"
- **JWCC** → "enterprise multi-vendor cloud contracts (DoW: JWCC)"
- **DDIL** → "denied / degraded / intermittent / limited connectivity environments"
- **FRACAS** → "Failure Reporting, Analysis, and Corrective Action System" (already expanded in current draft)

## Change log

*Format: `YYYY-MM-DD | section / line | change | rationale`*

### 2026-05-06

**Literature coverage (Keith ask #1 + #2):** added 4 new bib entries and 3 sentence-level citations.

- `rag.bib` | added `brown2025`, `yu2025rag`, `wampler2026`, `packowski2024` | new bib entries for Keith's reference list
- `rag.tex` §II.E (Quantitative Performance Benchmarks) | appended a "readers seeking a more comprehensive treatment" sentence citing `\textcite{brown2025}` (PRISMA SLR) and `\textcite{yu2025rag}` (unified evaluation framework) | gives readers options for more detail on RAG evaluation, per Keith's guidance
- `rag.tex` §III intro (Architecture and technology stack) | inserted one sentence citing `\cite{wampler2026}` after the "ad hoc chatbot feature" line, framing our layered architecture as mirroring the recent unified taxonomy | shows alignment with current architectural literature
- `rag.tex` §VI.E (Analyst Workload Reduction) | appended a sentence citing `\cite{packowski2024}` on knowledge-base-content as the dominant performance lever and the "human-in-the-lead" evaluation loop | connects our few-shot/report-generation theme to recent enterprise RAG deployment experience

**References Keith provided but not cited (deliberately, per "don't go overboard"):** `klesel2025` (BISE definition piece), `arslan2025` (Business-RAG with Llama+DeepSeek), `devalla2025` (microservice architecture), `yu2025ekrag` (enterprise QA benchmark). All are in `Sources-Keith/` for reference if a reviewer asks.

**Compile check:** `make all` succeeds, PDF rebuilt to 30 pages (was 29). All 4 new citations rendered correctly in the bibliography (verified by `pdftotext` + grep).

**Acronym generalization (Keith ask #3):** done with a light touch — one new "note on terminology" paragraph plus three inline parentheticals. Approach: leave abstract and section structure unchanged; signpost at the end of the introduction that DoW-specific terms are used because the case study is American, but equivalent constructs exist elsewhere; then add brief generic-equivalent parentheticals at the *first body* mention of NIPRNet/SIPRNet, IL2–IL6/JWCC, and RMF. Most other acronyms (ATO, STIG, CMMC, CAC, PIV, FRACAS, DDIL, FedRAMP, NLP, OCR, GSA, FAR, FASCSA, DIBCAC, CDAO) were already expanded in the prior review pass.

- `rag.tex` end of §I (Introduction) | added `\paragraph{A note on terminology and applicability.}` block (5 sentences) explaining DoW-specific labels and pointing to international equivalents | broadens appeal to other government departments and international readers per Keith's ask
- `rag.tex` §III.A line 140 | parenthetical "(the U.S.\ unclassified and secret government networks; analogous segregated network tiers exist in other defence establishments)" after first NIPRNet/SIPRNet mention | maps DoW-specific network labels to a generic concept
- `rag.tex` §III.F line 178 | parenthetical "(DoD impact levels covering unclassified through SECRET workloads; analogous tiered government cloud accreditation regimes exist in the UK, Australia, Canada, and the EU)" after IL2–IL6 mention | maps DoD impact-level scheme to allied analogues
- `rag.tex` §IV.A line 187 | inline gloss "(RMF; the U.S.\ federal IT-accreditation regime built on NIST SP 800-53, broadly comparable to ISO/IEC 27001-based frameworks used elsewhere)" at first RMF mention | maps to ISO equivalent for non-US readers

**Compile check (after generalization pass):** PDF rebuilt to 31 pages (was 30 after literature pass). No new warnings.
