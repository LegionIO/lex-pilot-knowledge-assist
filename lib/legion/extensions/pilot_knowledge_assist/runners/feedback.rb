# frozen_string_literal: true

module Legion
  module Extensions
    module PilotKnowledgeAssist
      module Runners
        module Feedback
          VALID_RATINGS = %i[positive negative].freeze

          def record_feedback(question:, answer:, rating:, user_id: nil)
            rating = rating.to_sym
            return { success: false, reason: :invalid_rating } unless VALID_RATINGS.include?(rating)

            entry = { question: question, answer: answer, rating: rating,
                      user_id: user_id, timestamp: Time.now }
            feedback_store << entry

            store_to_apollo(question: question, answer: answer) if rating == :positive

            { success: true, rating: rating }
          end

          def feedback_stats
            total = feedback_store.size
            positive = feedback_store.count { |e| e[:rating] == :positive }
            negative = total - positive

            { total: total, positive: positive, negative: negative,
              accuracy: total.positive? ? positive.to_f / total : 0.0 }
          end

          private

          def feedback_store
            @feedback_store ||= []
          end

          def store_to_apollo(question:, answer:)
            return unless defined?(Legion::Extensions::Apollo::Client)

            Legion::Extensions::Apollo::Client.new.handle_ingest(
              content: "Q: #{question}\nA: #{answer}",
              content_type: 'qa_pair',
              confidence: 0.5,
              tags: %w[knowledge_assist qa_pair]
            )
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
