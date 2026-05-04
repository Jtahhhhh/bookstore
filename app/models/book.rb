class Book < ApplicationRecord
    belongs_to :author
    has_many :book_categories, dependent: :destroy
    has_many :categories, through: :book_categories

    scope :with_author_and_categories, -> { includes(:author, :categories) }

    scope :search, ->(query) { where("title ILIKE ?", "%#{query}%") }
    scope :filter_by_author, ->(author_id) { where(author_id: author_id) }
    scope :filter_by_category, ->(category_id) { joins(:categories).where(categories: { id: category_id }) }
    scope :filter_by_category_name, ->(category_name) { joins(:categories).where(categories: { name: category_name }) }
    scope :filter_by_published, ->(published) { where(published: published) }

    scope :published, -> { where(published: true) }

    validates :title, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }
    validates :stock, numericality: { greater_than_or_equal_to: 0 }
end
