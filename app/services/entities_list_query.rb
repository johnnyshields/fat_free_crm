# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class EntitiesListQuery < Struct.new(:base_scope,
                                     :search_string,
                                     :filter,
                                     :order,
                                     :advanced_search,
                                     :page,
                                     :per_page,
                                     :format,
                                     :included_relations)

  attr_reader :count, :scope

  # Builds instance variables #scope, #count, #query, and #tags
  #----------------------------------------------------------------------------
  def build!
    @scope = base_scope
    add_scope_filter
    add_scope_query
    add_scope_tags
    add_scope_order
    @count = @scope.count
    add_scope_pagination
    add_scope_includes
    @scope
  end

  def query
    @query || (set_query_and_tags && @query)
  end

  def tags
    @tags || (set_query_and_tags && @tags)
  end

  protected

  # Get filter from session, unless running an advanced search
  def add_scope_filter
    @scope = @scope.state(filter) if filter.present? && !advanced_search
  end

  def add_scope_query
    @scope = @scope.text_search(query) if query.present?
  end

  def add_scope_tags
    @scope = @scope.tagged_with(tags, on: :tags) if tags.present?
  end

  # Ignore this order when doing advanced search
  def add_scope_order
    @scope = @scope.order(order) if order.present? && !advanced_search
  end

  # Pagination is disabled for xls and csv requests
  def add_scope_pagination
    return unless format.xls? || format.csv?
    per_page = @count if per_page == 'all'
    @scope = @scope.paginate(page: page, per_page: per_page)
  end

  def add_scope_includes
    @scope = @scope.includes(*included_relationsa) if included_relations.present?
  end

  # Somewhat simplistic parser that extracts query and hash-prefixed tags from
  # the search string and returns them as two element array, for example:
  #
  # "#real Billy Bones #pirate" => [ "Billy Bones", "real, pirate" ]
  #----------------------------------------------------------------------------
  def set_query_and_tags
    if search_string.blank?
      @query, @tags = '', ''
    else
      ary_query = []
      ary_tags = []
      search_string.strip.split(/\s+/).each do |token|
        if token.starts_with?("#")
          ary_tags << token[1..-1]
        else
          ary_query << token
        end
      end
      @query = ary_query.join(" ")
      @tags  = ary_tags.join(", ")
    end
    true
  end
end
