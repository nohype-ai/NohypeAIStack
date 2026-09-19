## Observations

- tunnel vision, rarely takes a step back, optimizes what should not exist
- does not use latest or most idiomatic tech
- produces much more code than necessary, never weighs compexity versus value added
- tacks stuff on instead of integrating it into what pre-exists in the way what pre-exists intends
- prefers adding code over adjusting code, leading to a disintegrated bloated codebase
- writes comments that describe what it did instead of the result
	- for example comments that explain how the new code relates to the old code that doesn't even exist anymore, as if the comment is part of the answer in the conversation in that moment
- rarely adds files and types, tries to stuff new code into existing files and folders, inflating their scope and watering down their concern
- overzealous: does too much too early, mindlessly, without considering the direction in which things actually should move or what a meaningful iteration/step would be at that moment
- does not weigh criticality versus scope of a change (highly critical changes should be done in smaller steps)
- applies common practice and conventional wisdom generically (but confidently) without actually **thinking** about the specific scenario at hand
- is satisfied with making things "work" without second thought on making things the right way, and without thinking on a level of structure and principles, leading to massive files that entangle many concerns
- agent overly weights the last feedback from the user, generally putting the last user input suddenly at the center of the whole thing being worked on, instead of considering where in the structure and shape of that thing the aspect applies.
	- in texts this typically means: turning a small hint suddenly into a whole section or weaving the hint into the whole document instead of considering where it belongs thematically into the structure of the text, and even rarer: considering what the hint conceptually might imply about that very structure and how that structure may need to be adjusted so that the hint can fit into one place naturally
- takes pre-existing things as hard law instead of questioning them, even if a small adjustment would unlock a lot of value, rather invents complex workarounds to adhere to laws it silently assumes and does not even state explicitly
	- example: complex workarounds with old tech to keep a min deployment target. not realizing the min deployment target may be outdated and may be increased. not mentioning at all how easy and straight forward the solution would be if the deployment target requirement were loosened.
- overly large artifacts (files, functions etc.)
- entangling of concerns (constantly)
- introducing cycles (collapse structure → nothing left anyone, including agents, could reason *about*)

## Practical Costs

- agent needs more and more time and tokens to accomplish the same size of feature
- agent makes one thing work while breaking another
- agent has more and more trouble correctly explaining what a system does and how it works, which is of course self-amplifying
- needless use of outdated tech
- needless technical limitations like reduced hardware compatability
- needless inconsistencies and compromises in the product (user facing), needless lack of performance, needless risk of bugs and crashes

## My Thoughts

- the issue is not that agents are incapable but that humans use agents to amplify what those humans already mistakenly do: buiding up too much tech debt in favour of quick short term wins
- agents amplify our good and bad habits
- → ❗ Never before have software makers been able to build up so much technical debt so quickly.

## Grok's Diagnosis

- the mechanism (of failure): Treats file boundaries and types as hard law. Treats the inside of an existing type as a dumping ground.
- Agents almost never split a type on their own. They will happily add a 200-line method.
- “Rarely adds files and types” is the root bias. Entanglement, cycles, 1750 LoC, and “one thing works while another breaks” are downstream.
- Language support went the other way because that domain already had the opposite default: specialized templates, a test matrix as oracle, and a bounded module (LanguageProfile). The agent extended a system that **intended to be extended**. Window/map never got that. Every new slice landed on WindowSession because that was the object the last session already had open.
- A complete §5+§6 that “ensures” architectural taste is that failure, one level up. Your working style is rapid, opinionated, interrupt-driven. A heavy DoR that gates all implement work will be skipped for “small” slices — which is exactly how hover, mute VMs, and union-mount got in.
  
  ## Grok's Prescription

- Card asks “which type owns this?” Guide says: if the hub would grow, or a file is already over a hard limit, or a structural question is open → stop and ask, do not implement around it. Next task then finds the type this task was forced to create. That is the loop.
-  You already have a working §7: language workflow + profile template + test matrix. That is the pattern to copy, not a 10-element playbook completeness project.
- Habit change, not a doc: any feature that would touch the window hub gets a human design beat before implement: “which type owns this, and what is the hub allowed to gain?” You already do this when you slow down. Vibe-coding skipped it.