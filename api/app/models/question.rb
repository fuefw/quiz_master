class Question < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :content, presence: true
  validates :answer, presence: true
  validates :category, presence: true

  def correct_answer?(guess)
    sanitize(answer)
      .casecmp(sanitize(guess))
      .zero?
  end

  private

  def sanitize(str)
    stripped = str
      .strip
      .tr("-", " ")
      .squeeze(" ")

    replace_numerals_with_words(stripped)
  end

  def replace_numerals_with_words(str)
    str.gsub(/\d+/) { |num| num.to_i.to_words }
  end
end
