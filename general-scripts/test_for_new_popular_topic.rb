rule_id = 7480

def most_retweeted_tweets rule_id
  from = 8.days.ago.to_datetime
  to   = DateTime.yesterday.end_of_day.to_datetime - 10.minutes

  # Elastic Search query
  body_search = {
    size: 0,
    query: {
      bool: {
        must: [
          { range: { created_at: { from: from, to: to } } },
          { terms: { "rules.id" => [rule_id] } } 
        ]
      }
    },
    aggs: {
      total_activities: {
        terms: { 
          field: "shared_native_id",
          size: 0
        }
      },
      big_klouts: {
        filter: { range: { klout: { gte: 60 } } },
        aggs: {
          total_activities: {
            terms: { 
              field: "shared_native_id",
              size: 0
            }
          }
        }
      }
    }
  }

  # Query execution
  search = $elasticsearch.search(
    size: 0,
    index: ElasticSearch.activities_indexes(from, to),
    search_type: 'count',
    body: body_search
  )

  count = search['aggregations']['total_activities']['buckets'].map{|t| { native_id: t['key'], total_count: t['doc_count']} }
  big_count = search['aggregations']['big_klouts']['total_activities']['buckets'].map{|t| { native_id: t['key'], total_big_count: t['doc_count']} }

  (count+big_count).group_by{|h| h[:native_id]}.map{|k,v| v.reduce(:merge)}
end

def tweets_features tweets
  result =[]

  tweets.each do |tweet|
    activity = Activity.joins(:actor).find_by(native_id: tweet[:native_id])
    from  = activity.created_at.to_datetime.utc
    to    = [from + 15.minutes, DateTime.now - 10.minutes].min.to_datetime

    # Elastic Search query
    body_search = {
      query: {
        bool: {
          must: [
            { range: { created_at: { from: from, to: to } } },
            { term: { verb: 'share' } },
            { term: { shared_native_id: tweet[:native_id] } }
          ]
        }
      },
      aggs: {
        avg_klout: { avg: { field: "klout" } },
        sum_klout: { sum: { field: "klout" } },
        big_count: { filter: { range: { klout: { gte: 60 } } } }
      }
    }

    # Query execution
    search = $elasticsearch.search(
      index: ElasticSearch.activities_indexes(from, to),
      search_type: 'count',
      body: body_search
    )

    tweet[:listed_count] = activity.actor.listed_count
    tweet[:avg_klout] = search['aggregations']['avg_klout']['value'].to_f
    tweet[:sum_klout] = search['aggregations']['sum_klout']['value'].to_f
    tweet[:big_count] = search['aggregations']['big_count']['doc_count'].to_i
    tweet[:count] = search['hits']['total'].to_i
    tweet[:link] = activity.link
    tweet[:followers] = activity.actor.followers_count
    tweet[:log_followers] = Math.log(activity.actor.followers_count) || 1
    tweet[:total_count] = activity.share_count
    tweet[:score] = tweet[:count]/tweet[:log_followers].to_f

    result << tweet
  end

  result
end

def print_results top
  puts "native_id\ttotal_count\ttotal_big_count\tcount\tbig_counts\tfollowers\tlog_followers\tlisted_count\tscore\tlink"
  puts top.map{|t| "#{t[:native_id]}\t#{t[:total_count]}\t#{t.try(:[], :total_big_count) || 0}\t#{t[:count].to_i}\t#{t[:big_count].to_i}\t#{t[:followers].to_s}\t#{t[:log_followers].round(2).to_s.gsub('.', ',')}\t#{t[:listed_count].to_i}\t#{t[:score].to_s.gsub('.', ',')}\t#{t[:link]}"}.join("\n")
end

# def tweets_histogram tweet_id, bin_size=60
#   from  = Activity.find_by(native_id: tweet_id).created_at.to_datetime.utc
#   to    = from + 15.minutes

#   # Elastic Search query
#   body_search = {
#     query: {
#       bool: {
#         must: [
#           { range: { created_at: { from: from, to: to } } },
#           { term: { shared_native_id: tweet_id } }
#         ]
#       }
#     },
#     aggs: {
#       activities_per_timeframe: {
#         date_histogram: {
#           field: "created_at",
#           interval: "#{bin_size}s",
#           min_doc_count: 0
#         }
#       }
#     }
#   }

#   # Query execution
#   search = $elasticsearch.search(
#     index: ElasticSearch.activities_indexes(from, to),
#     search_type: 'count',
#     body: body_search
#   )

#   # Query return map for relevant values
#   search['aggregations']['activities_per_timeframe']['buckets'].map{|e| e['doc_count']}
# end

def generate_top_articles rule_id
  tweets = most_retweeted_tweets rule_id
  top = tweets_features tweets
  #tweets_histogram top.map{|t| t[:native_id]}
  print_results top
end

# tweets_features tweets

# top.each{|t| h = tweets_histogram(t[:native_id]); t[:histogram] = h; p t}

generate_top_articles rule_id

