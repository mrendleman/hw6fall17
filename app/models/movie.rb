require 'themoviedb'

class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    movies = Array.new;
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      matches = Tmdb::Movie.find(string)
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
    matches.each do |match|
      rating = "R"
      Tmdb::Movie.releases(match.id)["countries"].each do |release|
        if release["iso_3166_1"].eql?("US") 
          rating = release["certification"] 
          break
        end
      end
      if rating.empty? then rating='R' end
      movie = { :title=> match.title, :release_date => match.release_date,
      :tmdb_id => match.id, :rating => rating }
      movies.push(movie)
    end
    return movies
  end

  def self.create_from_tmdb(tmdb_id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    movie =  Tmdb::Movie.detail(tmdb_id)
    releases = Tmdb::Movie.releases(tmdb_id)
    rating = "R"
    releases["countries"].each do |release|
      if release["iso_3166_1"].eql?("US") 
        rating = release["certification"] 
        break
      end
    end
    if rating.empty? then rating='R' end #default to R rating
    movie_params = { :title => movie["title"], :rating => rating, :release_date => movie["release_date"], :description => movie["overview"] }
    
    self.create!(movie_params)
    
  end

end
