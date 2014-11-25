/* Copyright Mixture
 * MIT Licence
 */
var yaml = require('js-yaml');

var input = process.argv[2];

var fs = require('fs');
fs.readFile( input, function (err, data) {
  if (err) {
    throw err; 
  }
  var header = "";
  var body = "";

  //get the stuff from the header only 
  var fullFile = data.toString();
            var str = fullFile.toString().replace(/\r\n/gi, '\n');
            var matches = str.match(/---(.|\n)*?---/gi);
            var yaml_header = "";
            
            if (matches.length > 0){
                yaml_header = matches[0].split("---").join("");
            //throw "Failed "+yaml_header;
                body = str.replace(matches[0], '');
            }
            else{
                throw "Failed to load post data, please check the post is valid";
            }
            
            
           
       
        
  results = [];
  var result = yaml.load(yaml_header, {filename:input,strict: false, json: true});

  results.push(
      result
  );

  results.push(
      body
  );

  console.log(JSON.stringify(results, null, 4));
  
});

