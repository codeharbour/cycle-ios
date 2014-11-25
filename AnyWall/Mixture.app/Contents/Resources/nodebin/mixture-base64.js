var fs = require("fs");
var mime = require("mime");
var path = require("path");
var input = process.argv[2];

fs.readFile(input, function(err, data) {
            var pattern = /inline-image\(.*?\)/ig;
            var content = data.toString();
            var save = false;
            
            while (matches = pattern.exec(content)) {
            var file = matches[0].replace("inline-image","").replace("(","").replace(")","").replace(/'/g,"").replace(/"/g,"");
                                                                                                     var match = matches[0];
                                                                                                     var lib = path.join(path.dirname(fs.realpathSync(input)), file);
                                                                                                     
                                                                                                     if (fs.existsSync(lib)) {
                                                                                                     save = true;
                                                                                                     var ext = path.extname(lib);
                                                                                                     var data = fs.readFileSync(lib);
                                                                                                     var base64data = new Buffer(data).toString('base64');
                                                                                                     var m = mime.lookup(lib);
                                                                                                     content = content.replace(match, 'url(data:' + m + ';base64,' + base64data + ')');
                                                                                                     }
                                                                                                     }
                                                                                                     
                                                                                                     if (save) {
                                                                                                     fs.writeFileSync(input, content, 'utf8');
                                                                                                     console.log(true);
                                                                                                     } else {
                                                                                                     console.log(false);
                                                                                                     }
                                                                                                     });