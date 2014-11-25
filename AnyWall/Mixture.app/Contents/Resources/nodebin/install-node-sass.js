var fs = require('fs'), path = require('path');

fs.lstat(path.resolve(__dirname + '../../node-sass'), function(err, stats) {
  if (!err && stats.isDirectory()) {
    console.log("node-sass is already installed");
  }
  else
  {
    var npm = require("npm");
    //npm.load(function (er, npm) {
    //  npm.install("node-sass");
    //});
    npm.load(function (er, npm) {
      if (er) return console.error(er);
      npm.commands.install(["node-sass"], function (er, data) {
        if (er) return console.error(er);
        console.log("successfully installed node-sass");
      })
      //npm.on("log", function (message) { .... })
    })
  }
});