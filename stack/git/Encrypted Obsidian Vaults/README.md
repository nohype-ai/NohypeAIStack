# Encrypted Obsidian Vaults

Dieses Dokument dokumentiert eine Strategie um sensitive Obsidian Vaults via GitHub Repos zu teilen und dennoch hinreichend privat zu halten.

## Overview

### Ziel:
- Obsidian Vaults via git teilen statt via Cloud Folder
- Grund 1: .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json` (allgemein: steuerbare Projekt-/Nutzer-Grenze)
- Grund 2: Generelle Vorteile von git nutzen: merging, branching, history ...
- Grund 3: Edits von AI Agents lassen sich anders kaum überwachen. In einem reinen Cloud Folder blieben viele Änderungen unbemerkt und würden von keinem Menschen abgenommen werden.

### Challenge:
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert
- Microslop
- Selbst private Repos gelten einfach nicht als hinreichend privat für sensitive Daten

### Lösung:
- Obsidian Vaults in privaten Repos auf GitHub hosten aber sensitive elemente zusätzlich automatisch verschlüsseln und so gegen Datenleaks sichern

### Positive Nebeneffekte
- Alles in einem System: nur Repos statt Repos + Cloud Folder
- Ein Repo kann mehrere Remotes haben: Level der Redundanz frei wählbar, Unabhängigkeit von einzelnem Cloud Anbieter (Apple), auch geografischer Speicherort wählbar (etwa Host im Heimatland)
- Verschlüsselung selektiv anwendbar, Repo Sichtbarkeit und Verschlüsselungsregeln pro Repo/Ordner/Datei einstellbar.
- Lesbarkeit für Host (Apple, Microsoft) und Behörden kann ausgeschlossen werden

## How to: git-crypt + GPG + Namenskonvention

### Grundprinzip
- Verschlüsselung erfolgt über **GPG-Modus** von `git-crypt`
	- `git-crypt` ist mit Abstand das etablierteste Tool seiner Art, und es nutzt git filters welche ein natives git feature sind das genau für diesen Zweck gemacht wurde, so dass die ganze Ver- und Entschlüsselung automatisch im Hintergrund passiert
- Zusätzlich wird eine **Namenskonvention** verwendet: Dateien/Ordner mit `vertraulich`, `Vertraulich`, `sensitive`, `Sensitive` im Namen werden automatisch verschlüsselt
- Das Repo ist weitgehend **self-contained**:
	- Für Kollaborateure soll der Ansatz im Repo dokumentiert sein, etwa so: [Repo Documentation Template](Repo%20Documentation%20Template.md)
	- Diese Doku darf natürlich selbst nicht mitverschlüsselt sein – ist sie nach der beschriebenen Strategie auch nicht
	- Durch die Dokumentation bleibt das Repo self-contained: Was ein neuer Kollaborateur zu tun hat kann er direkt im Repo lesen. Er muss dann nur einmal seinen public key erzeugen und sich vom Repo Owner dem Repo hinzufügen lassen.

### Wichtige Dateien & Speicherorte

#### Im Repo
- `.gitattributes` → enthält die Verschlüsselungsregeln, zum Bsp:
  ```gitattributes
  # Verschlüssle alle Dateien/Ordner, die diese Begriffe im Namen enthalten:
  **/*[Vv]ertraulich* filter=git-crypt diff=git-crypt
  **/*[Ss]ensitive* filter=git-crypt diff=git-crypt
  **/*[Vv]ertraulich*/** filter=git-crypt diff=git-crypt
  **/*[Ss]ensitive*/** filter=git-crypt diff=git-crypt
  ```
- `README.md` → enthält die Anleitung für Nutzer
- `.git-crypt/` — enthält die verschlüsselten symmetrischen Schlüssel (wird automatisch verwaltet) 
- `.git-crypt/keys/` — hier liegen die mit den Public Keys der Nutzer verschlüsselten symmetrischen Schlüssel; `git-crypt add-gpg-user` legt die passenden Dateien an. Optional kann man einzelne Einträge bei Nutzerentfernung manuell löschen (siehe **Nutzer entfernen**).

#### Lokal auf Rechner von Repo Owner
- `~/.gnupg/` — GPG-Schlüsselbund (enthält alle Public und Private Keys)
- `git-crypt` speichert keine zusätzlichen Konfigurationsdateien außerhalb des Repos

### Befehle (als Owner)

**Neuen Nutzer hinzufügen:**
```bash
git-crypt add-gpg-user <email-oder-key-id>
git add .git-crypt
git commit -m "Add collaborator"
git push
```

**Nutzer entfernen (ohne kryptografisches Read-Revocation):**
- Wenn euch genügt, dass der Nutzer **keinen Repo-Zugriff mehr** hat (und ein **alter lokaler Klon** für ihn weiterhin lesbar bleiben darf): **Zugriff auf GitHub/Hosting entziehen** (Einladung, Team/Org).
- **Schlüsselrotation** in Git/`git-crypt` (alles neu verschlüsseln, alle neu einbinden) ist dann **nicht nötig**, um den Austritt operativ abzuschließen.
- Hinweis: `git-crypt rm-gpg-user` ist im Upstream **unimplementiert**; für dieses Modell passt das zur Erwartung.
- **Optional (Hygiene):** In `.git-crypt/keys/` liegen pro Nutzer Dateien der Form `.git-crypt/keys/<key-name oder default>/<version>/<GPG-Fingerprint>.gpg`. Passende `.gpg`-Dateien für den Nutzer **löschen**, dann `git add .git-crypt`, `git commit`, `git push`. Damit kann ein **neuer** Klon mit diesem GPG in der **aktuellen** Repo-Version typischerweise **nicht mehr** `git-crypt unlock` aus dem Repo-Inhalt; **lokale Klone und bereits entsperrte Arbeitsverzeichnisse** bleiben davon unberührt.
- **Historie:** Alte Commits können die gelöschte `.gpg` weiterhin enthalten; ohne **History-Rewriting** ist sie nicht „überall“ aus dem Repository verschwunden.

**Status prüfen:**
```bash
git-crypt status
```

### Schlüssel-Management
- Public Keys der Kollaborateure müssen **nicht** im Repo liegen
- Sie werden in deinem lokalen GPG-Schlüsselbund (`~/.gnupg/`) verwaltet
- Das Repo speichert nur die verschlüsselten symmetrischen Schlüssel (in `.git-crypt/keys/`)
- Repo ist nach dem Hinzufügen weitgehend self-contained

### Namenskonvention (in `.gitattributes`)
- allgemeines pattern: vertraulich / sensitive
- zusätzlich bestimmte folder (bilanz / steuer / personal / vertrag), damit die nicht alle "vertraulich" im Namen haben müssen? Wäre andererseits inkonsistenter und komplexer ... 
- Achtung: keine automatische entscheidung über verschlüsselung allein basierend auf Dateityp! Format sagt nichts über Inhalt.
