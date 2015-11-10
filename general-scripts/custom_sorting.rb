from  = DateTime.now.utc - 24.hours
to    = DateTime.now.utc

body_search = {
#  from: 0,
#  size: 50,
  query: {
    function_score: {
      query: {
        constant_score: {
          query: {
            bool: {
              must: [
                { range: { created_at: { from: from, to: to } } },
                { terms: { hashtags: ['fuckwalmart'] } },
                { term: { verb: 'post' } }
              ]
            }
          },
          boost: 1
        }    
      },
      functions: [
        {
          field_value_factor: {
            field: 'klout',
            missing: 1,
            modifier: 'log1p'
          }
        },
        {
          field_value_factor: {
            field: 'reach',
            missing: 1,
            modifier: 'log1p'
          }
        },
        {
          field_value_factor: {
            field: 'engagement_score',
            missing: 1,
            modifier: 'log1p'
          }
        },
        script_score: {
          lang: "groovy",
          script: "sort_verb"
        }
      ],
      score_mode: "sum"
    }
  },
  size: 6
}

ap body_search.to_json

# Query execution
search = $elasticsearch.search(
  from: 0,
  size: 50,
  index: ElasticsearchHelper.activities_indexes(from, to),
  #search_type: 'explain',
  body: body_search
)

