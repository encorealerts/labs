AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).count
#244
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:true).count
#121
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).group('alerts.type').count
#=> {nil=>9, "HashtagAlert"=>15, "InfluencerAlert"=>88, "PopularTopicAlert"=>11}
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).where('feedback <> \'\'').map{|a| a.feedback}
# => ["this person looks psycho and rated R",
#  "In arabic, but relevant",
#  "500 followers isn't really an influencer.",
#  "We would only like to be notified of influencers posting on Instagram. This user had arouns 300 followers; we would like to see people with 1200+ followers",
#  "Only 160 followers. Not an influencer.",
#  "duplicated alert",
#  "3rd time receiving this alert",
#  "4th time receiving this alert",
#  "more promotional/salesy",
#  "Maybe it would be best to increase the number of posts that trigger this alert to an amount higher than 5!",
#  "Just a note, when I click to view these Instagram hashtags, it takes me to the twitter hashtag! Thanks.",
#  "duplicate",
#  "duplicate",
#  "I got this one 4 times",
#  "I've received this alert 3 times. Just FYI!",
#  "duplicate",
#  "duplicate",
#  "Inappropriate image and language. I can't share anything with curse words!",
#  "Duplicate of the Greenville, Liberia post.",
#  "the alerts are coming in with a broken up format and I am not able to take action on the trending content! The last 3 alerts have looked this way— only the trending hashtags."]
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).group('alert_ratings.category').count.map{|k,v| k = AlertRating.categories.key(k); {k=>v} }
#=> [{"content_not_relevant"=>77}, {"bad_user"=>18}, {"inappropriate_content"=>15}, {"technical_issues"=>11}, {"others"=>2}]

### Hashtags count
##
#

# Bad feedbacks
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).where(category: AlertRating.categories[:content_not_relevant]).map{|a| a.alert.activity.hashtags.count}.mean
#=> 16.51948051948052
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).where(category: AlertRating.categories[:content_not_relevant]).map{|a| a.alert.activity.hashtags.count}.standard_deviation
#=> 8.473814758932042

# Good feedbacks
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:true).map{|a| a.alert.activity.hashtags.count}.mean
#=> 12.173553719008265
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:true).map{|a| a.alert.activity.hashtags.count}.standard_deviation
#=> 9.267935482035549

# Bad hashtags
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:false).where(category: AlertRating.categories[:content_not_relevant]).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.group_by(&:downcase).map {|k,v| [k, v.length]}.sort{|a,b| b.last <=> a.last}
# => [["yeahthatgreenville", 22],
#  ["cleveland", 20],
#  ["greenville", 14],
#  ["greenvillesc", 13],
#  ["southcarolina", 9],
#  ["upstatesc", 8],
#  ["festivalfashion", 8],
#  ["fashion", 7],
#  ["tbt", 6],
#  ["southernliving", 6],
#  ["greersc", 6],
#  ["design", 6],
#  ["miami", 6],
#  ["organicskincare", 6],
#  ["interiordesign", 6],
#  ["homestaging", 5],
#  ["home", 5],
#  ["designer", 5],
#  ["edesign", 5],
#  ["staging", 5],
#  ["homedecor", 5],
#  ["insidethedesign", 5],
#  ["homestager", 5],
#  ["greer", 5],
#  ["boho", 5],
#  ["stager", 5],
#  ["decor", 5],
#  ["fitness", 4],
#  ["fitfam", 4],
#  ["ohio", 4],
#  ["bohostyle", 4],
#  ["blessed", 4],
#  ["la", 4],
#  ["festivalstyle", 4],
#  ["newyork", 4]

