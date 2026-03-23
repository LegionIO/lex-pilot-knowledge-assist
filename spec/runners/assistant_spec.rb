# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::PilotKnowledgeAssist::Runners::Assistant do
  let(:assistant) { Class.new { include Legion::Extensions::PilotKnowledgeAssist::Runners::Assistant }.new }

  describe '#answer_question' do
    context 'when no context is found' do
      before do
        allow(assistant).to receive(:retrieve_context).and_return([])
        allow(assistant).to receive(:generate_answer).and_return('general answer')
      end

      it 'returns answer structure with question echoed back' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:question]).to eq('What is Legion?')
        expect(result[:answer]).to eq('general answer')
      end

      it 'reports low confidence' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:confidence]).to eq(0.3)
      end

      it 'returns empty sources' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:sources]).to eq([])
      end
    end

    context 'when context is found from Apollo with confidence scores' do
      let(:context_entries) do
        [
          { id: 1, content: 'Legion is an async job engine', confidence: 0.9 },
          { id: 7, content: 'Legion uses RabbitMQ for messaging', confidence: 0.7 }
        ]
      end

      before do
        allow(assistant).to receive(:retrieve_context).and_return(context_entries)
        allow(assistant).to receive(:generate_answer).and_return('Legion is an async job engine using RabbitMQ')
      end

      it 'derives confidence from max Apollo entry score' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:confidence]).to eq(0.9)
      end

      it 'includes source ids' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:sources]).to eq([1, 7])
      end

      it 'returns the generated answer' do
        result = assistant.answer_question(question: 'What is Legion?')
        expect(result[:answer]).to eq('Legion is an async job engine using RabbitMQ')
      end
    end

    context 'when context entries lack confidence scores' do
      before do
        allow(assistant).to receive(:retrieve_context).and_return(
          [{ id: 42, content: 'Extensions are gems named lex-*' }]
        )
        allow(assistant).to receive(:generate_answer).and_return('Extensions are lex-* gems')
      end

      it 'returns fallback confidence of 0.6' do
        result = assistant.answer_question(question: 'What are extensions?')
        expect(result[:confidence]).to eq(0.6)
      end

      it 'includes the single source id' do
        result = assistant.answer_question(question: 'What are extensions?')
        expect(result[:sources]).to eq([42])
      end
    end

    context 'with custom agent_id' do
      before do
        allow(assistant).to receive(:retrieve_context).and_return([])
        allow(assistant).to receive(:generate_answer).and_return('answer')
      end

      it 'passes agent_id through and returns result' do
        result = assistant.answer_question(question: 'test', agent_id: 'custom-agent')
        expect(result[:question]).to eq('test')
      end
    end
  end
end
