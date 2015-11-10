rule = Rule.find(7485)

posts = Redis::Value.new("#{rule.id}-#{rule.segment}_popular_topic-cache_result", marshal: true)
mean  = Redis::Value.new("#{rule.id}-#{rule.segment}_popular_topic-cache_mean", marshal: true)
search_at = Redis::Value.new("#{rule.id}-#{rule.segment}_popular_topic-search_at", marshal: true)

start_id    = ActivitiesRule.where('created_at > ? AND rule_id = ?', DateTime.now.end_of_day - 1.week, rule.id).reorder('').first.id
end_id      = ActivitiesRule.where('created_at <= ? AND rule_id = ?', DateTime.now.end_of_day, rule.id).reorder('').last.id
index       = 15

query = ActivitiesRule.joins(:rule).joins(:activity).joins(:activity => :actor).where("rules.type LIKE '#{rule[:source].camelize + 'Rule'}'").where("rule_id = ?", rule.id).where('activities_rules.ignored = ?', false).where("activities_rules.id >= ?", start_id).where("activities_rules.id <= ?", end_id).where("activities.verb LIKE 'post'").where("activities.in_reply_to_native_id IS NULL").where("actors.screen_name NOT IN (?)", owned_handles)

unless BusinessOwnedContent.new(rule.business_id).interacted_activities.members.blank?
  query = query.where("activities.id NOT IN (?)", BusinessOwnedContent.new(rule.business_id).interacted_activities.members)
end

actors_alerted  = PopularTopicAlert.actors_alerted_today(rule.business_id)
select          = actors_alerted.empty? ? "activities.favorites_count as score" : "IF(actors.id IN (#{actors_alerted.join(',')}), activities.favorites_count * 0.60, activities.favorites_count) as score"
select          += ", activities.favorites_count, activities_rules.activity_id, activities.actor_id, activities.native_id, activities.created_at"

m_mean = query.select("AVG(activities.favorites_count) as mean").first.mean
m_posts = query.order('score DESC').select(select).limit((index/(PopularTopicAlert.alerts_today(rule.business_id) + 1).to_f).ceil)