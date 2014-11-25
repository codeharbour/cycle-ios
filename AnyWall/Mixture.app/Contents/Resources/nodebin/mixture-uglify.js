/* Copyright Mixture
 * MIT Licence
 */
var uglify = require('uglify-js');

var input = process.argv[2];

var result = uglify.minify(input, {mangle: true, comments: true});

console.log(result.code);