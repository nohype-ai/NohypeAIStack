# Rotating the Encryption Password

🚨🚨🚨 This is a draft. The process has not been tested and verified yet.

Dieses Dokument beschreibt unseren Ansatz um das Passwort eines verschlüsselten Repos regelmässig zu rotieren. Es ergänzt `Encrypting Repos.md`, welches die generelle Strategie beschreibt.

## Requirements That Lead to This Approach

- **Threat Model:** Das Passwort kann über Zeit lecken (Logs von Inference Providern, unsichere Ablagen bei Kollaborateuren, Agent-Kontexte). Wenn das Repo später exposed wird (Breach, versehentlich public, Subpoena), kann jeder der das alte Passwort hat, alle alten Commits entschlüsseln — für immer.
- **Dauerhaft hochwertige Daten:** Finanzdaten, IBANs, Wohnadressen, Ausweisnummern, Verträge veralten nicht schnell genug, dass ein altes Passwort irrelevant würde.
- **`transcrypt --rekey` reicht nicht:** Re-verschlüsselt nur den current state, alte History bleibt mit altem Passwort lesbar.
- **Echte History-Rewrite ist zu teuer:** Jeden historischen Blob via `git filter-repo` neu zu verschlüsseln bedeutet, jeden Commit neu aufzubauen — SHA-Fingerabdrücke propagieren sich durch den Graphen. 1-3 Tage Aufwand mit realem Risiko, und erzielt für unsere Zwecke nichts was der einfachere Ansatz nicht auch liefert.
- **History ist für diese Repos opferbar:** Diese Repos enthalten operationelle Dokumente (Finanzdaten, Belege, Verträge, AI arbeiten), keine Codebases. Wir nutzen git für Kollaboration und Review der Arbeit von Agents — nicht für Archäologie. Commit-by-commit Diffs sind hier nicht produktiv nutzbar.

## The Approach: Orphan-Squash Rotation

Die Prozedur re-verschlüsselt den aktuellen Stand mit einem neuen Passwort in einem einzigen frischen Commit und ersetzt dazu den `main` Branch auf dem Remote. Keine historischen Commits bleiben erreichbar.

Dafür erzeugen wir einen **orphan branch** — kein Parent-Commit, keine History, aber working tree, lokale git config, remotes, hooks und transcrypt-Skripte bleiben erhalten (im Gegensatz zum `rm -rf .git` Ansatz, der all das auch zerstören würde).

Der Trick zum Re-Verschlüsseln: `transcrypt.password` ist ein normaler git config Wert, den der clean/smudge filter live liest. Wir ändern nur diesen Wert — kein flush, kein reconfigure — und schon verschlüsselt `git add -A` mit dem neuen Passwort.

### Procedure

```zsh
# 1. Unlock with old password (working tree becomes plaintext)
unlock    # or: transcrypt -y -c aes-256-cbc -p "$OLD_PASS"

# 2. Create orphan branch — no parent, no history. Working tree and all
#    local state (git config, remotes, hooks, transcrypt scripts) stay intact.
git checkout --orphan fresh-start

# 3. Switch to new password in git config. Clean/smudge filters read this live.
git config --local transcrypt.password "$NEW_PASS"

# 4. Re-stage all files. Orphan checkout preserved the old-encrypted index from
#    the previous HEAD; git add -A reruns the clean filter (now with new password)
#    and overwrites the index with new-encrypted blobs.
git add -A

# 5. Commit, then replace main with this branch (-M force-renames the
#    current branch to main, overwriting the old main ref → 2 branches
#    collapse to 1)
git commit -m "Fresh start — re-encrypted with new password"
git branch -M main

# 6. Force-push to all remotes (invalidates all existing clones)
git push --force --all
git push --force --tags
```

Collaborators re-clone. Total human time: under 5 minutes.

**Why `git add -A` is necessary:** orphan checkout drops history but leaves the index untouched — it still contains old-encrypted blob hashes from the previous HEAD. Without re-staging, the new commit would reference old-encrypted blobs. `git add -A` reruns the clean filter with the new password.

### What This Achieves

- ✅ The old password can read **nothing** on the current remote `main`
- ✅ Local git config, remotes, hooks, transcrypt scripts all preserved
- ✅ Force-push invalidates all existing clones → everyone re-clones
- ✅ Operation takes ~5 minutes instead of days
- ✅ Repeatable at every rotation, consistently low cost

### What This Sacrifices

- Git history (commit messages, diffs, when-changed tracking)
- Open PRs against old `main` become invalid
- Tags pointing to old commits need manual handling
- Forks diverge from main (manual reconciliation)
- GitHub may retain old commits in internal backups for a while (not controllable)

### Residual Risk

Anyone who cloned **before** the rotation (legitimate or attacker) has old history encrypted with the old password — **forever**. History rotation bounds future exposure, not past.

- Each rotation shrinks this attack surface for new attackers; only those who already had access retain it.
- Password leak before rotation + clone before rotation = attacker has stale snapshot that ages over time.

### Recommended Rotation Cadence

- **Trigger-based** (primary): collaborator leaves, suspected leak, serious agent incident
- **Periodic hygiene**: annually as default, quarterly for high-sensitivity repos
- **Don't over-rotate**: monthly rotation without suspect is more disruption than benefit

Cost per rotation: ~5 minutes. Cadence isn't realistically limited by effort.

## Onboarding Collaborators After Rotation

Nach jeder Rotation gilt folgende Prozedur für alle Kollaborateure — unabhängig davon ob sie das alte Passwort hatten oder nicht:

1. **Offene lokale Änderungen committen oder sichern.** Alles was nicht committed ist geht verloren, da der alte Klon im nächsten Schritt gelöscht wird.
2. **Lokalen Klon löschen.** Ob man das alte Passwort hatte oder nicht — der alte Klon enthält History verschlüsselt mit dem alten Passwort, die mit dem neuen nicht lesbar ist. `unlock` mit dem neuen Passwort auf dem alten Klon würde die alte Blobs garbage-decrypt → unleserlicher Inhalt.
   ```bash
   rm -rf path/to/old/clone
   ```
3. **Neu klonen:**
   ```bash
   git clone git@github.com:org/repo.git
   cd repo
   ```
4. **Entsperren mit neuem Passwort:**
   ```bash
   unlock   # neues Passwort eingeben
   ```
5. **Neues Passwort im Password Manager ablegen.**

**Wer das alte Passwort weiter benutzt:** Sobald der remote `main` ersetzt wurde, funktioniert das alte Passwort gegen den neuen Stand nicht mehr — `git pull` wird die Divergenz ablehnen (kein fast-forward möglich), und ein `unlock` mit dem alten Passwort auf dem neuen remote Stand würde garbage produzieren. Der Schaden bleibt lokal und wird beim nächsten Sync sofort sichtbar.