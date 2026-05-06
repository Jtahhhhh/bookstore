class Api::BooksController < ApplicationController
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

  def index
    books = filter_books
    paginated_books = paginate(books)

    render json: {
      status: "success",
      message: "Books fetched successfully",
      data: paginated_books.as_json(
        include: [:author, :categories]
      ),
      meta: pagination_meta(books)
    }, status: :ok
  end

  def show
    book = Book.with_author_and_categories.published.find_by(id: params[:id])

    unless book
      return render json: {
        status: "error",
        message: "Book not found"
      }, status: :not_found
    end

    render json: {
      status: "success",
      message: "Book fetched successfully",
      data: book.as_json(
        include: [:author, :categories]
      )
    }, status: :ok
  end

  private

  def filter_books
    books = Book.with_author_and_categories.published

    books = books.filter_by_author(params[:author_id]) if params[:author_id].present?
    books = books.filter_by_category_slug(params[:category]) if params[:category].present?
    books = books.where("price >= ?", params[:min_price]) if params[:min_price].present?
    books = books.where("price <= ?", params[:max_price]) if params[:max_price].present?
    books = books.search(params[:q]) if params[:q].present?

    books.order(created_at: :desc)
  end

  def paginate(scope)
    scope.offset(offset_value).limit(per_page)
  end

  def pagination_meta(scope)
    total_count = scope.count
    total_pages = (total_count.to_f / per_page).ceil

    {
      current_page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      next_page: page < total_pages ? page + 1 : nil,
      prev_page: page > 1 ? page - 1 : nil
    }
  end

  def page
    params[:page].to_i.positive? ? params[:page].to_i : 1
  end

  def per_page
    value = params[:per_page].to_i
    value = DEFAULT_PER_PAGE if value <= 0
    [value, MAX_PER_PAGE].min
  end

  def offset_value
    (page - 1) * per_page
  end
end