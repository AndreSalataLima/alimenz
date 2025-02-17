class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Crie scopes para filtrar por papel, se necessário:
  scope :clientes, -> { where(papel: 'cliente') }
  scope :fornecedores, -> { where(papel: 'fornecedor') }
  scope :admins, -> { where(papel: 'admin') }

  # Validações (exemplo)
  validates :nome, presence: true
  validates :papel, inclusion: { in: %w[cliente fornecedor admin] }


end
