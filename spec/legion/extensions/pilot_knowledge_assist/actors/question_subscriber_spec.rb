# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::PilotKnowledgeAssist::Actors::QuestionSubscriber do
  describe 'actor configuration' do
    it 'uses the correct runner class' do
      expect(described_class.new.runner_class).to eq(
        'Legion::Extensions::PilotKnowledgeAssist::Runners::Assistant'
      )
    end

    it 'uses answer_question as the runner function' do
      expect(described_class.new.runner_function).to eq('answer_question')
    end

    it 'disables subtask checking' do
      expect(described_class.new.check_subtask?).to be false
    end

    it 'disables task generation' do
      expect(described_class.new.generate_task?).to be false
    end

    it 'disables runner lookup' do
      expect(described_class.new.use_runner?).to be false
    end
  end
end
