module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_category, only: [:edit, :update]

    def index
      @categories = Category.all.order(:name)
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "Categoria criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Categoria atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description)
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user.role == "admin"
    end
  end
end
