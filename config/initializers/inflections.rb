# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
  inflect.irregular "cotacao", "cotacoes"
  inflect.irregular 'fornecedor_categoria', 'fornecedor_categorias'
  inflect.irregular 'item_de_cotacao', 'itens_de_cotacao'
  inflect.irregular 'produto_customizado', 'produtos_customizados'
  inflect.irregular 'resposta_de_cotacao', 'respostas_de_cotacao'
  inflect.irregular 'usuario', 'usuarios'
  inflect.irregular 'categoria', 'categorias'
  inflect.irregular 'subcategoria', 'subcategorias'
  inflect.irregular 'fornecedor', 'fornecedores'
  inflect.irregular 'fornecedor_categoria', 'fornecedor_categorias'
  inflect.irregular 'produto', 'produtos'
  inflect.irregular 'resposta_de_cotacao', 'respostas_de_cotacao'
  inflect.irregular 'item_de_cotacao', 'itens_de_cotacao'
  inflect.irregular 'produto_customizado', 'produtos_customizados'
#   inflect.uncountable %w( fish sheep )
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
