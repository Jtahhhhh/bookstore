class Admin::BooksController < Admin::BaseController
    before_action :set_book, only: [:show, :edit, :update]
    
    def index
        filter_books
    end

    def show 
    end

    def new
        @book = Book.new
        @categories = Category.all
        @authors = Author.all
    end

    def create
        @book = Book.new(book_params)
        ActiveRecord::Base.transaction do
            if @book.save!
                redirect_to admin_books_path, notice: "Book created successfully."
            end
        end
        rescue ActiveRecord::RecordInvalid => e
            @categories = Category.all
            @authors = Author.all
            flash.now[:alert] = "Failed to create book: #{e.message}"
            render :new 
    end

    def edit
        @categories = Category.all
        @authors = Author.all
    end

    def update
        ActiveRecord::Base.transaction do
            if @book.update!(book_params)
                redirect_to admin_books_path, notice: "Book updated successfully."
            end
        end
        rescue ActiveRecord::RecordInvalid => e
            @categories = @book.categories.pluck(:id)   
            @authors = @book.author_id
            flash.now[:alert] = "Failed to update book: #{e.message}"
            render :edit
    end

    def destroy
        if @book.destroy
            redirect_to admin_books_path, notice: "Book deleted successfully."
        else
            flash.now[:alert] = "Failed to delete book."
        end
    end

    protected

    def filter_books
        @books = Book.with_author_and_categories.all.order(:title)
        @books = @books.search(params[:keyword]) if params[:keyword].present?
        @books = @books.filter_by_author(params[:author_id]) if params[:author_id].present?
        @books = @books.filter_by_category(params[:category_id]) if params[:category_id].present?
        @books = @books.filter_by_published(params[:published] == "true") if params[:published].present?
    end


    private
    def set_book
        @book = Book.with_author_and_categories.find(params[:id])
    end

    def book_params 
        params.require(:book).permit(:title, :description, :price, :published, :stock,  :author_id, category_ids: [])
    end
end
