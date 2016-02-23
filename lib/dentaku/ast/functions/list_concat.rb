require_relative '../function'

Dentaku::AST::Function.register(:concat_list, :list, ->(*args) {
  args.inject(&:concat)
})
