# encoding UTF-8

def scrape_company company_name, proxies
  proxy = rand(proxies.count)

  begin
    agent = Mechanize.new

    website = company_name + ' twitter'

    p "#{company_name} - Scraping - (proxy #{(proxy) + 1} of #{proxies.count})"

    agent.set_proxy proxies[proxy].first, proxies[proxy].last
    page = agent.get('http://www.google.com/')

    p "#{company_name} - Loading Google Query: #{website}"

    google_form = page.form('f')
    google_form.q = website

    p "#{company_name} - Submitting: '#{website}'"

    page = agent.submit(google_form, google_form.buttons.first)

    ap "#{company_name} - Links: #{page.links.count}"

    CSV.open('companies/' + company_name + '-links.csv', 'w') do |csv|
      page.links.each do |l|
        csv << [l.text, l.href]
      end
    end
  rescue Exception => ex
    puts company_name + ': ' + proxies[proxy].to_s + ': ' + ex.message
    scrape_company company_name, proxies
  end
end

proxies = [
  ['186.225.99.140', 80], # good
  ['177.47.238.18', 8080], # good
  ['200.252.200.14', 8080], # good
  ['177.75.7.18', 80], # good
  ['177.75.8.34', 80], # good
  ['177.8.170.4', 80], # good
  ['187.49.235.197', 3128], # good
  ['177.8.170.11', 80], # good
  
  # Argentina
  ['200.16.124.43', 3128],
  ['190.98.162.22', 8080],
  ['200.49.32.164', 80],
  ['200.70.56.204', 3128],
  ['200.117.50.61', 3128],
  ['200.43.219.116',  8080],
  ['186.0.222.10',  8080],
  ['190.221.23.158',  80],

  # Chile
  ['200.86.219.33', 80],
  ['190.101.126.199', 80],
  ['190.101.126.199', 8080],
  ['186.67.158.43', 3128],
  ['190.208.45.221', 3128],

  ['208.67.1.154', 80],
  ['69.85.193.119', 80],
  ['204.152.240.30', 9999],
  ['205.177.86.114', 81],
  ['216.251.121.103', 80],
  ['66.76.24.115', 3128]

]

threads = []

@csv_data = File.open('companies-list.csv')

raw_parsed_csv_data = Rcsv.raw_parse(@csv_data)
raw_parsed_csv_data.each do |r|
  company_name = r[0]
  
  threads << Thread.new do
    unless File.exist?('companies/' + company_name + '-links.csv')
      scrape_company company_name.dup, proxies.dup
    end
  end

  if threads.count == proxies.count
    loop do
      threads.reject!{|t| !t.alive?}
      ap "Alive threads: #{threads.count}"
      sleep(1)
      break if threads.count < proxies.count / 2
    end
  end
end

loop do
  threads.all?{|t| !t.alive?}
  ap "Alive threads: #{threads.count}"
  break unless threads.any?{|t| t.alive?}
end

