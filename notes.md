# ITEA 2026 — RAG Paper & Presentation Notes

This folder contains the **RAG for T&E** paper (`rag.tex`/`rag.pdf`) and the Slidev source for the RAG presentation (`slides_rag_itea2026.md`) at the ITEA Test Instrumentation Workshop (TIW), Las Vegas, April 28–30, 2026.

## Related Folders

- **Vendor Lock-in presentation:** `/Users/michael.soltys/Library/CloudStorage/Dropbox-OmniaInBonum/Michael Soltys/Docs/Writing/Papers/daj-2026/ITEA-2026/` (separate git repo: `ITEA2026-Vendor`)
- **Conference logistics / travel / abstracts / receipts:** `/Users/michael.soltys/Library/CloudStorage/Dropbox-OmniaInBonum/Michael Soltys/Docs/Workshop/GBLWorkspace/Conferences/ITEALasVegas2026/`
- **Parent project / cross-paper tracking:** `/Users/michael.soltys/Library/CloudStorage/Dropbox-OmniaInBonum/Michael Soltys/Docs/Writing/Papers/daj-2026/` — `CLAUDE.md` and `notes.md` track both ITEA presentations alongside the vendor lock-in and legacy-code ARJ submissions

## Presentation Info

- **Title:** Taming the Beast: Secure Retrieval-Augmented Generation for T&E Report Automation in Classified Environments
- **Authors:** Sam Bright, Michael Soltys (GBL Systems)
- **Track:** Track 6 (Topics Supporting T&E), Siena room
- **Time:** Wednesday April 29, 2026, **1:30–2:00 PM** (30 min incl. Q&A)
- **Presenters:** Michael Soltys + Sam Bright (50-50)
- **Paper:** `rag.tex` / `rag.pdf`
- **Slides source:** `slides_rag_itea2026.md` (Slidev format)
- **Slides submitted:** PDF, April 14, 2026 (Distro A cleared)
- **Git repo:** https://github.com/michaelsoltys/ITEA2026-RAG.git
- **Live Slidev URL:** https://michaelsoltys.github.io/ITEA2026-RAG/

## Journal Submission

- **Paper submitted to ITEA Journal editor Dr. Keith Joiner (UNSW), March 23, 2026**
- Contact: k.joiner@unsw.edu.au
- Facilitator: Kathi Swagerty (kathiswagerty@gmail.com / kathi@itea.org)
- Target: **June 2026 edition**; review in April

## Correspondence Log

### April 24, 2026 — Jim Alich logistics email

Jim Alich (Track 6 lead, 812 AITS / Edwards AFB) confirmed receipt of submitted presentations and laid out logistics:
- Computer will be provided (his personal laptop)
- Logitech remote/laser available for slide flip + pointing
- **Some presenters submitted PDFs** — Jim asked if PowerPoint is available
- Asked for abstracts to be resubmitted so he can introduce each talk
- Presenters should self-introduce briefly at the start
- **30 minutes total including Q&A**
- Jim's cell: **(661) 874-6957** (note: different from earlier (661) 810-7179)

**Reply sent (same day):**
- Presentation format options: PDF (viewer or browser) or **live Slidev in a browser**:
  - RAG: https://michaelsoltys.github.io/ITEA2026-RAG/
  - Vendor Lock-in: https://michaelsoltys.github.io/ITEA2026-Vendor/
- Sent both abstracts (RAG + Vendor Lock-in) with titles, times, and co-presenter info
- Confirmed self-intros + 30-min timing
- **Full email text archived in:** `/Users/michael.soltys/Library/CloudStorage/Dropbox-OmniaInBonum/Michael Soltys/Docs/Workshop/GBLWorkspace/Conferences/ITEALasVegas2026/notes.md` (April 24, 2026 section)

### April 29, 2026 — ITEA MDO Forum Call for Papers Extended

ITEA (info@itea.org) sent TIW attendees a call-for-papers reminder for the **All/Multi-Domain Operations Forum** (July 14–16, 2026, Huntsville, AL).

- **Theme:** "Testing for the Arsenal of Freedom"
- **Focus:** How test/experimentation informs acquisition, mission engineering, and integration in an All/Multi-Domain operations environment; accelerated PAE capability delivery
- **Topics:** Integrated Fires, Integrated Air & Missile Defense, Space-augmented navigation/targeting/communication, Autonomous systems, Command and Control, Tactical systems with AI/ML, Threat-representative T&E (Cyber, EW, non-kinetic), Transformation in Contact, Operational realism in experimentation/DT/OT
- **Deadline:** ~~May 1~~ → **Extended to May 15, 2026**
- **Forum URL:** https://itea.org/event/all-multi-domain-operations-forum/

**MDO abstract drafted at:** `MDO/abstract-mdo.md` (419/500 words, Distro A, vendor lock-in reframed for kill-web / CJADC2 / T&E reproducibility — substantially differentiated from the ITEA Journal long version and Defense Acquisition Magazine short version).

