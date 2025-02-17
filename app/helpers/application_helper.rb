module ApplicationHelper

  def nome_para_exibir(produto)
    return produto.nome unless current_usuario&.papel == 'cliente'
    custom = ProdutoCustomizado.find_by(cliente_id: current_usuario.id, produto_id: produto.id)
    custom ? custom.nome_customizado : produto.nome
  end

end
