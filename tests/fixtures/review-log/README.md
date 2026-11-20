Three pages copied from revvu/treadmill's `tests/fixtures/review-log/`, which every copy of the Reader review check answers the same way:
this repo's `bin/lavish-review-gate` (frozen by `tests/lavish-review-gate.bats`), and Treadmill's `treadmill/review_log.py` and `web/store.ts`.
mark-only and summary-only carry a review; neither does not.
Keep them byte-for-byte equal to Treadmill's copies.
