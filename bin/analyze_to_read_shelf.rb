require_relative '../lib/book-finder.rb'
require 'dotenv/load'
require 'goodreads'
@chrome = Chrome.new

def fetch_asin( asin )
  begin
    amazon = Amazon.new( @chrome )

    book = amazon.find_kindle_book_by_asin( asin )
    if( book )
      puts "#{asin}, #{book.title},#{book.on_kindle_unlimited?},#{book.kindle_price}"
    else
      puts "#{asin}, No Kindle book"
    end
  rescue Exception => e
    puts "Bad ASIN: #{asin}: #{e.message}"
  end
end

client = Goodreads::Client.new(api_key: ENV['GOODREADS_API_KEY'], api_secret: ENV['GOODREADS_SECRET_KEY'])

shelf = client.shelf(ENV['GOODREADS_USER_ID'], 'to-read')
(shelf.start .. shelf.end).each do |page|
  client.shelf(ENV['GOODREADS_USER_ID'], 'to-read', {page: page} ).books.each do |book|
    fetch_asin( book.to_h['book']['isbn'] ) if book.to_h['book']['isbn']
  end
end
