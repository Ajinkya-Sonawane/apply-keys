# apply-keys
Keyboard for applying jobs while on the go from your phone.

**ApplyKeys** is an iOS snippet keyboard: switch to it with 🌐 while filling a job application (LinkedIn, Greenhouse, Lever, Workday…), tap a labelled button, and your saved text — links, contact details, answers to common questions — is inserted into the field exactly as saved. Spec: [#1](https://github.com/Ajinkya-Sonawane/apply-keys/issues/1).

## Layout

| Folder | What it is |
| --- | --- |
| `ApplyKeysCore/` | Swift package with all the logic: `SnippetStore` (add/edit/delete/reorder, persisted as JSON) and `KeyboardController` (panel state and key handling). Fully tested. |
| `ApplyKeys/` | SwiftUI companion app for managing snippets in the Me / Links / Answers tabs, plus setup instructions. |
| `Keyboard/` | The keyboard extension: a snippet panel with 🌐, space, ⌫ and ⏎. |
| `Config/` | Keyboard Info.plist and App Group entitlements. |

The app and keyboard share data through the App Group `group.com.ajinkyasonawane.ApplyKeys`. The keyboard needs **Allow Full Access** to read it. There is no network code.

## Run on your iPhone

1. Open `ApplyKeys.xcodeproj` in Xcode.
2. For both the **ApplyKeys** and **Keyboard** targets, under *Signing & Capabilities*, pick your team. If the bundle IDs or App Group are taken, change them (and `AppGroup.identifier` in `ApplyKeysCore`) to match.
3. Run the **ApplyKeys** scheme on your phone.
4. On the phone: Settings → General → Keyboard → Keyboards → Add New Keyboard → ApplyKeys, then tap it and turn on **Allow Full Access**.

## Tests

```bash
cd ApplyKeysCore && swift test
```
