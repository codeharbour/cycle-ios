var sass = require('node-sass');
sass.render({
    data: 'body{background:blue; a{color:black;}}',
    success: function(css){
        console.log(css)
    },
    error: function(error) {
        console.log(error);
    },
    includePaths: [ 'lib/', 'mod/' ],
    outputStyle: 'compressed'
});