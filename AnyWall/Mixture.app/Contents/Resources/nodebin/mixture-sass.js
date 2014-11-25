var fs = require('fs');

var input = process.argv[2];
var debug = process.argv[3];
var loadPaths = process.argv[4].split(',');

var sass = require('node-sass');

if (debug == undefined)
  debug = false;

fs.readFile(input, 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }

  sass.render({
    data: data,
    success: function(css){
        console.log(css)
    },
    error: function(error) {
        console.error(error);
    },
    debug: debug,
    includePaths: loadPaths
  });
});