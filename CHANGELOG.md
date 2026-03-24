# Changelog

## [0.1.3] - 2026-03-23

### Changed
- route llm calls through pipeline when available, add caller identity for attribution

## [0.1.2] - 2026-03-23

### Changed
- Derive confidence from actual Apollo entry scores (max of returned confidence values) instead of hardcoded 0.8/0.3
- Added `derive_confidence` helper: returns max score when entries have confidence, 0.6 fallback for entries without scores, 0.3 for empty context

## [0.1.1] - 2026-03-22

### Changed
- Add legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, and legion-transport as runtime dependencies
- Update spec_helper with real sub-gem helper stubs replacing manual Legion::Logging and Legion::Settings mocks

## [0.1.0] - 2026-03-21

### Added
- `Runners::Assistant` with `answer_question` method for RAG-based knowledge answering
- Apollo context retrieval integration for knowledge-grounded responses
- Confidence scoring based on context availability (0.8 with context, 0.3 without)
- Source tracking from Apollo knowledge entries
- Full RSpec test coverage (9 specs)
