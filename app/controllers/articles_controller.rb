class ArticlesController < ApplicationController

# ユーザがログインしていないと"new"にアクセスできない
  before_action :authenticate_user!, only: :new

	def new
		@article = Article.new
	end

	def create
		@article = Article.new(article_params)

		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

	def show
		@article = Article.find(params[:id])


		REDIS.zincrby("articles/all/", 1, "#{@article.id}")
		@popular_ids = REDIS.zrevrange "articles/all/", 0, -1, withscores: true


	end

	def index
		@articles = Article.all

		@popular_ids = REDIS.zrevrange "articles/all/", 0, -1, withscores: true
		
	end

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])

		if @article.update(article_params)
			redirect_to @article
		else
			render 'edit'
		end
	end

	def destroy
		@article = Article.find(params[:id])
		@article.destroy

		redirect_to articles_path
	end

	private
		def article_params
			params.require(:article).permit(:title, :text)
	end
end
