# frozen_string_literal: true

module Legion
  module Extensions
    module PilotKnowledgeAssist
      module Runners
        module Assistant
          include Classifier

          DISCLAIMER_THRESHOLD = 0.5
          ESCALATION_THRESHOLD = 0.2
          DISCLAIMER_PREFIX = "I'm not fully certain about this answer -- please verify:\n\n"
          INTENT_ANSWERS = {
            greeting: 'Hello! I can help with Grid documentation and support questions.',
            out_of_scope: 'I can only help with Grid infrastructure and documentation questions.',
            ops_request: 'I can answer documentation questions but cannot perform operations. ' \
                         'Please contact the Grid team.'
          }.freeze

          def answer_question(question:, agent_id: 'knowledge-assist')
            intent_response = classify_and_route(question: question)
            return intent_response if intent_response

            context_entries = retrieve_context(question: question, agent_id: agent_id)
            confidence = derive_confidence(context_entries)

            if confidence < ESCALATION_THRESHOLD
              escalate(question: question, confidence: confidence)
              return { question: question, answer: 'This question has been escalated to the support team.',
                       sources: [], confidence: confidence, escalated: true, flagged: true }
            end

            answer = generate_answer(question: question, context: context_entries)
            flagged = confidence < DISCLAIMER_THRESHOLD
            final_answer = flagged ? "#{DISCLAIMER_PREFIX}#{answer}" : answer

            { question: question, answer: final_answer, sources: context_entries.map { |e| e[:id] },
              confidence: confidence, flagged: flagged, escalated: false }
          end

          private

          def classify_and_route(question:)
            classification = classify_intent(message: question)
            intent = classification[:intent]
            answer = INTENT_ANSWERS[intent]
            return unless answer

            { question: question, answer: answer, intent: intent,
              confidence: 1.0, sources: [], flagged: false, escalated: false }
          end

          def derive_confidence(context)
            return 0.3 if context.empty?

            scores = context.filter_map { |c| c[:confidence] }
            return 0.6 if scores.empty?

            scores.max.clamp(0.1, 1.0)
          end

          def retrieve_context(question:, agent_id:)
            return [] unless defined?(Legion::Extensions::Apollo::Client)

            client = Legion::Extensions::Apollo::Client.new(agent_id: agent_id)
            client.query_knowledge(query: question, limit: 5)
          rescue StandardError
            []
          end

          def generate_answer(question:, context:)
            return 'LLM unavailable' unless defined?(Legion::LLM)

            context_text = context.map { |c| c[:content] }.join("\n\n")
            prompt = if context_text.empty?
                       question
                     else
                       "Context:\n#{context_text}\n\nQuestion: #{question}"
                     end

            result = Legion::LLM.chat(message: prompt, caller: { extension: 'lex-pilot-knowledge-assist' })
            result.is_a?(Hash) ? result[:content] : result.to_s
          rescue StandardError => e
            "Error: #{e.message}"
          end

          def escalate(question:, confidence:)
            return unless defined?(Legion::Extensions::Slack::Client)

            webhook = escalation_webhook
            return unless webhook

            message = "Knowledge assist escalation:\n*Question:* #{question}\n*Confidence:* #{confidence}"
            Legion::Extensions::Slack::Client.new.send_webhook(message: message, webhook: webhook)
          rescue StandardError => e
            Legion::Logging::Logger.warn("Escalation failed: #{e.message}") if defined?(Legion::Logging)
          end

          def escalation_webhook
            return nil unless defined?(Legion::Settings)

            config = Legion::Settings[:pilot_knowledge_assist] || {}
            config[:escalation_webhook]
          end
        end
      end
    end
  end
end
