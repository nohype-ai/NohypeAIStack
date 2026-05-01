# Encrypted Obsidian Vaults

Dieses Dokument dokumentiert eine Strategie um sensitive Obsidian Vaults via GitHub Repos zu teilen und dennoch hinreichend privat zu halten.

## Overview

### Ziel:
- Obsidian Vaults via git teilen statt via Cloud Folder
- Grund 1: .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json`
- Grund 2: Generelle Vorteile von git nutzen: merging, branching, history, changes (von Agents) kontrollieren ...

### Challenge:
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert
- Microslop
- Repos gelten einfach nicht als hinreichend privat für sensitive Daten

### Lösung:
- Obsidian Vaults in Repos auf GitHub hosten aber teilweise automatisch verschlüsseln und so gegen Daten Leaks sichern

### Positive Nebeneffekte
- Alles in einem System: nur Repos statt Repos + Cloud Folder
- Ein Repo kann mehrere Remotes haben: Level der Redundanz frei wählbar, Unabhängigkeit von einzelnem Cloud Anbieter (Apple)

## How to: git-crypt + GPG + Namenskonvention

### Grundprinzip
- Verschlüsselung erfolgt über **GPG-Modus** von `git-crypt`
	- `git-crypt` ist mit Abstand das etablierteste Tool seiner Art, und es nutzt git filters welche ein natives git feature sind das genau für diesen Zweck gemacht wurde, so dass die ganze ver- und entschlüsselung automatisch im Hintergrund passiert
- Zusätzlich wird eine **Namenskonvention** verwendet: Dateien/Ordner mit `vertraulich`, `Vertraulich`, `sensitive`, `Sensitive` im Namen werden automatisch verschlüsselt
- Das Repo ist weitgehend **self-contained**:
	- Für Kollaborateure soll der Ansatz im Repo dokumentiert sein, etwa so: [Repo Documentation Template](Repo%20Documentation%20Template.md)
	- Diese Doku darf natürlich selbst nicht mit verschlüsselt sein – ist sie nach der beschriebenen Strategie auch nicht
	- Durch die Dokumentation bleibt das Repo self-contained: Was ein neuer Kollaborateur zu tun hat kann er direkt im Repo lesen. Er muss dann nur einmal seinen public key erzeugen und sich vom Repo Owner dem Repo hinzufügen lassen.

### Wichtige Dateien & Speicherorte

#### Im Repo
- `.gitattributes` → enthält die Verschlüsselungsregeln, zum Bsp:
  ```gitattributes
  # Verschlüssele alle Dateien/Ordner, die diese Begriffe im Namen enthalten:
  **/*[Vv]ertraulich* filter=git-crypt diff=git-crypt
  **/*[Ss]ensitive* filter=git-crypt diff=git-crypt
  **/*[Vv]ertraulich*/** filter=git-crypt diff=git-crypt
  **/*[Ss]ensitive*/** filter=git-crypt diff=git-crypt
  ```
- `README.md` → enthält die Anleitung für Nutzer
- `.git-crypt/` — enthält die verschlüsselten symmetrischen Schlüssel (wird automatisch verwaltet) 
- `.git-crypt/keys/` — hier liegen die mit den Public Keys der Nutzer verschlüsselten symmetrischen Schlüssel. Werden auch automatisch von `git-crypt` verwaltet, man muss hier nichts manuell ändern.

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

**Nutzer entfernen:**
```bash
git-crypt remove-gpg-user <email-oder-key-id>
git add .git-crypt
git commit -m "Remove collaborator"
git push
```

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
