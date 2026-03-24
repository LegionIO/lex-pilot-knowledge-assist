# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::PilotKnowledgeAssist::Runners::Feedback do
  subject { Object.new.extend(described_class) }

  describe '#record_feedback' do
    it 'stores positive feedback' do
      result = subject.record_feedback(question: 'How?', answer: 'Like this', rating: :positive)
      expect(result[:success]).to be true
      expect(result[:rating]).to eq(:positive)
    end

    it 'stores negative feedback' do
      result = subject.record_feedback(question: 'How?', answer: 'Wrong', rating: :negative)
      expect(result[:success]).to be true
      expect(result[:rating]).to eq(:negative)
    end

    it 'rejects invalid ratings' do
      result = subject.record_feedback(question: 'How?', answer: 'x', rating: :maybe)
      expect(result[:success]).to be false
    end
  end

  describe '#feedback_stats' do
    before do
      subject.record_feedback(question: 'a', answer: 'b', rating: :positive)
      subject.record_feedback(question: 'c', answer: 'd', rating: :positive)
      subject.record_feedback(question: 'e', answer: 'f', rating: :negative)
    end

    it 'returns counts and accuracy rate' do
      stats = subject.feedback_stats
      expect(stats[:total]).to eq(3)
      expect(stats[:positive]).to eq(2)
      expect(stats[:negative]).to eq(1)
      expect(stats[:accuracy]).to be_within(0.01).of(0.667)
    end
  end
end
