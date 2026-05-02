# Encrypted Obsidian Vaults

Dieser Ordner beschreibt Strategien um sensitive Business Obsidian Vaults via Git Repos zu teilen und dennoch hinreichend privat zu halten.

## Ziel
- Obsidian Vaults via git teilen statt via Cloud Folder
- **Grund 1:** .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json` (allgemein: steuerbare Projekt-/Nutzer-Grenze)
- **Grund 2:** Edits von AI Agents lassen sich anders kaum überwachen. In einem reinen Cloud Folder blieben viele Änderungen unbemerkt und würden von keinem Menschen abgenommen werden.
  - Das ist eine neue aber fundamentale Anforderung. Agents sind jetzt zentraler Teil von Knowledge Work, auch jenseits vom Code selbst: Harness, Scaffolding, LLM Wiki etc.
- **Beide Gründe zielen auf effektive Nutzung von KI.** Obsidian ist die IDE für Markdown, und Markdown ist die Sprache der LLMs.

## Challenge
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert (GitHub down times, Microslop)
- Auf regulären git Hosting Services (wie GitHub) gelten selbst private Repos einfach nicht als hinreichend privat für sensitive Daten. Auch weil da bezüglich Privacy andere Standards angewendet werden als bei echten Business Cloud Services.

## Weitere Vorteile (wenn gelöst)
1. Generelle Vorteile von git nutzen: merging, branching, history ...
2. Alles in einem System: nur Repos statt Repos + Cloud Folders
3. Ein Repo kann mehrere Remotes haben:
	- Level der Redundanz frei wählbar
	- Unabhängigkeit von einzelnem Cloud Anbieter (Apple, MS)
	- geografischer Speicherort wählbar (etwa Host im Heimatland)
4. Lesbarkeit für Host (Apple, Microsoft) und Behörden kann ausgeschlossen werden. End-to-End Encryption wird möglich wenn nicht gar zum Default. (Privacy-Level generell selektiv einstellbar also pro Repo/Ordner/Datei)

## Strategien
1. [git filters](Strategy%201%20-%20git%20filters/README.md)
2. [git remote helper](Strategy%202%20-%20remote%20helper/README.md)
3. [self-hosting](Strategy%203%20-%20self-host%20on%20business%20cloud/README.md)
