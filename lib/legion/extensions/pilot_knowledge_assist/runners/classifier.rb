# frozen_string_literal: true

module Legion
  module Extensions
    module PilotKnowledgeAssist
      module Runners
        module Classifier
          VALID_INTENTS = %i[doc_question ops_request greeting out_of_scope].freeze

          CLASSIFY_PROMPT = <<~PROMPT
            Classify this message into exactly one category. Reply with ONLY the category name:
            - doc_question (asking about documentation, how-to, configuration, architecture)
            - ops_request (asking to perform an action, run a command, make a change)
            - greeting (hello, hi, thanks, goodbye)
            - out_of_scope (weather, sports, personal questions, unrelated topics)

            Message: %<message>s
          PROMPT

          def classify_intent(message:)
            return { intent: :doc_question, method: :default } unless llm_available?

            prompt = format(CLASSIFY_PROMPT, message: message)
            response = Legion::LLM.chat(message: prompt, # rubocop:disable Legion/HelperMigration/DirectLlm
                                        caller:  { extension: 'lex-pilot-knowledge-assist',
                                                   function:  'classify_intent' })
            intent = response.to_s.strip.downcase.to_sym
            intent = :doc_question unless VALID_INTENTS.include?(intent)

            { intent: intent, method: :llm }
          rescue StandardError => _e
            { intent: :doc_question, method: :fallback }
          end

          private

          def llm_available?
            defined?(Legion::LLM) && Legion::LLM.respond_to?(:started?) && Legion::LLM.started?
          end
        end
      end
    end
  end
end
