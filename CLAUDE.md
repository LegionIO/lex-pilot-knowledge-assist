# lex-pilot-knowledge-assist

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

RAG-based knowledge assistant pilot extension for LegionIO. Answers natural language questions by retrieving relevant context from `lex-apollo` and generating answers via `legion-llm`. Demonstrates the Apollo + LLM retrieval-augmented generation pattern.

## Gem Info

- **Gem name**: `lex-pilot-knowledge-assist`
- **Version**: `0.2.0`
- **Module**: `Legion::Extensions::PilotKnowledgeAssist`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/pilot_knowledge_assist/
  version.rb
  runners/
    assistant.rb   # answer_question(question:, agent_id:)
spec/
  runners/
    assistant_spec.rb
```

## Runner: `Runners::Assistant`

### `answer_question(question:, agent_id: 'knowledge-assist')`

Two-step RAG pipeline:

1. **Retrieve context** (`retrieve_context`): calls `Legion::Extensions::Apollo::Client.new(agent_id: agent_id).query_knowledge(query: question, limit: 5)` if `lex-apollo` is loaded. Returns `[]` on failure or when Apollo is unavailable.
2. **Generate answer** (`generate_answer`): calls `Legion::LLM.chat(message: prompt)` where prompt is either the raw question (no context) or context-augmented. Returns `'LLM unavailable'` if `legion-llm` is not defined.

Returns:
```ruby
{
  question: '...',
  answer:   '...',
  sources:  [entry_id, ...],   # IDs from Apollo context entries
  confidence: 0.8 | 0.3        # 0.8 when context found, 0.3 when no context
}
```

## Integration Points

- **lex-apollo** (`extensions-agentic/`): context retrieval via `Client#query_knowledge`
- **legion-llm** (core lib): answer generation via `LLM.chat`

Both dependencies are guarded with `defined?()` — the runner returns degraded responses when either is unavailable.

## Development Notes

- This is a pilot extension — it demonstrates the RAG pattern but is not production-hardened
- Confidence is binary (0.8 with context, 0.3 without) — a production implementation would compute this from Apollo's returned confidence scores
- `retrieve_context` rescues `StandardError` and returns `[]` to prevent LLM call failures from propagating
- No actor — this is purely request-driven (invoked via AMQP task or standalone client)
