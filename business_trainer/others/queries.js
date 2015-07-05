module.exports = (function () {
  var twitterQuery = [];
  twitterQuery.push('SELECT r1.* ');
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
  twitterQuery.push('LIMIT :limit; ');

  var instagramQuery = [];
  instagramQuery.push('SELECT a.*');
  instagramQuery.push('FROM rules');
  instagramQuery.push('JOIN activities_rules AS ar');
  instagramQuery.push('  ON ar.rule_id = rules.id');
  instagramQuery.push('JOIN activities AS a');
  instagramQuery.push('  ON a.id = ar.activity_id');
  instagramQuery.push('JOIN (SELECT ');
  instagramQuery.push('    (');
  instagramQuery.push('      (SELECT MIN(id) FROM activities) + ');
  instagramQuery.push('      RAND() *');
  instagramQuery.push('      (SELECT (SELECT MAX(id) FROM activities) - (SELECT MIN(id) FROM activities))');
  instagramQuery.push('    ) AS id');
  instagramQuery.push('  ) AS random');
  instagramQuery.push('WHERE rules.source = \'instagram\'');
  instagramQuery.push('  AND a.id >= random.id');
  instagramQuery.push('ORDER BY a.id DESC');
  instagramQuery.push('LIMIT 100;');

  return {
    getActivities: function (source, limit) {
      if (source === 'twitter') {
        return twitterQuery.join('\r').replace(':limit', limit);
      } else {
        return instagramQuery.join('\n').replace(':limit', limit);
      }
    }
  };
}());