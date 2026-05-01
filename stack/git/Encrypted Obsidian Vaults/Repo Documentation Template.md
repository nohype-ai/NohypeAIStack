# Verschlüsselung & Zusammenarbeit

Dieses Repository verwendet **git-crypt** im GPG-Modus zur Verschlüsselung sensibler Daten.

## Namenskonvention (wichtig!)
Dateien und Ordner werden automatisch verschlüsselt, wenn sie eines der folgenden Wörter im Namen enthalten:
- `vertraulich`, `Vertraulich`
- `sensitive`, `Sensitive`

Beispiel: `Finanzen_Vertraulich_2025.xlsx` oder `Contracts_Sensitive/`

## Setup für neue Mitwirkende

1. **GPG-Schlüssel generieren** (falls noch nicht vorhanden)
   ```bash
   gpg --full-generate-key
   ```

2. **Public Key teilen**
   - Exportiere deinen Public Key und sende ihn an den Owner

3. **Repository klonen** (sobald Owner dich via git-crypt dem repo hinzugefügt hat)
   ```bash
   git clone <repo-url>
   cd <repo-name>
   ```

4. **Repo entsperren**
   ```bash
   git-crypt unlock
   ```

5. Danach kannst du normal mit Obsidian arbeiten. Alle Dateien sind lokal lesbar.

## Hinweise
- Nach dem ersten `unlock` musst du diesen Schritt normalerweise nicht wiederholen
- Bei Problemen: `git-crypt status` ausführen
- Die README bleibt unverschlüsselt