# 🌿 GatherReminder

Petit plugin LOTRO qui rappelle d’activer une compétence de détection de ressources après la connexion ou une résurrection en solo.

**🌍 Langues / Languages / Sprachen :** 🇫🇷 Français · 🇬🇧 English · 🇩🇪 Deutsch

---

## 🇫🇷 Français

### 📖 Présentation

**GatherReminder** affiche une petite fenêtre pour te rappeler d’activer une compétence de détection liée aux métiers de récolte. Jusqu’à **3 compétences** peuvent être mémorisées par personnage.

### ✨ Fonctionnalités

- Jusqu’à 3 compétences de détection enregistrées par personnage.
- Une seule détection à choisir lorsque le rappel apparaît.
- Position de la fenêtre mémorisée.
- Clic droit sur une case pour la vider.
- Bouton **Plus tard** pour fermer temporairement le rappel.
- Réaffichage après une résurrection en solo.
- Pas de popup automatique après une défaite en communauté ou en raid.
- Si le personnage est encore en combat après la résurrection, le rappel attend la fin du combat.
- Interface FR / EN / DE.

### 📦 Installation

Copie le dossier **Dusk** de la release dans :

```text
Documents\The Lord of the Rings Online\Plugins\
```

Puis en jeu :

```text
/plugins refresh
```

Charge ensuite **GatherReminder** depuis le gestionnaire de plugins LOTRO.

### 🎮 Utilisation

Au premier lancement, glisse jusqu’à 3 compétences de détection dans les cases. Quand le rappel apparaît, clique sur celle que tu veux activer. Un **OK** confirme le choix et la fenêtre se ferme automatiquement.

### ⌨️ Commandes

- `/gather` — afficher ou masquer la fenêtre.
- `/gr` — alias court.
- `/grem` — alias court.
- `/gather reset` — vider les 3 cases.
- `/gather center` — recentrer la fenêtre.
- `/gather help` — afficher l’aide.

### ⚙️ Sauvegardes & réglages

Les compétences et la position sont sauvegardées **par personnage**. GatherReminder utilise son propre espace de sauvegarde Lua afin de rester isolé des autres plugins.

### 🌍 Langues

L’interface est disponible en **français, anglais et allemand** et suit automatiquement la langue du client LOTRO.

### ⚠️ Limites / notes

L’API Lua de LOTRO ne permet pas de vérifier de manière fiable si une compétence de détection est réellement active. Le plugin utilise donc ton clic dans la fenêtre comme confirmation.

### 🐛 Bugs & suggestions

Utilise les [Issues GitHub](https://github.com/Dusk-92/GatherReminder/issues).

### 🙏 Crédits

Développement et maintenance : **Dusk-92**.

---

## 🇬🇧 English

### 📖 Overview

**GatherReminder** displays a small reminder window for gathering tracking skills. Up to **3 tracking skills** can be saved per character.

### ✨ Features

- Up to 3 saved tracking skills per character.
- Choose one tracking skill when the reminder appears.
- Saved window position.
- Right-click a slot to clear it.
- **Later** button to temporarily dismiss the reminder.
- Reminder after a solo resurrection.
- No automatic popup after a fellowship or raid defeat.
- If the character is still in combat after resurrection, the reminder waits until combat ends.
- FR / EN / DE interface.

### 📦 Installation

Copy the **Dusk** folder from the release into:

```text
Documents\The Lord of the Rings Online\Plugins\
```

Then in game:

```text
/plugins refresh
```

Load **GatherReminder** from LOTRO's Plugin Manager.

### 🎮 Usage

On first launch, drag up to 3 tracking skills into the slots. When the reminder appears, click the one you want to activate. An **OK** confirms the choice and the window closes automatically.

### ⌨️ Commands

- `/gather` — show or hide the window.
- `/gr` — short alias.
- `/grem` — short alias.
- `/gather reset` — clear all 3 slots.
- `/gather center` — recenter the window.
- `/gather help` — display help.

### ⚙️ Saved data & settings

Skills and window position are saved **per character**. GatherReminder uses its own Lua data apartment so it stays isolated from other plugins.

### 🌍 Languages

The interface is available in **English, French and German** and automatically follows the LOTRO client language.

### ⚠️ Limitations / notes

The LOTRO Lua API cannot reliably confirm whether a tracking skill is currently active. The plugin therefore uses your click in the reminder window as confirmation.

### 🐛 Bugs & suggestions

Use [GitHub Issues](https://github.com/Dusk-92/GatherReminder/issues).

### 🙏 Credits

Development and maintenance: **Dusk-92**.

---

## 🇩🇪 Deutsch

### 📖 Übersicht

**GatherReminder** zeigt ein kleines Erinnerungsfenster für die Suchfertigkeiten der Sammelberufe. Pro Charakter können bis zu **3 Suchfertigkeiten** gespeichert werden.

### ✨ Funktionen

- Bis zu 3 gespeicherte Suchfertigkeiten pro Charakter.
- Auswahl einer Suchfertigkeit, sobald die Erinnerung erscheint.
- Gespeicherte Fensterposition.
- Rechtsklick auf ein Feld, um es zu leeren.
- **Später** schließt die Erinnerung vorübergehend.
- Erinnerung nach einer Solo-Wiederbelebung.
- Keine automatische Einblendung nach einer Niederlage in Gruppe oder Schlachtzug.
- Falls der Charakter noch im Kampf ist, wartet die Erinnerung bis zum Kampfende.
- Oberfläche auf FR / EN / DE.

### 📦 Installation

Den Ordner **Dusk** aus der Release nach folgendem Pfad kopieren:

```text
Documents\The Lord of the Rings Online\Plugins\
```

Danach im Spiel:

```text
/plugins refresh
```

Anschließend **GatherReminder** im LOTRO-Plugin-Manager laden.

### 🎮 Verwendung

Beim ersten Start bis zu 3 Suchfertigkeiten in die Felder ziehen. Wenn die Erinnerung erscheint, die gewünschte Fertigkeit anklicken. **OK** bestätigt die Auswahl und das Fenster schließt sich automatisch.

### ⌨️ Befehle

- `/gather` — Fenster anzeigen oder ausblenden.
- `/gr` — kurzer Alias.
- `/grem` — kurzer Alias.
- `/gather reset` — alle 3 Felder leeren.
- `/gather center` — Fenster zentrieren.
- `/gather help` — Hilfe anzeigen.

### ⚙️ Gespeicherte Daten & Einstellungen

Fertigkeiten und Fensterposition werden **pro Charakter** gespeichert. GatherReminder verwendet einen eigenen Lua-Datenbereich und bleibt damit von anderen Plugins getrennt.

### 🌍 Sprachen

Die Oberfläche ist auf **Deutsch, Englisch und Französisch** verfügbar und folgt automatisch der Sprache des LOTRO-Clients.

### ⚠️ Einschränkungen / Hinweise

Die LOTRO-Lua-API kann nicht zuverlässig prüfen, ob eine Suchfertigkeit wirklich aktiv ist. Deshalb gilt der Klick im Erinnerungsfenster als Bestätigung.

### 🐛 Fehler & Vorschläge

Bitte die [GitHub Issues](https://github.com/Dusk-92/GatherReminder/issues) verwenden.

### 🙏 Credits

Entwicklung und Wartung: **Dusk-92**.
