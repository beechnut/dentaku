module Dentaku
  module AST
    class Negation < Operation
      def initialize(node)
        @node = node
        fail "Negation requires numeric operand" unless valid_node?(node)
      end

      def value(context={})
        @node.value(context) * -1
      end

      def type
        :numeric
      end

      def generate_constraints(context)
        context.add_constraint!([:syntax, self], [:concrete, :bool], [:operator, self, :return])
        context.add_constraint!([:syntax, @node], [:concrete, :bool], [:operator, self, :left])
        @node.generate_constraints(context)
      end

      def pretty_print
        "(! #{@node.pretty_print})"
      end

      def self.arity
        1
      end

      def self.right_associative?
        true
      end

      def self.precedence
        40
      end

      def dependencies(context={})
        @node.dependencies(context)
      end

      private

      def valid_node?(node)
        node.dependencies.any? || node.type == :numeric
      end
    end
  end
end
