# Rachio Winterizer

Blow out your sprinkler lines with an air compressor while your Rachio controller cycles through the zones for you. Set the on time, the compressor rest and the number of passes, then grab a chair.

A single HTML file that runs entirely in your browser. No server, no install, no build step.

> Forked from [AlexOnAPeak/rachio-winterizer](https://github.com/AlexOnAPeak/rachio-winterizer). Thanks to Alex for the original idea and app.
> Not affiliated with or endorsed by Rachio.

## Quick start

1. Download `index.html` (**Code → Download ZIP**, or open the file and click **Download raw file**).
2. Open it in **Edge, Chrome or Firefox**: right-click → *Open with*. Preview panes (Outlook, File Explorer, OneDrive or SharePoint in a browser) block the page's script. If you see a red "script isn't running" banner, that's why.
3. Either:
   - **🧪 Test this out:** a pretend two-controller account. Nothing is sent to Rachio, and time runs 60× faster. Good for poking around.
   - **Connect:** paste your Rachio API key (app.rach.io → account settings → *Get API Key*).

## How a run works

```
Pass 1: Zone 1 on → rest → (repeat for bursts) → Zone 2 on → rest → … → last zone
Pass 2: same zones, shorter on time
…
Final rest is skipped; a "stop all watering" command is always sent at the end.
```

| Setting | Default | Range | Notes |
|---|---|---|---|
| Zone on time | 60 s | 5–180 s | Valve open time per burst. Running dry heats the fittings. |
| Compressor rest | 180 s | 0–1800 s | All valves closed while the tank refills. Happens after every burst. |
| Bursts per zone | 1 | 1–10 | On/rest bursts a zone gets before moving on. |
| Whole-system passes | 4 | 1–4 | Full trips through every selected zone. |
| On time per pass | 100 / 75 / 50 / 25 % | 10–100 % | Tapers each pass. With 60 s that's 60 / 45 / 30 / 15 s. |

**Example:** 15 zones at the defaults is 60 zone runs and about 3 h 34 m in total. The page shows the estimate, a live "zone X of N, done around 3:55 PM" readout, the progress in the browser tab title, and a chime when it finishes.

Run stays locked until the **pre-flight checklist** is ticked: water off, regulator about 50 PSI or less for PVC (about 80 for poly), air downstream of the backflow preventer, eye protection on, and driveway beer in hand.

## Safety and reliability

- **STOP is instant.** It cuts any wait short and cancels any request in progress. `Esc` does the same.
- **A stop command always goes out.** A "stop all watering" command is sent when a run finishes, is stopped, or errors out.
- **Only one run at a time.** Double-clicks and stop-then-rerun can't start a second loop.
- **Bad runs abort.** Three failures in a row, a rejected key (401) or a rate limit (429) stops the run.
- **Each burst's on time is enforced by the controller**, through the duration sent with every zone start. If the laptop sleeps, the worst case is longer rests, never longer airflow.
- **The screen is kept awake where the browser allows it** (Wake Lock API), and you're warned before closing the tab mid-run.

## Security

- **Only talks to Rachio.** A strict Content Security Policy lets the page connect only to `https://api.rach.io` and run only its own inline script and style, which are pinned by SHA-256 hash. If anything modifies the code, the browser refuses to run it.
- **Your API key controls your whole Rachio account.** It's masked by default and **not saved** unless you tick *Remember*, and there's a *Forget saved key* button. Only use a copy of this file that you downloaded and can read yourself.
- **No outside scripts, fonts, images or tracking.** It runs fine with no internet connection except for the calls to Rachio.

### Editing the file

Any change inside `<script>` or `<style>` changes its hash, and the page will refuse to run until the CSP is updated. After editing, run:

```powershell
pwsh ./tools/update-csp.ps1          # or: powershell -File .\tools\update-csp.ps1
```

## Changes from the original

- **Fixed:** the loop could run forever if the last zone failed to start.
- **Fixed:** stopping and re-running quickly could leave two loops running at once.
- **Fixed:** Stop waited out the current wait instead of acting immediately.
- **Fixed:** blank or out-of-range numbers slipped past validation.
- **Added:** Content Security Policy, a masked API key that's only saved if you opt in, request timeouts, and error messages with the HTTP status.
- **Added:** bursts per zone, the per-pass taper, the pre-flight checklist, live ETA and tab title, a finish chime, and the wake lock.
- **Added:** demo mode, a warning when the script is blocked, keyboard and screen-reader improvements, and a mobile layout.

## License

The upstream project doesn't currently include a license, so this fork doesn't add one. All rights to the original code remain with its author.
