class Posting < ApplicationRecord

  belongs_to :author,    class_name: 'User', foreign_key: 'user_id'
  belongs_to :editor,    class_name: 'User', foreign_key: 'editor_id'

  before_save :validate_article_image

  # I will add two more fields to table
  # [article_image] -> image link;
  # [image_present] -> flag
  # Do not calculate and manipulate this post image;
  # and Update after all changes


  def validate_article_image
    self.article_image = posting_image_params[0]
    self.image_present = posting_image_params.present?
    self.save
  end

  def article_with_image
    return type if type != 'Article'

    figure_start = body.index('<figure')
    figure_end = body.index('</figure>')
    return "#{figure_start}_#{figure_end}" if figure_start.nil? || figure_end.nil?

    # Do not sure undertood what is number [9]
    # If this need should move to Constant and freeze
    image_tags = body[figure_start...figure_end + 9]
    # Why we return not include
    # Do not clear understood;
    # Think is do not need
    return 'not include <img' unless image_tags.include?('<img')

    posting_image_params(image_tags)
  end

  private

  def posting_image_params(html)
    tag_parse = -> (image, att) { image.match(/#{att}="(.+?)"/) }
    tag_attributes = {}

    # Prefare to use Symbol and freeze
    %w[alt src data-image].each do |attribute|
      data = tag_parse.(html, attribute)
      unless data.nil?
        tag_attributes[attribute] = data[1] unless data.size < 2
      end
    end
    # tag_parse
    tag_attributes
  end
end