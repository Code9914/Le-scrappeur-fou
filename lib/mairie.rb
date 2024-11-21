require 'httparty'
require 'nokogiri'
require 'uri'

def scrape
  scraped_pages = []
  page_body = HTTParty.get("https://lannuaire.service-public.fr/navigation/ile-de-france/mairie?where=Val+d%27Oise").body
  doc = Nokogiri::HTML(page_body)
  doc.css('ul.fr-raw-list').each do |node|
    scraped_pages << node
  end
  scraped_pages
end

def clean_url(url)
  url.strip.gsub(/\s+/, '')
end

def valid_url?(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
rescue URI::InvalidURIError
  false
end

def get_urls
  urls_array = []
  scrape.each do |node|
    node.css('p.fr-mb-0 a').each do |link|
      url = clean_url(link['href'])
      urls_array << url if url && valid_url?(url)
    end
  end
  urls_array
end

def get_emails(url)
    page_body = HTTParty.get(url).body
    doc = Nokogiri::HTML(page_body)
    email = doc.xpath('//*[@id="contentContactEmail"]/span[2]/a').map { |link| link['href'].sub('mailto:', '') }
    email.first
end

def collect_emails
  emails = []
  urls = get_urls
  urls.each do |url|
    begin
      email = get_emails(url)
      emails << { url: url, email: email || "Non trouvé/Pas d'email." }
    end
  end
  emails
end

result = collect_emails
puts result