class Usuario < ApplicationRecord
  has_many :cotacoes, class_name: "Cotacao", foreign_key: "cliente_id", dependent: :destroy
  has_many :respostas_de_cotacao, foreign_key: "fornecedor_id", class_name: "RespostaDeCotacao"
  has_many :fornecedor_categorias, foreign_key: "fornecedor_id", class_name: "FornecedorCategoria", dependent: :destroy
  has_many :categorias, through: :fornecedor_categorias

  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Crie scopes para filtrar por papel, se necessário:
  scope :clientes, -> { where(papel: 'cliente') }
  scope :fornecedores, -> { where(papel: 'fornecedor') }
  scope :admins, -> { where(papel: 'admin') }

  # Validações (exemplo)
  validates :nome, presence: true
  validates :papel, inclusion: { in: %w[cliente fornecedor admin] }


end
