def generate
  time_start = DateTime.now - 1.days
  time_end = DateTime.now
  range = [time_start].tap{ |array| array << array.last + 15.minutes while array.last < time_end }

  Business.active.map{|b| b.rules}.flatten.map{|r| r}.each do |rule|
    range.each do |to|
      from = to - 2.hours

      top = $elasticsearch.search({
        index: ElasticsearchHelper.activities_indexes(from, to),
        search_type: 'count',
        body: {
          query: {
            bool: {
              must: [
                { range: { created_at: { from: from, to: to } } },
                { terms: { 'rules.id' => [rule.id] } }
              ]
            }
          },
          aggs: {
            urls: {
              terms: {
                exclude: RedisBusiness.new(rule.business_id).stopwords,
                field: 'urls'
              }
            }
          }
        }
      })

      urls = top['aggregations']['urls']['buckets'].map{|r| r['key']}.take(5)

      urls.each do |h|
        # Elastic Search query
        body_search = {
          query: {
            bool: {
              must: [
                { range: { created_at: { from: from, to: to } } },
                { terms: { urls: [h] } },
                { terms: { 'rules.id' => [rule.id] } }
              ]
            }
          },
          size: 10,
          aggs: {
            count_per_interval: {
              date_histogram: {
                field: "created_at",
                interval: "15m",
                min_doc_count: 0, 
                extended_bounds: { 
                    min: from,
                    max: to
                }
              }
            }
          }
        }

        # Query execution
        result = $elasticsearch.search(
          from: 0,
          size: 50,
          index: ElasticsearchHelper.activities_indexes(from, to),
          search_type: 'count',
          body: body_search
        )

        histogram = parse_data(result).map{|v| v[:value]}
        histogram = Array.new([8-histogram.count, 0].max, 0) + histogram

        puts "#{to}\t#{rule.id}\t#{h}\t#{histogram.join("\t")}"
      end
    end
  end
end

def parse_data result
  data = []
  result.try(:[], 'aggregations').try(:[], 'count_per_interval').try(:[], 'buckets').try(:each) do |b|
    time_str = b['key_as_string'].match(/\d\d:\d\d/)[0]
    label = Time.parse(time_str).strftime('%I:%M:%P')
    data << { 
      value: b['doc_count'], 
      label: label
    }
  end
  data
end