var express = require('express');
var app = express();

var webSitePort = 8080;

// Now we can load static files
app.use(express.static('public'));

app.get('/', function (req, res) {
	//res.send('Hello World!');
	res.sendFile(path.join(__dirname + 'public/index.html'));
});

app.listen(webSitePort, function () {
	console.log('Example app listening on port ' + webSitePort + '!');
});
