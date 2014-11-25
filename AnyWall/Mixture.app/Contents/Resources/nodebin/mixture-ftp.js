/* Copyright Mixture
 * MIT Licence
 */
var ftpClient = require('ftp'),
walk = require('walk'),
fs = require('fs'),
walker,
options,
dir = process.argv[2],
remoteDir = process.argv[3],
host = process.argv[4],
port = process.argv[5],
user = process.argv[6],
pass = process.argv[7],
ignore = process.argv[8],
secure = process.argv[9],
processed = [],
skipped = [],
ignoreFilter = [];

if (ignore.length > 1)
ignoreFilter = ignore.split(',');

host = host.replace("ftp://","");
host = host.replace("ftps://","");
host = host.replace("http://","");
host = host.replace("https://","");
host = host.replace("ftpes://","");

ignoreFilter.push(".git");
ignoreFilter.push(".globbing");
ignoreFilter.push(".sass-cache");
ignoreFilter.push(".pid");
ignoreFilter.push("mixture.json");
ignoreFilter.push(".gitignore");
ignoreFilter.push(".githubsettings");
ignoreFilter.push(".ftpsettings");
ignoreFilter.push(".s3settings");

var FTP = new ftpClient();

doIt();

var uploadFile = function(path, source, callback) {
	var dirs = path.split('/');
	var total = dirs.length-1;
	var arr = [];
    
	for (var i=0;i<dirs.length;i++) {
		if (i > total) continue;
		arr.push(dirs[i]);
		var newpath = arr.join('/');
		if (i<(dirs.length-1)) {
            
            FTP.mkdir(newpath, function(err) {
                      if (err && err.code != 550)
                      return callback(err, null);
                      });
            
		}else{
            
            FTP.put(source, newpath, function(hadError) {
                    if (!hadError)
                    return callback(null, source);
                    else
                    return callback(hadError, null);
                    });
            
		}
	}
};

var checkFile = function(path, source, callback) {
    
	for(var y in ignoreFilter) {
		if (source.toLowerCase().lastIndexOf(ignoreFilter[y].toLowerCase()) > 1)
			return callback(null, false)
            }
    
	fs.stat(source, function(err, stats) {
            if (err) return callback(null, false);
            
            if (stats.isFile() && source.toLowerCase().lastIndexOf('.') === -1)
            return callback(null, false);
            
            var size = stats.size;
            
            FTP.list(path, function(err2, list) {
                     
                     if (err2) return callback(null, true);
                     
                     if (list.length === 0 ) return callback(null, true);
                     
                     list.forEach(function(file) {
                                  if (size != file.size)
                                  return callback(null, true);
                                  else
                                  return callback(null, false);
                                  });
                     
                     });
            
            });
    
};

function doIt() {
    
    options = { followLinks: false, filters: ignoreFilter };
    
    FTP.on('ready', function() {
           
           FTP.mkdir(remoteDir, function(err) {
                     if (err && err.code != 550) {
                     console.error(err);
                     FTP.end();
                     return;
                     }
                     
                     walker = walk.walk(dir, options);
                     
                     walker.on("file", function (root, fileStats, next) {
                               var rdir = root.toLowerCase().replace(dir.toLowerCase(),"");
                               fs.readFile(fileStats.name, function () {
                                           var me = (remoteDir + rdir + "/" + fileStats.name).replace("//","/");
                                           checkFile(me, root + "/" + fileStats.name, function(err, upload) {
                                                     if (upload) {
                                                     uploadFile(me, root + "/" + fileStats.name, function(err2, path) {
                                                                if (err2) {
                                                                FTP.end();
                                                                console.error(err2);
                                                                }else{
                                                                processed.push(root + "/" + fileStats.name);
                                                                next();
                                                                }
                                                                });
                                                     }else{
                                                     skipped.push(root + "/" + fileStats.name);
                                                     next();
                                                     }
                                                     });
                                           });
                               });
                     
                     walker.on("end", function () {
                               var resp = {};
                               resp.processed = processed.length;
                               resp.skipped = skipped.length;
                               console.log(JSON.stringify(resp, null, 4));
                               FTP.end();
                               });
                     
                     });
           });
    
    FTP.on("error", function(err) {
           console.error(err);
           FTP.destroy();
           });
    
    var secureOptions = { rejectUnauthorized: false };
    
    if (secure === "true")
        secure = true;
    else
        secure = false;
    
    FTP.connect({ host: host, port: port, user: user, password: pass, secure: secure, secureOptions: secureOptions });
    
}