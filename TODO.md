## TODO - Quran Surah Player Slider Fix

- [ ] Update `QuranSurahPlayerController`:
  - [ ] Add cached prefix durations for current batch to compute `totalPosition` efficiently.
  - [ ] Fix `_syncPlaybackProgress` to avoid repeated heavy calculations and guard against double state updates.
  - [ ] Ensure `currentAyah` updates only when index changes.
  - [ ] Ensure `totalDuration` is computed once from the 5 loaded ayahs.

- [ ] Update `QuranSurahPlayerScreen` seek bar widget:
  - [ ] Remove elapsed/remaining time display.
  - [ ] Show current ayah number text from `playerState.currentAyah`.
  - [ ] Keep Slider value/max based on `totalPosition/totalDuration`.

- [ ] Verification:
  - [ ] Hot restart and verify Slider movement.
  - [ ] Verify seeking updates current ayah text correctly.
  - [ ] Verify max value uses current batch total duration.

