# frozen_string_literal: true

module Legion
  module Extensions
    module PilotKnowledgeAssist
      module Runners
        module Assistant
          def answer_question(question:, agent_id: 'knowledge-assist')
            context = retrieve_context(question, agent_id)
            answer = generate_answer(question, context)

            {
              question: question,
              answer: answer,
              sources: context.map { |c| c[:id] },
              confidence: derive_confidence(context)
            }
          end

          private

          def derive_confidence(context)
            return 0.3 if context.empty?

            scores = context.filter_map { |c| c[:confidence] }
            return 0.6 if scores.empty?

            scores.max.clamp(0.1, 1.0)
          end

          def retrieve_context(question, agent_id)
            return [] unless defined?(Legion::Extensions::Apollo::Client)

            client = Legion::Extensions::Apollo::Client.new(agent_id: agent_id)
            client.query_knowledge(query: question, limit: 5)
          rescue StandardError
            []
          end

          def generate_answer(question, context)
            return 'LLM unavailable' unless defined?(Legion::LLM)

            context_text = context.map { |c| c[:content] }.join("\n\n")
            prompt = if context_text.empty?
                       question
                     else
                       "Context:\n#{context_text}\n\nQuestion: #{question}"
                     end

            result = Legion::LLM.chat(message: prompt)
            result[:content]
          rescue StandardError => e
            "Error: #{e.message}"
          end
        end
      end
    end
  end
end
