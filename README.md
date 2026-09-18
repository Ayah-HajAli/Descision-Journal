# Decision Journal

Before an important decision, write down what you believe will happen.
The prediction is **sealed** until a reveal date you choose. Once that
date passes, you open it, log what actually happened, and mark whether
you were right, wrong, or partly right — building an honest track
record of your own judgment over time.

## Concept → screens

- **Home** — a timeline of decisions. Sealed ones show a lock icon and
  a countdown; ones ready to open are flagged "REVEAL NOW"; resolved
  ones are color-coded (green = right, coral = wrong, violet = partly
  right).
- **New decision** — title, category, your prediction, a confidence
  slider, and the date it unlocks.
- **Sealed view** — the prediction itself is blurred behind a frosted
  panel until the reveal date, reinforcing "no peeking." If you
  recorded a video with the decision, it shows as a locked tile too —
  no playback until reveal.
- **Reveal flow** — once due, the prediction unblurs, the video
  becomes watchable, and you record what really happened, then choose
  an outcome.
- **Resolved view** — prediction vs. reality side by side (with your
  video, if you recorded one), and the final verdict front and center.

## Design language

Colors and the scalloped card edges are carried over from the
reference "Academy" story-card UI: flat saturated color blocks, a
rounded bold display font (Fredoka) for headlines, and a repeating
half-circle wave as the signature shape motif — used here as the
"seal" visual metaphor as well as a plain divider.

## Running it

This is a standard Flutter project. Video recording needs one extra
setup step — see **`PERMISSIONS.md`** for the two-minute camera/mic
permission setup on Android and iOS before your first `flutter run`.

```bash
flutter create .        # generates android/ ios/ around the existing lib/
# then add the permissions in PERMISSIONS.md
flutter pub get
flutter run
```

All data currently lives in memory (`lib/data/store.dart`), seeded
with a few example decisions (some sealed, some already resolved) so
the app isn't empty on first launch. Swap `DecisionStore` for a
persisted version (e.g. backed by `sqflite`, `hive`, or a backend) to
keep data between sessions — the rest of the UI doesn't need to
change.

## Structure

```
lib/
  main.dart
  theme/app_theme.dart        # colors + text theme
  models/decision.dart        # Decision, DecisionStatus, DecisionCategory
  data/store.dart             # in-memory ChangeNotifier store
  widgets/
    scallop_edge.dart         # scallop clipper + divider
    logo_pill.dart            # small pill badge + header wordmark
    decision_card.dart        # home timeline card
  screens/
    home_screen.dart
    new_decision_screen.dart
    detail_screen.dart        # sealed / reveal / resolved views
```
