curl -XGET localhost:9200/activities_v2_week_44/_search?explain=true -d '
{
  "query": { 
      "bool": {
         "should": [
            {
              "more_like_this" : {
                  "fields" : ["body.text"],
                  "docs": [{
                    "_index": "activities_v2_week_44",
                    "_type": "activity",
                    "_id": "443640355323124150"
                  }],
                  "min_word_length": 3,
                  "max_query_terms" : 12,
                  "boost": 2
              }
            },
            {
              "more_like_this" : {
                  "fields" : ["hashtags"],
                  "docs": [{
                    "_index": "activities_v2_week_44",
                    "_type": "activity",
                    "_id": "443640355323124150"
                  }],
                  "min_word_length": 3,
                  "max_query_terms" : 12,
                  "boost": 2
              }
            },
            {
              "more_like_this" : {
                  "fields" : ["urls.text"],
                  "docs": [{
                    "_index": "activities_v2_week_44",
                    "_type": "activity",
                    "_id": "443640355323124150"
                  }],
                  "min_word_length": 3,
                  "max_query_terms" : 12,
                  "boost": 3
              }
            },
            {
              "more_like_this" : {
                  "fields" : ["handles.text"],
                  "docs": [{
                    "_index": "activities_v2_week_44",
                    "_type": "activity",
                    "_id": "443640355323124150"
                  }],
                  "min_word_length": 3,
                  "max_query_terms" : 12,
                  "boost": 1
              }
            }
          ]
      }
  }
}'

curl -XGET localhost:9200/activities_v2_week_44/_search?explain=true -d '
{
  "query": { 
    "bool": {
      "must": {
        "term": { "verb": "post", "boost": 2.0 }
      },
      "should": [{
        "more_like_this" : {
            "fields" : ["body.full_text"],
            "docs": [{
              "_index": "activities_v2_week_44",
              "_type": "activity",
              "_id": "443640355323124150"
            }],
            "analyzer": "standard",
            "min_word_length": 3,
            "max_query_terms" : 12
        }
      },
      {
        "terms" : { "hashtags" : ["cavs"], "boost": 2.0}
      },
      {
        "terms" : { "handles" : ["lebronjames"], "boost": 2.0}
      },
      {
        "fuzzy" : {
          "urls" : {
              "value" :         "https://vine.co/v/eFq2lJaFhL0",
              "boost" :         1.0,
              "fuzziness" :     2,
              "prefix_length" : 0,
              "max_expansions": 100
          }
        }
      }]
    }
  }
}'

curl -XGET localhost:9200/activities_v2_week_44/_search?explain=true -d '
{
  "query": {
    "function_score": {
      "query": {
        "function_score": {
          "query": {
            "bool": {
              "must": [
                {
                  "terms": {
                    "rules.id": [
                      7530,
                      7531,
                      7532,
                      7533,
                      7534,
                      7535,
                      7536,
                      7542,
                      7543,
                      7547
                    ]
                  }
                }
              ],
              "must_not": [
                {
                  "term": {
                    "verb": "share"
                  }
                },
                {
                  "term": {
                    "_id": 443640355322831265
                  }
                }
              ],
              "should": [
                {
                  "match": {
                    "body.text": {
                      "query": "What does luxury mean today? According to execs at @katespadeny and @soulcycle, it depends on whom you ask: https://t.co/fAAHIyJq7D"
                    }
                  }
                },
                {
                  "terms": {
                    "hashtags": []
                  }
                },
                {
                  "terms": {
                    "handles": [
                      "katespadeny",
                      "soulcycle"
                    ]
                  }
                },
                {
                  "match": {
                    "urls.text": "http://fashionista.com/2015/10/nyu-stern-redefining-luxury"
                  }
                }
              ]
            }
          },
          "weight": 100
        }
      },
      "functions": [
        {
          "field_value_factor": {
            "field": "klout",
            "missing": 1,
            "modifier": "log1p"
          }
        },
        {
          "field_value_factor": {
            "field": "reach",
            "missing": 1,
            "modifier": "log1p"
          }
        },
        {
          "field_value_factor": {
            "field": "engagement_score",
            "missing": 1,
            "modifier": "log1p"
          }
        },
        {
          "script_score": {
            "lang": "groovy",
            "script": "sort_verb"
          }
        }
      ],
      "score_mode": "sum"
    }
  }
}'


curl -XGET 'localhost:9200/activities_v2_week_44/_analyze?analyzer=tag_custom' -d 'cavs'
curl -XGET 'localhost:9200/activities_v2_week_44/_analyze?analyzer=url_custom' -d 'https://vine.co/v/eFq2lJaFhL0'
curl -XGET 'localhost:9200/activities_v2_week_44/_analyze?analyzer=body_custom' -d 'What does luxury mean today? According to execs at @katespadeny and @soulcycle, it depends on whom you ask: https://t.co/fAAHIyJq7D'