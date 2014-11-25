/* Copyright Mixture

 * MIT Licence

 */

var autoprefixer = require('autoprefixer'),

        fs = require('fs'),

        path = require('path'),

        browsers = process.argv[2],

        input = process.argv[3],

        map = process.argv[4],

        from = process.argv[5],

        to = process.argv[6];



var options;



map = (map === 'false' || map === undefined) ? false : true; 



if(browsers != null && browsers != '') {

    options = browsers.split(',').map(function (i) {

        return i.trim();

    });

}



fs.readFile(input, function (err, css) {




    result = autoprefixer.apply(null, options).process(css.toString(), { map: map, to: to.toString() });



    if (result.css && result.css != undefined)
        console.log(result.css);
    else
        console.log('');


});

