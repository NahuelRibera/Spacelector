# Finds spaces, subspaces, image titles and annotation text belonging to a single
# user. Matching tolerates accents and small typos (via Postgres' unaccent/pg_trgm
# extensions) but always ranks an exact or substring match above an approximate one,
# so a fuzzy match can't bury the result someone was actually looking for.
class SearchService
  MIN_SIMILARITY = 0.3
  MAX_RESULTS = 8

  Result = Struct.new(:type, :label, :location, :space, :image, :compartment, :rank, :score, keyword_init: true) do
    def url_options
      case type
      when :space, :subspace
        { id: space.id }
      when :image
        { id: image.space_id, image_id: image.id }
      when :annotation
        { id: image.space_id, image_id: image.id, highlight_compartment_id: compartment.id }
      end
    end
  end

  def initialize(user, query)
    @user = user
    @query = query.to_s.strip
  end

  def results
    return [] if query.blank?

    (space_results + image_results + annotation_results)
      .sort_by { |r| [r.rank, -r.score] }
      .first(MAX_RESULTS)
  end

  def top_result
    results.first
  end

  private

  attr_reader :user, :query

  def space_results
    Space.where(user_id: user.id)
         .select("spaces.*, #{rank_and_score_sql('spaces.name')}")
         .where(match_sql('spaces.name'))
         .order(Arel.sql('match_rank ASC, match_score DESC'))
         .limit(MAX_RESULTS)
         .map do |space|
           Result.new(
             type: space.parent_space_id.present? ? :subspace : :space,
             label: space.name,
             location: breadcrumb(space),
             space: space,
             rank: space.match_rank,
             score: space.match_score
           )
         end
  end

  def image_results
    Image.joins(:space)
         .merge(Space.where(user_id: user.id))
         .select("images.*, #{rank_and_score_sql('images.title')}")
         .where(match_sql('images.title'))
         .order(Arel.sql('match_rank ASC, match_score DESC'))
         .limit(MAX_RESULTS)
         .map do |image|
           Result.new(
             type: :image,
             label: image.title,
             location: breadcrumb(image.space),
             image: image,
             rank: image.match_rank,
             score: image.match_score
           )
         end
  end

  def annotation_results
    ObjectInfo.joins(compartment: { image: :space })
              .merge(Space.where(user_id: user.id))
              .select("object_infos.*, #{rank_and_score_sql('object_infos.description')}")
              .where(match_sql('object_infos.description'))
              .order(Arel.sql('match_rank ASC, match_score DESC'))
              .limit(MAX_RESULTS)
              .map do |object_info|
                compartment = object_info.compartment
                Result.new(
                  type: :annotation,
                  label: object_info.description,
                  location: breadcrumb(compartment.image.space),
                  image: compartment.image,
                  compartment: compartment,
                  rank: object_info.match_rank,
                  score: object_info.match_score
                )
              end
  end

  def rank_and_score_sql(column)
    ActiveRecord::Base.sanitize_sql_array([
      "CASE
         WHEN unaccent(lower(#{column})) = unaccent(lower(?)) THEN 0
         WHEN unaccent(lower(#{column})) LIKE unaccent(lower('%' || ? || '%')) THEN 1
         ELSE 2
       END AS match_rank,
       similarity(unaccent(lower(coalesce(#{column}, ''))), unaccent(lower(?))) AS match_score",
      query, query, query
    ])
  end

  def match_sql(column)
    ActiveRecord::Base.sanitize_sql_array([
      "#{column} IS NOT NULL AND (
         unaccent(lower(#{column})) LIKE unaccent(lower('%' || ? || '%'))
         OR similarity(unaccent(lower(#{column})), unaccent(lower(?))) > ?
       )",
      query, query, MIN_SIMILARITY
    ])
  end

  def breadcrumb(space)
    chain = [space]
    while chain.last.parent_space
      chain << chain.last.parent_space
    end
    chain.reverse.map(&:name).join(' → ')
  end
end
