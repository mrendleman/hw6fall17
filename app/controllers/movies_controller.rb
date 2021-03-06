class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    
    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def search_tmdb
    @search_terms = params[:search_terms];
    if @search_terms.class == Array # the HAML code "= text_field :search_terms, ''" returns an array containing a string instead of a string
      @search_terms = @search_terms[0]
    end
    none = false;
    if @search_terms && !@search_terms.empty? && !@search_terms.match(/^\s+$/)
      @movies=Movie.
      find_in_tmdb(@search_terms)
      if @movies && !(@movies.size > 0)
        none = true;
      end
    else
      none = true;
    end

    if none
      flash[:notice] = "No matching movies were found on TMDb"
      redirect_to movies_path
    end
  end
  
  def add_tmdb
    if params[:tmdb_movies].nil? #this means no boxes were checked
      flash[:notice] = "No movies added"
      redirect_to movies_path
    else
      successful = true;
      params[:tmdb_movies].keys.each do |id|
        successful = Movie.create_from_tmdb(id)
      end
    
      if successful
        flash[:notice] = "Movies successfully added to Rotten Potatoes"
      else
        flash[:notice] = "Error adding movies"
      end
      redirect_to movies_path
    end
  end

end
