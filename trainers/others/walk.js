var fs = require('fs');
var path = require('path');
var walk = function (dir) {
  var 
    results = [],
    list = fs.readdirSync(dir);
    list.forEach(function (file) {
      file = path.join(dir, '/', file);
      var stat = fs.statSync(file);
      if (stat && stat.isDirectory()) {
        results = results.concat(walk(file));
      } else {
        results.push(file);
      }
    });
  return results;
}

module.exports = walk;