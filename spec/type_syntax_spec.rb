require 'dentaku/type_syntax'
require 'pry'

describe Dentaku::TypeSyntax do
  it 'tokenizes' do
    tokens = Dentaku::TypeSyntax::Token.tokenize('foo bar :baz()').to_a

    expect(tokens[0].name).to eql(:NAME)
    expect(tokens[0].value).to eql('foo')

    expect(tokens[1].name).to eql(:NAME)
    expect(tokens[1].value).to eql('bar')

    expect(tokens[2].name).to eql(:PARAM)
    expect(tokens[2].value).to eql('baz')

    expect(tokens[3].name).to eql(:LPAREN)
    expect(tokens[4].name).to eql(:RPAREN)
  end

  it 'parses' do
    expr = Dentaku::TypeSyntax.parse('foo(:numeric) = :bool')
    expect(expr.name).to eql('foo')
    expect(expr.arg_types.size).to be 1
    expect(expr.arg_types[0].pretty_print).to eql(':numeric')
    expect(expr.return_type.pretty_print).to eql(':bool')
  end
end