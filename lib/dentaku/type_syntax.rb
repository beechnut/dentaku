require 'strscan'
require 'dentaku/type_expression'

module Dentaku
  module TypeSyntax
    def self.parse(string)
      # p Token.tokenize(string).to_a
      Parser.parse(Token.tokenize(string))
    end

    class Token
      attr_reader :name, :value
      def initialize(name, value=nil)
        @name = name
        @value = value
      end

      def inspect
        if @value
          ":#{@name}(#{@value})"
        else
          ":#{@name}"
        end
      end

      def self.tokenize(string, &b)
        return enum_for(:tokenize, string) unless block_given?

        scanner = StringScanner.new(string)

        until scanner.eos?
          if scanner.scan /[=]/
            yield new(:EQ)
          elsif scanner.scan /[(]/
            yield new(:LPAREN)
          elsif scanner.scan /[)]/
            yield new(:RPAREN)
          elsif scanner.scan /\[/
            yield new(:LBRACE)
          elsif scanner.scan /\]/
            yield new(:RBRACE)
          elsif scanner.scan /%(\w+)/
            yield new(:VAR, scanner[1])
          elsif scanner.scan /:(\w+)/
            yield new(:PARAM, scanner[1])
          elsif scanner.scan /\w+/
            yield new(:NAME, scanner[0])
          elsif scanner.scan /[\s,]+/
            # pass
          else
            raise "invalid thing!"
          end
        end

        yield new(:EOF)
      end
    end

    class TypeSpec
      attr_reader :name, :arg_types, :return_type
      def initialize(name, arg_types, return_type)
        @name = name
        @arg_types = arg_types
        @return_type = return_type
      end
    end

    class Parser
      def self.parse(tokens)
        new(tokens).parse
      end

      def initialize(tokens)
        @tokens = tokens
        @head = @tokens.next
      end

      def next!
        @head = @tokens.next
      end

      def check(toktype)
        return @head.name == toktype
      end

      def check!(toktype)
        out = check(toktype)
        next! if out
        out
      end

      def check_val(toktype)
        return @head.value if check(toktype)
      end

      def check_val!(toktype)
        @head.value.tap { next! } if check(toktype)
      end

      def expect(toktype)
        if check(toktype)
          @head.value
        else
          binding.pry # raise "parse error: expected #{toktype.inspect}, got #{@head.inspect}"
        end
      end

      def expect!(toktype)
        expect(toktype).tap { next! }
      end

      def parse
        function_name = expect!(:NAME)
        expect!(:LPAREN)
        arg_types = parse_types(:RPAREN)
        expect!(:EQ)
        return_type = parse_type
        expect(:EOF)

        TypeSpec.new(function_name, arg_types, return_type)
      end

      def parse_type
        if (name = check_val!(:VAR))
          TypeExpression.var(name)
        elsif (param_name = check_val!(:PARAM))
          if check!(:LPAREN)
            member_types = parse_types(:RPAREN)
            TypeExpression.param(param_name.to_sym, member_types)
          else
            TypeExpression.concrete(param_name)
          end
        elsif check!(:LBRACE)
          list_type = parse_type
          expect!(:RBRACE)
          TypeExpression.param(:list, [list_type])
        else
          raise "invalid type expression starting with #{@head.inspect}"
        end
      end

      def parse_types(expected_end)
        arg_types = []
        until check(expected_end)
          arg_types << parse_type
        end
        expect!(expected_end)

        arg_types
      end
    end
  end
end