**Action:** Circulate MDO abstract to co-authors after TIW (April 30) for sign-off; submit by May 15.

### May 5, 2026 — Keith Joiner: Acceptance Conditions & Revision Requests

**From:** Dr Keith Joiner (Chief Editor, ITEA Journal) — k.joiner@unsw.edu.au
**To:** Michael Soltys; cc Gilbert Torres, Viruben Watson, journal@itea.org, Sam Bright

Both papers (RAG and Vendor Lock-In) accepted for publication subject to minor edits. Keith's three asks:

1. **MSWord versions** required so Keith can do minor edits.
2. **Add literature coverage in the background sections** using the reference lists he provided. He notes both papers "lack a little relation to the literature in this field and focus very heavily on DoW processes."
3. **In the discussion sections** (which he characterizes as "already rich"), add minor connections to where the paper's themes are mirrored in any of the more recent studies he listed.
4. **Generalize acronyms and policy documents** into broad industry terms and standards with the DoW ones in brackets (or vice versa) — to broaden appeal to other Government Departments and the international readership.

**Reference list for RAG paper (all recent, 2023–2026):**

- Y. Gao et al., "Retrieval-Augmented Generation for Large Language Models: A Survey," arXiv:2312.10997, 2024. *(already cited as `gao2023`)*
- A. Brown, M. Roman, B. Devereux, "A Systematic Literature Review of Retrieval-Augmented Generation: Techniques, Metrics, and Challenges," *Big Data and Cognitive Computing* 9(12):320, 2025. https://www.mdpi.com/2504-2289/9/12/320
- H. Yu et al., "Evaluation of Retrieval-Augmented Generation: A Survey," in CCIS 2301, Springer, 2025, pp. 102–120. https://link.springer.com/chapter/10.1007/978-981-96-1024-2_8
- M. Klesel and H. F. Wittmann, "Retrieval-Augmented Generation (RAG)," *Business & Information Systems Engineering* 67:551–561, 2025. https://link.springer.com/article/10.1007/s12599-025-00945-3
- E. Karakurt and A. Akbulut, "RAG and LLMs for Enterprise Knowledge Management and Document Automation: A Systematic Literature Review," *Applied Sciences* 16(1):368, 2026. *(already cited as `mdpi2025`)*
- S. Packowski, I. Halilovic, J. Schlotfeldt, T. Smith, "Optimizing and Evaluating Enterprise RAG: A Content Design Perspective," ICAAI, 2024. https://arxiv.org/pdf/2410.12812
- M. Arslan, S. Munawar, C. Cruz, "Business-RAG: Advancing Enterprise Information Extraction with Llama and DeepSeek," CCIS, Springer, 2025. https://link.springer.com/chapter/10.1007/978-3-032-06075-4_2
- S. Devalla, "Designing RAG Pipelines in Microservice Architectures," *International Journal of Computer Technology* 6(2):16–25, 2025.
- D. Wampler, D. Nielson, A. Seddighi, "Engineering the RAG Stack: A Comprehensive Review of the Architecture and Trust Frameworks for RAG Systems," arXiv:2601.05264, 2026.
- T. Yu et al., "EKRAG: Benchmark RAG for Enterprise Knowledge Question Answering," ACL 2025. https://aclanthology.org/2025.knowledgenlp-1.13.pdf

**Cross-paper note:** Keith also sent a separate reference list for the Vendor Lock-In paper — see `daj-2026/notes.md` entry for May 5, 2026.

**Action items:**

- [x] RAG: weave in 4 new RAG references (Brown 2025, Yu 2025, Wampler 2026, Packowski 2024) — done May 6
- [x] RAG: discussion connections to listed surveys — done May 6
- [x] RAG: generalize DoW-specific acronyms — done May 6 (terminology paragraph + 3 inline parentheticals)
- [x] Convert `rag.tex` → `rag.docx` (pandoc with citeproc) — done May 7
- [x] Fix PDF figures not rendering in .docx (converted to PNG via `pdftoppm`, re-exported with sed-substituted temp .tex) — done May 7
- [x] Send .docx to Keith — sent May 7, 2026 (with vendor-lockin.docx)

## See Also

For full ITEA journal submission timeline and cross-paper context, see:
- `../daj-2026/CLAUDE.md` (sections: "ITEA TIW 2026 Presentations", "2026-03-30 Both Papers Submitted to ITEA Journal")
- `../daj-2026/notes.md` (March 2026 section on ITEA Opportunity)
- `/Users/michael.soltys/Library/CloudStorage/Dropbox-OmniaInBonum/Michael Soltys/Docs/Workshop/GBLWorkspace/Conferences/ITEALasVegas2026/notes.md` (full conference correspondence, travel, agenda)
