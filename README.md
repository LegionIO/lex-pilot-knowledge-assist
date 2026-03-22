# lex-pilot-knowledge-assist

RAG-based knowledge assistant using Apollo and LLM for LegionIO.

## Usage

```ruby
assistant = Class.new { include Legion::Extensions::PilotKnowledgeAssist::Runners::Assistant }.new

result = assistant.answer_question(question: 'How do I create a new extension?')
# => { question: '...', answer: '...', sources: [1, 7], confidence: 0.8 }
```

When Apollo context is available, the assistant retrieves relevant knowledge entries and includes them as context for the LLM. Confidence is 0.8 with context, 0.3 without.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```
