# File-Level Encryption with git-crypt (or transcrypt)

### Lösung:
- Obsidian Vault in privatem Repo auf GitHub hosten und ausgewählte Inhalte des Repos zusätzlich automatisch verschlüsseln und so gegen Datenleaks sichern
- Dieses Dokument illustriert die Strategie anhand `git-crypt`. Eine Alternative dazu wäre noch `transcrypt`

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
