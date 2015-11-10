active_businesses = Business.active.map{|b| b.id}
trackable_businesses = MailTracking.where('created_at > ? AND created_at < ?', 3.month.ago, DateTime.now).where(business_id: active_businesses).where(event: 'opened').group('business_id').count.map{|k,v| k}
excluded_businesses = active_businesses - trackable_businesses

trackable_businesses.each do |b|
  b = Business.find(b)
  #query = MailTracking.where('created_at > ? AND created_at < ?', 1.month.ago, DateTime.now).where('alert_id IS NOT NULL').select('alert_id').distinct.group('date(created_at)').where('recipient NOT LIKE \'%encorealert%\' AND recipient NOT LIKE \'%encorehq%\' AND recipient NOT LIKE \'%cameron%\' AND recipient NOT LIKE \'%tammy%\'').where('business_id NOT IN (?)', excluded_businesses)
  query = MailTracking.where('created_at > ? AND created_at < ?', 3.month.ago, DateTime.now).where('alert_id IS NOT NULL').select('alert_id').distinct.where('recipient NOT LIKE \'%encorealert%\' AND recipient NOT LIKE \'%encorehq%\' AND recipient NOT LIKE \'%cameron%\' AND recipient NOT LIKE \'%tammy%\'').where('business_id NOT IN (?)', excluded_businesses)
  query = query.where(business_id: b.id)

  #ap query.to_sql

  delivered = query.where(event: 'delivered').count
  opened = query.where(event: 'opened').count
  clicked = query.where(event: 'clicked').count
  actioned = query.where(event: 'clicked').where('recommendation_id IS NOT NULL').count

  # open_rate = delivered.map{|k,v| ((opened[k]||0)/v.to_f) * 100}
  # click_rate = opened.map{|k,v| ((clicked[k]||0)/v.to_f) * 100}
  # action_rate = opened.map{|k,v| ((actioned[k]||0)/v.to_f) * 100}

  open_rate = opened / delivered.to_f
  click_rate = clicked / opened.to_f

  # ap "#### Business: #{b.name}"
  # ap "Open Rate: #{open_rate.mean}"
  # ap "Click Rate: #{click_rate.mean}"
  # ap "Action Rate: #{action_rate.mean}"
  # ap '-------'

  puts "#{b.name}\t#{open_rate}\t#{click_rate}"
end