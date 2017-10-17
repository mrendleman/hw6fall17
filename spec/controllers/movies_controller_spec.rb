require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    context 'with valid search' do
      it 'should call the model method that performs TMDb search' do
        fake_results = [double('movie1'), double('movie2')]
        expect(Movie).to receive(:find_in_tmdb).with('Ted').
          and_return(fake_results)
        post :search_tmdb, {:search_terms => ['Ted','asdf']}
      end
      it 'should select the Search Results template for rendering' do
        allow(Movie).to receive(:find_in_tmdb)
        post :search_tmdb, {:search_terms => ['Ted','asdf']}
        expect(response).to render_template('search_tmdb')
      end  
      it 'should make the TMDb search results available to that template' do
        fake_results = [double('Movie'), double('Movie')]
        allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
        post :search_tmdb, {:search_terms => ['Ted','asdf']}
        expect(assigns(:movies)).to eq(fake_results)
      end
    end
    context 'with empty search' do
      it 'should select the movies template for rendering' do
        post :search_tmdb, {:search_terms => ''}
        expect(response).to redirect_to('/movies')
      end
    end
    context 'with bad search terms' do
      it 'should select the movies template for rendering' do
        post :search_tmdb, {:search_terms => ['asdflkjaeoirvn','asdf']}
        expect(response).to redirect_to('/movies')
      end
    end
  end
  describe 'adding from TMDb' do
    it 'should call the model method that adds TMDb movies' do
      expect(Movie).to receive(:create_from_tmdb).with(123).and_return(true)
      post :add_tmdb, {:tmdb_movies => {123=>1}}
    end
    it 'should select the movies template for rendering (movie selected)' do
      allow(Movie).to receive(:create_from_tmdb).with(123).and_return(true)
      post :add_tmdb, {:tmdb_movies => {123=>1}}
      expect(response).to redirect_to('/movies')
    end
    it 'should select the movies template for rendering (no movie selected)' do
      allow(Movie).to receive(:create_from_tmdb).with(123).and_return(true)
      post :add_tmdb, {}
      expect(response).to redirect_to('/movies')
    end
  end
end
