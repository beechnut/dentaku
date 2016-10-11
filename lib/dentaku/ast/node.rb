module Dentaku
  module AST
    class Node
      # type annotation to be added later
      # by the type checker
      attr_accessor :type
      attr_accessor :begin_token
      attr_accessor :end_token

      def self.precedence
        0
      end

      def self.arity
        arity = instance_method(:initialize).arity
        arity < 0 ? nil : arity
      end

      def dependencies(context={})
        []
      end

      def constraints(context)
        generate_constraints(context)
        context.constraints
      end

      def loc_range
        [begin_token.begin_location, end_token.end_location]
      end

      def generate_constraints(context)
        raise "Abstract #{self.class.name}"
      end

      def repr
        "(TODO #{self.class.name})"
      end

      def inspect
        "<AST #{repr}>"
      end

      def evaluate
        Calculator.current.trace(self) do
          value
        end
      end

      protected

      def value
        raise 'abstract'
      end

    end
  end
end
