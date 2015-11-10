from  = DateTime.now.utc - 1.day
to    = DateTime.now.utc

# Elastic Search query
body_search = {
#  from: 0,
#  size: 50,
  query: {
    bool: {
      must: [
        { range: { created_at: { from: from, to: to } } },
        #{ term:  { verb: 'post' } },
        { terms: { urls: ['http://www.designboom.com/architecture/beijing-design-week-bjdw-spark-architects-jianzi-box-pavilion-09-21-2015'] } },
        { terms: { 'rules.id' => [431] } }
      ],
      must_not: { term: { posting_handles: { value: '*follow*' } } }
    }
  },
  size: 10
  # ,
  # aggs: {
  #   reach_per_day: {
  #     date_histogram: {
  #       field: "created_at",
  #       interval: "1h",
  #       format: "yyyy-MM-dd-HH",
  #       min_doc_count: 0
  #     }
  #   }
  # }
}

# Query execution
search = $elasticsearch.search(
  from: 0,
  size: 50,
  index: ElasticsearchHelper.activities_indexes(from, to),
  #search_type: 'count',
  body: body_search
)

activities_ids = search['hits']['hits'].map{|h| h['_source']['id'].to_i}
count = search['hits']['total']
related = Activity.where(id: activities_ids).where(verb: 'post').count