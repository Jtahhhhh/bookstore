class Admin::AuthorsController < Admin::BaseController
    before_action :set_author, only: [:show, :edit, :update, :destroy]

    def index
        @authors = Author.all
    end

    def show 
    end

    def edit 
    end

    def update
        if @author.update(author_params)
            redirect_to admin_authors_path, notice: "Author updated successfully."
        else
            render :edit
        end
    end

    def destroy
        if @author.destroy
            redirect_to admin_authors_path, notice: "Author deleted successfully."
        else
            flash.now[:alert] = "Failed to delete author."
        end
    end

    def new
        @author = Author.new
    end

    def create
        @author = Author.new(author_params)
        if @author.save
            redirect_to admin_authors_path, notice: "Author created successfully."
        else
            render :new
        end
    end

    private
    def set_author
        @author = Author.find(params[:id])
    end

    def author_params
        params.require(:author).permit(:name, :bio)
    end
end
