# frozen_string_literal: true

require_relative 'lib/legion/extensions/pilot_knowledge_assist/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-pilot-knowledge-assist'
  spec.version       = Legion::Extensions::PilotKnowledgeAssist::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX::PilotKnowledgeAssist'
  spec.description   = 'RAG-based knowledge assistant using Apollo and LLM for LegionIO'
  spec.homepage      = 'https://github.com/LegionIO'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']
end
