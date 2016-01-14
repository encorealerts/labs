companies_list = File.open('companies-links.csv')

class String
  def is_i?
     /\A[-+]?\d+\z/ === self
  end
end

CSV.open('companies-followers.csv', 'wb') do |csv|
  CSV.open('companies-followers.csv.finished', 'r') do |finished|
    scraped = finished.to_a

    companies = Rcsv.raw_parse(companies_list)
    companies.each do |company|
      begin
        company_name = company[0]
        company_link = company[1].try(:split, '%').try(:first)

        company_entry = scraped.select{|s| s.first == company_name}.try(:first)

        company_followers = company_entry.try(:last).try(:gsub, '.', '')
        company_followers = company_followers && company_followers.is_i? ? company_followers.to_i : nil

        # If don't have followers, scrape
        unless company_followers || !company_link
          ap "#{company_name}: Scraping"
          doc = Nokogiri::HTML(open(company_link))
          company_followers = doc.search("a[data-nav='followers']").try(:first).try(:get_attribute, 'title').try(:split, ' ').try(:first)
        else
          ap "#{company_name}: Not Scraping - followers:#{company_followers} - entry:#{company_entry}"
        end
      rescue OpenURI::HTTPError => ex
        ap ex
        company_followers = ex.message
      end

      puts "#{[company_name, company_link, company_followers].join(',')}"

      csv << [company_name, company_link, company_followers]
      csv.flush
    end
  end
end

FileUtils.rm('companies-followers.csv.finished')
FileUtils.mv('companies-followers.csv', 'companies-followers.csv.finished')