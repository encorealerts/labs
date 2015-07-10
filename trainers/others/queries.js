module.exports = (function () {
  var twitterQuery = [];
  twitterQuery.push('SELECT acs.*');
  twitterQuery.push('FROM activities AS acs');
  twitterQuery.push('JOIN (SELECT r1.id, r1.actor_id ');
  twitterQuery.push(' FROM activities AS r1 JOIN');
  twitterQuery.push('    (SELECT ');
  twitterQuery.push('      (');
  twitterQuery.push('        (SELECT MIN(id) FROM activities) + ');
  twitterQuery.push('        RAND() *');
  twitterQuery.push('        (SELECT (SELECT MAX(id) FROM activities) - (SELECT MIN(id) FROM activities))');
  twitterQuery.push('      ) AS id)');
  twitterQuery.push('    AS r2');
  twitterQuery.push('WHERE r1.id >= r2.id');
  twitterQuery.push('    AND r1.verb = \'post\'');
  twitterQuery.push('    AND r1.source = \'twitter\'');
  twitterQuery.push('ORDER BY r1.id ASC');
  twitterQuery.push('LIMIT :multipliedLimit) as ids');
  twitterQuery.push('WHERE');
  twitterQuery.push('  ids.id = acs.id');
  twitterQuery.push('GROUP BY');
  twitterQuery.push('  acs.actor_id');
  twitterQuery.push('LIMIT :limit;');

  var instagramQuery = [];
  instagramQuery.push('SELECT a.* FROM');
  instagramQuery.push('activities AS a');
  instagramQuery.push('JOIN (');
  instagramQuery.push('  SELECT ar.activity_id AS id');
  instagramQuery.push('  FROM rules');
  instagramQuery.push('  JOIN activities_rules AS ar');
  instagramQuery.push('    ON ar.rule_id = rules.id');
  instagramQuery.push('  JOIN (SELECT ');
  instagramQuery.push('      (');
  instagramQuery.push('        (SELECT MIN(id) FROM activities) + ');
  instagramQuery.push('        RAND() *');
  instagramQuery.push('        (SELECT (SELECT MAX(id) FROM activities) - (SELECT MIN(id) FROM activities))');
  instagramQuery.push('      ) AS id');
  instagramQuery.push('    ) AS random');
  instagramQuery.push('  WHERE rules.source = \'instagram\'');
  instagramQuery.push('    AND ar.activity_id >= random.id');
  instagramQuery.push('  ORDER BY ar.activity_id DESC');
  instagramQuery.push('  LIMIT :limit');
  instagramQuery.push(') AS ids');
  instagramQuery.push('WHERE a.id = ids.id');
  instagramQuery.push('LIMIT :limit;');

  return {
    getActivities: function (source, limit) {
      if (source === 'twitter') {
        return twitterQuery.join('\r').replace(':limit', limit).replace(':multipliedLimit', limit * 10);
      } else {
        return instagramQuery.join('\n').replace(':limit', limit);
      }
    }
  };
}());