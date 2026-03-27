# frozen_string_literal: true

module Legion
  module Extensions
    module PilotKnowledgeAssist
      module Actor
        class QuestionSubscriber < Legion::Extensions::Actors::Subscription
          def runner_class
            'Legion::Extensions::PilotKnowledgeAssist::Runners::Assistant'
          end

          def runner_function
            'answer_question'
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end

          def use_runner?
            false
          end
        end
      end
    end
  end
end
