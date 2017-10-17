
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        a = Tmdb::Movie.new
        a.id=200;
        fake_results = [a,a]
        expect(Tmdb::Movie).to receive(:find).with('Inception').and_return(fake_results)
        allow(Tmdb::Movie).to receive(:release).and_return({ "countries"=>[{"iso_3166_1"=>"US","certification"=>"G"}]})
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  describe 'adding movies with TMDb' do
    it 'should call Tmdb detail with ID' do
      fake_movie = { "title"=>"Fight Club", "release_date"=>"1999-10-15", "id"=>550, "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion."}
      expect(Tmdb::Movie).to receive(:detail).and_return(fake_movie)
      allow(Tmdb::Movie).to receive(:releases).and_return({"id"=>550, "countries"=>[{"certification"=>"R", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1999-09-21"}, {"certification"=>"R", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1999-10-06"}]})
      Movie.create_from_tmdb(550)
    end
    it 'should call Tmdb releases with ID' do
      fake_movie = { "title"=>"Fight Club", "release_date"=>"1999-10-15", "id"=>550, "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion."}
      allow(Tmdb::Movie).to receive(:detail).and_return(fake_movie)
      expect(Tmdb::Movie).to receive(:releases).and_return({"id"=>550, "countries"=>[{"certification"=>"R", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1999-09-21"}, {"certification"=>"R", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1999-10-06"}]})
      Movie.create_from_tmdb(550)
    end
  end
end
