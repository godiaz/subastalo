class Admin::ProductsController < ApplicationController
  before_action :set_categories
  before_action :authenticate_user!

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      handle_features
      redirect_to product_path(@product)
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      handle_existing_features
      handle_features
      redirect_to product_path(@product)
    else
      render :edit
    end
  end

  def destroy

  end

  def hide
    @product = Product.find(params[:id])
    @product.update(hidden: !@product.hidden?)
    redirect_to admin_category_path(@product.category)
  end

  private

  def handle_existing_features
    features = params.dig(:product, :current_features)
    return unless features

    @product.features.each_with_index do |feature, i|
      feature.update(key: features[i][:key], value: features[i][:value])
    end
  end

  def handle_features
    features = params.dig(:product, :features)
    return unless features

    features.each { |feature| Feature.create(product: @product, key: feature[:key], value: feature[:value]) }
  end

  def product_params
    params.require(:product).permit(:name, :description, :start_time, :end_time, :opening_price, :maximum_price, :category_id)
  end
end
