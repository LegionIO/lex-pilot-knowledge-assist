# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::PilotKnowledgeAssist::Runners::Classifier do
  subject { Object.new.extend(described_class) }

  describe '#classify_intent' do
    context 'when LLM is available' do
      before do
        stub_const('Legion::LLM', double('LLM', started?: true))
      end

      it 'returns doc_question for a documentation query' do
        allow(Legion::LLM).to receive(:chat).and_return('doc_question')
        result = subject.classify_intent(message: 'How do I set up a Vault namespace?')
        expect(result[:intent]).to eq(:doc_question)
      end

      it 'returns greeting for a greeting' do
        allow(Legion::LLM).to receive(:chat).and_return('greeting')
        result = subject.classify_intent(message: 'Hello!')
        expect(result[:intent]).to eq(:greeting)
      end

      it 'returns out_of_scope for unrelated questions' do
        allow(Legion::LLM).to receive(:chat).and_return('out_of_scope')
        result = subject.classify_intent(message: 'What is the weather today?')
        expect(result[:intent]).to eq(:out_of_scope)
      end
    end

    context 'when LLM is not available' do
      it 'defaults to doc_question' do
        result = subject.classify_intent(message: 'anything')
        expect(result[:intent]).to eq(:doc_question)
      end
    end
  end
end
