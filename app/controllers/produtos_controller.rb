class ProdutosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_admin, except: [:index, :show]

  def index
    @produtos = Produto.all
    # Se for um cliente logado, vamos buscar nomes customizados e mesclar na exibição
  end

  def show
    @produto = Produto.find(params[:id])
  end

  def new
    @produto = Produto.new
  end

  def create
    @produto = Produto.new(produto_params)
    if @produto.save
      redirect_to @produto, notice: "Produto criado com sucesso."
    else
      render :new
    end
  end

  def edit
    @produto = Produto.find(params[:id])
  end

  def update
    @produto = Produto.find(params[:id])
    if @produto.update(produto_params)
      redirect_to @produto, notice: "Produto atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @produto = Produto.find(params[:id])
    @produto.destroy
    redirect_to produtos_path, notice: "Produto removido com sucesso."
  end

  private

  def produto_params
    params.require(:produto).permit(:nome, :categoria_id, :subcategoria_id, :marca, :unidade_sugerida, :nome_generico, :commission_percentage)
  end

  def verificar_admin
    # Ajuste conforme sua lógica. Exemplo:
    unless current_usuario&.papel == "admin"
      redirect_to root_path, alert: "Acesso negado."
    end
  end
  
end
