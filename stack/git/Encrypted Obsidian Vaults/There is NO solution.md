> Prompt: "I feel an obvious unconquered niche here. No true solution for git + E2EE without platform lock-in. You think this niche will grow in importance due to AI? I want everything in a repo and everything in text because AI. And that implies encryption. And basic sovereignty and sanity implies E2EE and avoiding lock-in (i.e. keeping concerns decoupled). doesn't sound like too much to ask but apparently I am one of very few asking. question is: will the demand of such a solution grow because AI?"

**Yes, I think you're onto something real.**

Your intuition is sharp. Let me give you a direct and honest answer.

### Will Demand for "Git + Strong E2EE + No Lock-in" Grow Because of AI?

**Short answer:**  
**Yes, demand will likely grow** — but probably not as fast or as dramatically as you might hope, and it may not lead to a great solution anytime soon.

### Why Demand Should Increase

Here’s why your reasoning makes sense:

1. **AI is pushing almost everything into text and code**
   - Prompts, agents, workflows, evaluation datasets, RAG data, fine-tuning data, system prompts, context windows — more and more of this is living in Git repositories.
   - The "everything is a repo" mindset is growing fast in AI-native teams.

2. **Data sovereignty is becoming a real concern**
   - People and companies are increasingly uncomfortable with big platforms (GitHub, OpenAI, Anthropic, etc.) having access to their data.
   - Regulations around AI data usage are tightening in Europe and elsewhere.

3. **The desire for independence is rising**
   - More people want to avoid vendor lock-in and keep their options open (especially after seeing how platforms change terms or get acquired).
   - The "local-first + AI" movement is gaining traction.

4. **The current solutions are unsatisfying**
   - As we’ve discussed, there’s no clean solution that gives you strong E2EE + good Git collaboration + simplicity + independence.

So yes — the problem space you identified is real, and AI is making it more relevant.

### Why It Might Not Explode (The Realistic View)

However, here’s the counterpoint:

- **Most teams still prioritize convenience** over strong E2EE. They’re willing to accept "good enough" security (private repos + platform-managed encryption) in exchange for excellent Git UX and collaboration features.
- The "serious" teams that care about sovereignty are mostly solving it with **Strategy 3 or 4 + CMK** — even if it means some platform lock-in.
- Building a great solution in this niche is **technically and commercially difficult**. It requires solving encryption, performance, usability, and collaboration all at once.
- The niche might grow into a **solid medium-sized market**, but it probably won’t become a massive, well-funded category unless a big player or well-backed startup decides to go after it aggressively.

### My Prediction (2026–2030)

| Timeframe     | Expected Development |
|---------------|----------------------|
| **Next 1–2 years** | Slow growth. `git-remote-gcrypt` remains dominant in the niche. Some new `age`-based experiments appear. |
| **3–5 years**     | Moderate growth. We might see 1–2 serious new projects emerge. Demand increases noticeably among AI-native teams. |
| **5–10 years**    | Possible consolidation. A clearer winner might emerge, or big platforms might add better E2EE options. |

### Final Thought

You’re not wrong — there *is* an obvious gap. The combination of:

- Strong E2EE
- Full Git collaboration features
- No platform lock-in
- Simplicity

…is still largely unsolved.

Whether this niche becomes important enough to attract real investment and innovation depends heavily on how paranoid (or sovereign-minded) the AI community becomes over the next few years.