# Good hashtags
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good:true).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.group_by(&:downcase).map {|k,v| [k, v.length]}.sort{|a,b| b.last <=> a.last}
# => [["traveloregon", 31],
#  ["cleveland", 26],
#  ["mercedesbenz", 15],
#  ["lecreuset", 13],
#  ["oregonexplored", 13],
#  ["wildernessculture", 12],
#  ["oregon", 12],
#  ["rei1440project", 11],
#  ["upperleftusa", 11],
#  ["amg", 11],
#  ["mercedes", 11],
#  ["neverstopexploring", 10],
#  ["pnw", 10],
#  ["pnwonderland", 9],
#  ["bestoforegon", 9],
#  ["thisiscle", 7],
#  ["ourplanetdaily", 7],
#  ["travelstoke", 7],
#  ["pdx", 6],
#  ["pdxnow", 6],
#  ["vscocam", 6],
#  ["mercedesamg", 6],
#  ["lebronjames", 6],
#  ["huffpostgram", 6],
#  ["soulcycle", 6],
#  ["exklusive_shot", 5],
#  ["lifeofadventure", 5],
#  ["exploregon", 5],
#  ["northwestisbest", 5],
#  ["love", 5],
#  ["liveauthentic", 5],
#  ["bpmag", 5],
#  ["passionpassport", 4],
#  ["doyoutravel", 4],
#  ["livefolk", 4]

AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good: false).where(category: AlertRating.categories[:content_not_relevant]).group('alerts.business_id').count.map{|k,v| {Business.find(k).name => v}}
# => [{"Denver Broncos"=>3},
#  {"IDEO"=>2},
#  {"Cleveland CVB"=>23},
#  {"UVA"=>1},
#  {"Razorfish - Mercedes Benz"=>3},
#  {"Gordmans"=>8},
#  {"Brains on Fire - Greenville"=>31},
#  {"Juice Beauty"=>6}]
AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good: false).where(category: AlertRating.categories[:content_not_relevant]).group('alerts.business_id').count.map{|k,v| {k => v}}
# => [{320=>3}, 
# {381=>2}, 
# {411=>23}, 
# {416=>1}, 
# {426=>3}, 
# {443=>8}, 
# {501=>31}, 
# {522=>6}]

#### 
##
## Analyzing Customer Quality 
##
####

# Brains on Fire - Greenville (501)
# Cleveland (411)

# All good hashtags
good_hashtags = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where('alerts.business_id = ?', 501).where(category: AlertRating.categories[:content_not_relevant]).where(good:true).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.map{|h| h.downcase}
bad_hashtags = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where('alerts.business_id = ?', 501).where(category: AlertRating.categories[:content_not_relevant]).where(good:false).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.group_by(&:downcase).map {|k,v| [k, v.length]}.sort{|a,b| b.last <=> a.last}
bad_hashtags.reject{|a| good_hashtags.include?(a.first)}

[320, 381, 411, 416, 426, 443, 501, 522].each do |business_id|
  good_feedbacks_count = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good: true).where('alerts.business_id = ?', business_id).count
  bad_feedbacks_count = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where(good: false).where('alerts.business_id = ?', business_id).where(category: AlertRating.categories[:content_not_relevant]).count

  next unless good_feedbacks_count > 1 && bad_feedbacks_count > 1

  puts '#########'
  puts '##'
  puts '## ' + Business.find(business_id).name
  puts '##'
  puts '#########'
  puts ''
  puts '1. Hashtags in bad alert feedbacks'
  puts '2. How many times it appeared'
  puts ''
  puts "Total good feedbacks: #{good_feedbacks_count}"
  puts "Total bad feedbacks received due content issues: #{bad_feedbacks_count}"
  puts ''
  good_hashtags = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where('alerts.business_id = ?', business_id).where(good:true).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.group_by(&:downcase).map {|k,v| [k, v.length]}.sort{|a,b| b.last <=> a.last}
  good_hashtags_text = good_hashtags.map{|h| h.first}
  bad_hashtags = AlertRating.joins(:alert).joins(alert: :rule).where(rules: {source: 'instagram'}).where('alerts.business_id = ?', business_id).where(category: AlertRating.categories[:content_not_relevant]).where(good:false).map{|a| a.alert.activity.hashtags}.flatten.map{|h| h.text}.group_by(&:downcase).map {|k,v| [k, v.length]}.sort{|a,b| b.last <=> a.last}

  puts '# Top hashtags in good feedbacks'
  puts good_hashtags.take(10)
  puts '# Top hashtags in bad feedbacks'
  puts bad_hashtags.take(10)
  puts '# Top hashtags in bad feedbacks that were never in a good feedback'
  puts bad_hashtags.reject{|a| good_hashtags_text.include?(a.first)}.take(10)
end