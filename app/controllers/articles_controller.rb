class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def new
    @article = Article.new
  end

  def create
    #byebug
    @article = Orders::ArticlesCreator.new(params[:article][:title], params[:article][:body]).create
    if @article.save
      redirect_to 'articles/index'
    else
        render 'articles/new'
    end
  end

  
end
