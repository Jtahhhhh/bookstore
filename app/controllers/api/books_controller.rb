class Api::BooksController < ApplicationController
    def index
        @books = filter_books
        render json: @books.as_json(include: [:author, :categories]), status: :ok
    end

    def show
        @book = Book.with_author_and_categories.published.find(params[:id])
        render json: @book.as_json(include: [:author, :categories]), status: :ok
    end

    private 
    def filter_books
        @books = Book.with_author_and_categories.published.order(:title)
        @books = @books.filter_by_author(params[:author_id]) if params[:author_id].present?
        @books = @books.filter_by_category_name(params[:category]) if params[:category].present?
        @books = @books.where("price >= ?", params[:min_price]) if params[:min_price].present?
        @books = @books.where("price <= ?", params[:max_price]) if params[:max_price].present?
        @books = @books.order(created_at: :desc)
    end
end
