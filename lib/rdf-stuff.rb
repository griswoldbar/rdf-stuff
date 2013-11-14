require 'sparql/client'
require 'rdf/raptor'

module Console
  def movie_client
    SPARQL::Client.new("http://data.linkedmdb.org/sparql")
  end

  def count_films(actor="Arnold Schwarzenegger")
    movie_client.query(%Q{
      PREFIX : <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT (COUNT (?movie)) AS ?howmany)
      WHERE {
        ?arnie :actor_name "#{actor}".
        ?movie      :actor ?arnie.
      }
    }).output
  end

  def films(actor="Arnold Schwarzenegger")
    movie_client.query(%Q{
      PREFIX : <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT ?movieName
        WHERE {
          ?arnie :actor_name "#{actor}".
          ?movie      :actor ?arnie;
                      dc:title ?movieName ;
                      :sequel  ?sequel .
        }
    }).output
  end

  def films_no_sequels(actor="Arnold Schwarzenegger")
    movie_client.query(%Q{
      PREFIX : <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT ?movieName
        WHERE {
          ?arnie :actor_name "#{actor}".
          ?movie      :actor ?arnie;
                      dc:title ?movieName .
          OPTIONAL {
            ?otherMovie dc:title ?otherMovieName .
            ?movie      :sequel ?otherMovie .
          }
          FILTER ( ! bound(?otherMovieName) )
        }
    }).output
  end

  def films_with_sequel(actor="Arnold Schwarzenegger")
    #where film has a sequel but is not a sequel itself
    movie_client.query(%Q{
      PREFIX : <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT ?movieName ?sequelName
        WHERE {
          ?arnie :actor_name "#{actor}".
          ?movie      :actor ?arnie;
                      dc:title ?movieName ;
                      :sequel  ?sequel .
          ?sequel     dc:title ?sequelName
          # OPTIONAL {
          #   ?prequel :sequel ?movie .
          # }
          # FILTER ( ! bound(?prequel) )
        }
    }).output
  end

  def sequel_count(max=4)

  end

  def output
    each_solution.map {|s| s.to_hash.each_pair.map{|k,v| v } }.each {|x| puts x.map{|str| str.to_s.ljust(35)}.join(" ") }
  end

end

include Console