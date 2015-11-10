Alert.skip_callback(:create, :before, :generate_score)

Alert.skip_callback(:commit, :after, :set_content_alerted
Alert.skip_callback(:commit, :after, :send_outlier_volume)
Alert.skip_callback(:commit, :after, :send_limit_reached)
Alert.skip_callback(:commit, :after, :send_users_didnt_opened_alerts)

HashtagAlert.skip_callback(:validate, :before, :prepare)
HashtagAlert.skip_callback(:commit, :after, :store_hashtags_in_stopwords)

UrlAlert.skip_callback(:validate, :before, :prepare)

Alert.skip_callback(:commit, :after, :send_email_alert)
HashtagAlert.skip_callback(:commit, :after, :send_email_alert)
UrlTopicAlert.skip_callback(:commit, :after, :send_email_alert)
PopularTopicAlert.skip_callback(:commit, :after, :send_email_alert)
PredictivePostAlert.skip_callback(:commit, :after, :send_email_alert)
InfluencerAlert.skip_callback(:commit, :after, :send_email_alert)
DirectAlert.skip_callback(:commit, :after, :send_email_alert)

Alert.skip_callback(:commit, :after, :send_outlier_volume)
HashtagAlert.skip_callback(:commit, :after, :send_outlier_volume)
UrlTopicAlert.skip_callback(:commit, :after, :send_outlier_volume)
PopularTopicAlert.skip_callback(:commit, :after, :send_outlier_volume)
PredictivePostAlert.skip_callback(:commit, :after, :send_outlier_volume)
InfluencerAlert.skip_callback(:commit, :after, :send_outlier_volume)
DirectAlert.skip_callback(:commit, :after, :send_outlier_volume)

Alert.skip_callback(:commit, :after, :send_limit_reached)
HashtagAlert.skip_callback(:commit, :after, :send_limit_reached)
UrlTopicAlert.skip_callback(:commit, :after, :send_limit_reached)
PopularTopicAlert.skip_callback(:commit, :after, :send_limit_reached)
PredictivePostAlert.skip_callback(:commit, :after, :send_limit_reached)
InfluencerAlert.skip_callback(:commit, :after, :send_limit_reached)
DirectAlert.skip_callback(:commit, :after, :send_limit_reached)

TwitterRule.skip_callback(:validate, :before, :set_provider_value)
TwitterRule.skip_callback(:create, :after, :configure_influencers)
TwitterRule.skip_callback(:create, :after, :configure_trends)

InstagramRule.skip_callback(:commit, :after, :create_provider_value)
InstagramRule.skip_callback(:create, :after, :configure_influencers)
InstagramRule.skip_callback(:create, :after, :configure_trends)

FacebookRule.skip_callback(:save, :before, :set_provider_value)
FacebookRule.skip_callback(:create, :before, :configure_trends)

Handle.skip_callback(:create, :before, :configure_trends)
Handle.skip_callback(:commit, :after, :fetch_actor_info)
Handle.skip_callback(:validate, :after, :create_mention_rule)
Handle.skip_callback(:validate, :after, :create_from_rule)

[{from: 320, to: 540}, {from: 416, to: 541}, {from: 427, to: 542}, {from: 196, to: 543}, {from: 7, to: 544}, {from: 21, to: 545}].each do |migrate|
#[{from: 411, to: 416}].each do |migrate|
  business  = Business.find(migrate[:from])
  to        = Business.find(migrate[:to])

  to.alerts.delete_all
  to.rules.delete_all
  to.handles.delete_all

  business.rules.each do |rule|
    new_r = Rule.new(
      business_id: to.id,
      raw_value: rule.raw_value, 
      segment: rule.segment,
      category: rule.category,
      source: rule.source
    )
    new_r.save(validate: false)

    rule.alerts.where('created_at > ?', 2.months.ago).each do |a|
      new_a = Alert.new(
        business_id: to.id,
        options: a.options, 
        created_at: a.created_at,
        updated_at: a.updated_at,
        alert_type: a.alert_type,
        type: a.type,
        rule_id: new_r.id,
        context: a.context
      )
      new_a.activities = a.activities
      new_a.save(validate: false)
    end  
  end

  business.handles.each do |handle|
    h = Handle.new(
      business_id: to.id,
      name: handle.name,
      actor_id: handle.actor_id,
      source: handle.source)
    h.save(validate: false)
  end
end