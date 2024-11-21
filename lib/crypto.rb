require 'nokogiri'
require 'open-uri'
require 'httparty'

def scrape
  scraped_pages = []
  page_body = HTTParty.get("https://coinmarketcap.com/all/views/all/").body
  doc = Nokogiri::HTML(page_body)
  doc.css('tr.cmc-table-row').each do |node|
    scraped_pages << node
  end
  scraped_pages
end

def crypto_details
  details_arr = []
  scrape.each do |node|
    name = node.css('td.cmc-table__cell--sort-by__name a').text.strip
    market_cap = node.css('td.cmc-table__cell--sort-by__market-cap span[2]').text.strip
    price = node.css('td.cmc-table__cell--sort-by__price span').text.strip
    volume = node.css('td.cmc-table__cell--sort-by__volume-24-h a').text.strip
    circulating_supply = node.css('td.cmc-table__cell--sort-by__circulating-supply div').text.strip
    change = node.css('td.cmc-table__cell--sort-by__percent-change-24-h div').text.strip

    details_hash = {
      Name: name,
      Market_cap: market_cap,
      Price: price,
      Volume: volume,
      Circulating_supply: circulating_supply,
      Change: change
    }

    details_arr << details_hash unless details_hash.values.all?(&:empty?)
  end
  details_arr.each { |hash| puts hash }
end

crypto_details