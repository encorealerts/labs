companies_list = File.open('companies-list.csv')

CSV.open('companies-links.csv', 'w') do |csv|
	companies = Rcsv.raw_parse(companies_list)
	companies.each do |company|
		next unless File.exist?('companies/' + company.first + '-links.csv')
		company_data = File.open('companies/' + company.first + '-links.csv')
		company_links = Rcsv.raw_parse(company_data)
		link = company_links.select{|r| r.first.include?('| Twitter') && r.last.include?('twitter.com') }.try(:first)

		csv << [company.first, link.try(:last).try(:gsub, '/url?q=', '').try(:split, '&').try(:first)]
	end
end