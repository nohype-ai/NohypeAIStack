# Dev Harness Playbook

**Elements of a project-level harness for long-running coding agents**

- **Elements are tangible repo documents** that give coding agents durable context over long horizons. They are files (or in-repo doc surfaces) agents can open, link, and maintain.
- Elements are not: agent product internals (tools, MCP, models), runtime config, advice that never becomes files, any aspects that are already parts of other elements (like DoD being part of the task completion guide)

⚠️ This is a conceptual tool box and a high-level conceptual framework of maximizing agent leverage in a project. It is not a requirement to implement all the tools in the tool box, nor is it a reflection of the tools we already use in any specific project. What most projects already use is a fraction of what we outline here, and each tool can also be implemented to various degrees of completeness. In that sense all the identified elements are optional.

---

## Core model of agent input

**Order is intentional** (also the TOC). Each row = one essential element.

| #                                         | Input                               | Role                                                                                      |
| ----------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------- |
| [1](#1-repo-local-constitution)           | Constitution                        | Privileged standing instructions (root + nested walk-up)                                  |
| [2](#2-comprehensive-documentation)       | Documentation                       | What the system *is* (as-is)—navigated as needed                                          |
| [3](#3-hierarchical-objectives)           | High-level objectives               | Where we are *going* (to-be / why)—goals, vision, target arch, epics; parents tasks       |
| [4](#4-task-management)                   | Task management                     | Leaf workflow: what exists, state, what is in progress                                    |
| [5](#5-task-template-dor)                 | Task template (DoR)                 | Schema + readiness bar for a card before work                                             |
| [6](#6-task-completion-guide)             | Task completion guide               | How to *execute* any ready task (incl. DoD)                                               |
| [7](#7-specialized-task-templates)        | Specialized template                | How to execute *this kind* of work or role pass                                           |
| [8](#8-specific-task-card)                | Specific task card                  | This run’s goal, scope, acceptance                                                        |
| [9](#9-work-log--durable-record)          | Work log / durable record           | Progress mid-task + how completion is filed                                               |
| [10](#10-harness-improvement-policy-meta) | Harness evolution policy            | *(meta)*: **Friction → harness upgrade** as habit; explicit paths so high-leverage change is normal |

**Session minimums**

| Job | Inputs |
|-----|--------|
| **Execute task** | §6 + §8 (+ parent §3; optional §7); on friction, apply §10 (don’t only work around it) |
| **Create / refine task** | §5 + parent §3 + §4 as needed (+ §2) |
| **Improve harness** | §10 + target surface; usually a dedicated §8 from the friction loop |

§1 when present is always standing law. §2 / §3 / §4 / §9 supply depth, direction, leaf queue, and trail—not a restatement of the goal.

---

## 1. Repo-local constitution

- **What:** Conventionally named files some agents **auto-load**—`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, etc.
- **Optional, product-dependent.** Delivery mechanism for standing instructions—not a second docs system.

**How products treat them (value scales with this)**
- Always-on / sticky / high-priority inclusion; known filename
- **Root + any subfolder**; walk-up from current context → parents → root  
  `effective ≈ root + … + parent + local`
- Sometimes system/developer-channel injection
- *Privileged* = harder to miss—not undilutable; without special load, just another markdown file

**Value vs normal docs:** load policy + imperative defaults—not agent-only knowledge. Humans and agents share the same truth when docs are good.

**Keep short:** few dozen–low hundreds of lines (often ≪ 200); nested even thinner; links over copies; imperative tone.

**Include**
- Must-nots (secrets, protected paths, irreversible ops)
- Pointers: §3 tree, §4 board, §5 DoR, §6 guide, §9 convention; top §2 entry points
- Tiny high-frequency invariants; critical commands or link to build/test doc
- Nested: local overrides/entrypoints only (additive—don’t copy root)

**Exclude** → put in §2–§9 (substance, goals, board state, DoR fields, DoD, playbooks, card body, work log). How agents improve the harness → §10 (may live *in* §1 or §6, but must exist)

**Anti-patterns:** novel-length silo; nested file in every dir; sole copy of architecture truth; relying on filename without privileged load

---

## 2. Comprehensive documentation

- **What:** Ordinary project docs—*as-is* product/architecture, modules, setup, test, ADRs, deep-dives.
- Agents navigate READMEs/links well; constitution/guide should **point**, not inline everything.
- Quality of autonomous work tracks doc quality.

**Typical content:** orientation index · module/architecture map · build/run/test · domain deep-dives · decision history · verification oracles (matrices, goldens) linked from §6

**Vs §3:** §2 = what *is*; §3 = where we’re *driving* it (link; don’t merge undated)

**Anti-patterns:** truth only in chat/long AGENTS.md; unreachable docs; no §3 when multi-task change has a clear destination

---

## 3. Hierarchical objectives

- **What:** Documented higher-level objectives that **parent** run-scoped tasks.
- **Kinds:** product (vision, philosophy, target design) · technical (target architecture, NFRs) · mid-level (epics, themes)
- **Principle:** hierarchy + **written intent at each non-leaf**—layout is free; folders are one natural form.

**Example shape (not mandatory)**
```text
Tasks/   (entrypoint)
  README.md                 ← direction + priority among top goals
  Some-Goal/
    README.md               ← intent, NFRs/non-goals, priority among children
    Some-Epic/
      README.md
      task-….md             ← leaf (§8)
```

**Priority at high levels lives here** (stable lists in entrypoint / mid-level READMEs)—not a super-dynamic kanban of every goal/epic. Leaf dynamic state → §4.

**Objective doc:** intent · why · constraints/non-goals · links to §2 (as-is) · child map + **order/focus** · optional status

**Agent uses:** read parents before execute · place new tasks under right parent · inherit non-goals · optional parent update on done (§6)

**Anti-patterns:** flat title pile · empty “Epic” folders · paste full vision into every card · as-is §2 merged with to-be here

---

## 4. Task management

- **What:** In-repo surface for **leaf** work items: existence, relations, **workflow state** (e.g. inbox → ready → in progress → done).
- Forms: kanban board, status index, folder layout with statuses—often **links** into the §3 tree.

**Split with §3**

| Question | Prefer |
|----------|--------|
| Which goal/epic next? | §3 entrypoint / mid-level READMEs |
| Which task ready / in progress / done? | §4 |
| Full objective intent | §3 |

- Board may thin-point at “current focus epic” → §3; don’t fork a second high-level priority system.

**Anti-patterns:** work only in chat · titles with no card body · board as sole epic mechanism · board priority fighting §3 READMEs

---

## 5. Task template (DoR)

- **What:** Dedicated doc = **definition of ready**—how a card must look before work.
- **Not:** filled card (§8) · execution guide (§6) · specialized playbook (§7)

**Defines**
- Required fields (problem, outcome, scope, non-goals, acceptance, risks, deps, **parent objective**, pointers)
- Optional (open questions, §7 link, design sketch)
- DoR checklist · authoring questions · naming/location (often under epic folder) · examples

**Agent uses:** create · refine toward ready · gate implement until bar met · interview human with question list

**Anti-patterns:** so heavy nothing is ready · no template (every card a different shape) · DoR only buried in §6 with no authoring doc

---

## 6. Task completion guide

- **What:** How to **execute any** ready task. Central process doc.
- **Holds:** DoD · verification · outputs · work-log/done filing (§9) · stop rules · scope discipline · when to start (→ §5) · read parents (§3) · doc entry points (§2/§3)
- **Not a separate element:** Definition of Done (DoR = §5)

**DoD layers (typical):** machine checks · card acceptance · diff hygiene · memory updates (board, §9, optional parent touch)

Cards add acceptance; they don’t reinvent global DoD.

---

## 7. Specialized task templates

- **What:** Optional **execution** playbooks—job type (“add language”, “release”) or role (explore / implement / review).
- **≠ §5:** §5 = how to *write* a card; §7 = how to *perform* a class of work.

**Into the session:** human supplies · card links · agent picks from repo library

**Anti-patterns:** contradict §6 · name collision with “task template” · override project laws instead of specializing

---

## 8. Specific task card

- **What:** One run-scoped unit of intent—instance of §5, under §3 when hierarchy exists, executed via §6 (+ optional §7).

**Body (per §5):** outcome · scope/non-goals · acceptance · risks/deps · parent link · code/doc pointers · optional §7 · log/done convention

**Anti-patterns:** title-only thrash · ignore DoR · orphans when work is epic-driven

---

## 9. Work log / durable record

**Two jobs**
- **In progress:** resume without re-explore (hypothesis, tries/fails, blockers, branch/PR pointers)—append-only, operational
- **When done:** lasting record—not only a board flip

**Done conventions (project picks; §6 points here):** Done/ folder · history log file · closing writeup on card · board + archive path · optional parent epic child-map/status update

**Anti-patterns:** “done” only in chat · log only mid-task, nothing recoverable after close

---

## 10. Harness improvement policy *(meta)*

- **Ultimate goal:** turn agent work into a **self-improving harness**—especially high-leverage surfaces (DoD §6, DoR §5, §7 playbooks, board/objective conventions, doc entry points).
- **Core habit (the point of §10):**

```text
hit friction in a real task
    → notice / name it (don’t only work around in chat)
    → file or update a harness-improvement task (§8, often under a harness/process epic in §3)
    → apply the upgrade (or propose it) via the paths below
    → later runs hurt less
```

- **Enabler, not the goal:** make upgrades **explicit enough to be safe** (what may change, when, how)—so the loop is *invited*, not frozen or chaotic.
- **Question answered somewhere findable** (in §1, §6, a short doc, or a standing epic)—not necessarily its own file.

**What counts as friction (examples)**
- Vague / uncheckable DoD · missing DoR fields · repeated “ask human” for the same gap · weak or missing §7 · board/objective signals that mislead · docs entry points agents never find · same footgun twice

**Duty on every session (not only “improve harness” jobs)**
1. Prefer finishing the product task—but **don’t swallow process pain**.
2. If friction is real (repeated, costly, or will hit the next run): **open or update** a harness-improvement §8 (link from §9 / done notes if useful).
3. High-leverage upgrades are **normal work**, not a side hobby: e.g. “tighten DoD verification”, “add DoR field for parent epic”, “add language-profile §7”.
4. Routine bookkeeping (§9, card moves) stays easy so energy goes to the loop, not ceremony.

**Paths that make the loop work** (policy content)
- **Default writable:** §9 · §4/§8 state · leaf tasks · parent child-map updates §6 already requires  
- **Improve via dedicated task / on request:** §5 DoR · §6 DoD/verification/stop rules · §7 · §2 entry points · §3 epic structure · board layout  
- **Slow / human-gated:** §1 · §3 top vision/priority · **§10 itself** · destroying done history  
- **How:** task-scoped preferred · propose-then-apply vs apply-in-PR · bootstrap missing pieces vs only extend  

**Anti-patterns:** work around friction forever in chat · harness read-only · agent may only touch product code · silent mid-feature DoD/DoR rewrites · file improvement tasks that never get prioritized · “safety” so strict the loop never lands

---

## Quick reference (owns · missing · check)

| § | Owns | If missing | Check |
|---|------|------------|--------|
| **1** | Always-on must-nots + pointer index | Defaults/entrypoints easy to miss *(if product supports load)* | Short; privileged walk-up; links not silo |
| **2** | As-is knowledge, oracles | Wrong assumptions; thrash rediscovering structure | Navigable docs (+ oracles) |
| **3** | To-be / why; goal·epic tree; high-level priority | Local “done” drifts from vision / target arch / epic non-goals | Hierarchy + intent + priority at entry/mid; tasks under |
| **4** | Leaf ready / in progress / done | No shared leaf queue/state | Board (or equiv.) → real cards |
| **5** | Card schema + DoR | Underspecified cards; weak create/refine | Template for create / refine / gate |
| **6** | Execute any task; global DoD | Inconsistent process; vague done | Guide: DoD, outputs, §9, parents, stop rules |
| **7** | Execute this *kind* / role | Reinvent procedure; miss pitfalls *(when recurring)* | Specialized templates where needed |
| **8** | This change (filled instance) | Unbounded or invented goals | Cards meet §5; parented when epic-driven |
| **9** | Progress + filing when done | Can’t resume; no trail after close | Mid-task log **and** done-filing convention |
| **10** | **Friction → harness task → upgrade** (esp. DoD/DoR/…); explicit paths | Friction only worked around **or** thrash / freeze | Loop is duty on sessions; improvement §8s get filed; paths clear |

