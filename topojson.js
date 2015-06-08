var express = require('express');
var app = express();
var pgLib = require('pg-promise');
var R = require('rsvp');
var mnmst = require('minimist');
var topojson = require('topojson');

var args = mnmst(process.argv.slice(2));
var pgp = pgLib();
var cn;
if (args.u && args.p){
    cn = "postgres://"+args.u+":"+args.p+"@localhost:5432/geo";
} else {
    console.log('need a username and password: node index.js -u USERNAME -p PASSWORD');
    process.exit(0);
}
var db = pgp(cn);


//fetch GeoJSON from database
var getGeoJson = function(req, res) {
    var promise = new R.Promise(function(resolve,reject) {
        db.connect()
        .then(function(obj){
            sco = obj;

            //modify query to select 1 or multiple countries
            console.log(req.url);
            console.log(req.params);
            var eqorin, sel, andname, timerange;
            if (req.query && req.query.country) {
                andname = 'and name';
                console.log('fooo');
                console.log(req.query.country.split(',').length);
                if (req.query.country.split(',').length > 1) {
                    eqorin = ' IN ';
                    sel = "('"+req.query.country.split(',').join("','")+"')";
                } else {
                    eqorin = ' = ';
                    sel = "'"+req.query.country+"'";
                }
            } else if (req.params.name) {
                console.log('hoi');
                eqorin = ' = ';
                sel = "'"+req.params.name+"'";
                andname = ' and name ';
            } else {
                eqorin = '';
                sel = '';
                andname = '';
            }
            
            if (req.query.year) {
                timerange = "and time && daterange('"+req.query.year+"-01-01','"+req.query.year+"-12-31')";
            } else if (req.query.start_year && req.query.end_year) {
                timerange = "and time && daterange('"+req.query.start_year+"-01-01','"+req.query.end_year+"-12-31')";
                
            } else {
                timerange = "and time && daterange('2012-01-01','2012-12-31')";
            }
            
            console.log(andname+eqorin+sel+timerange);
            var qu = "SELECT row_to_json(fc) FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features FROM (SELECT 'Feature' As type, ST_AsGeoJSON(lg.geometry, 6, 0)::json As geometry, row_to_json((SELECT l FROM (SELECT (concept_id||extract(year from lower(time))::text) as id, name, lower(time) as begin, upper(time) as end) As l )) As properties FROM geoinfra.entities As lg where source_id in (1, 2)"+andname+eqorin+sel+timerange+") As f) As fc;";
            return sco.query(qu);
        })
        .then(function(data){
            resolve(data);
        })
        .then(null,function(error){
            console.log(error);
            return res.status(500).send('Internal server error. check your server logs for more details');
        process.exit(1);
        });    
    });
    return promise;
    
}


var getCountries = function(req, res) {
    console.log(req.params);
    getGeoJson(req, res)
    .then(function(data){
        res.setHeader('Content-Type', 'application/json');
        //build a GeoJSON feature and return it
        data[0].row_to_json.totalFeatures = data[0].row_to_json.features.length;
        if (req.query.format && req.query.format == 'topojson') {
            res.send(makeTopo(data[0].row_to_json));
        } else {
            res.send(data[0].row_to_json);
        }
    })
    .then(null,function(error){
        console.log(error);
        return res.status(500).send('Internal server error. check your server logs for more details');
    process.exit(1);
    });
    
    
}

var getCountriesAsTopoJson = function(req, res) {
    getGeoJson(req, res)
    .then(function(data){
          res.setHeader('Content-Type', 'application/json');
        //build a GeoJSON feature and return it
          data[0].row_to_json.totalFeatures = data[0].row_to_json.features.length;
          var tj = makeTopo(data[0].row_to_json);
          res.send(tj);
 //           res.send(data[0].row_to_json);

    })
    .then(null,function(error){
        console.log(error);
        return res.status(500).send('Internal server error. check your server logs for more details');
    process.exit(1);
    });
    
    
    
}



var makeTopo = function(data){
    var tj = topojson.topology({countries:data},{"property-transform": function(feature){return feature.properties}});
    return tj;
    
    
}

app.get('/', function(req, res) {
  res.send({
    name: 'Demo',
    version: '0.0.0',
    message: 'Returning geojson and topojson'
  });
});

app.get('/countries/:name?/', getCountries);

//unneeded if we use format query param; /countries can handle both then.
app.get('/topojson', getCountriesAsTopoJson);
app.get('/geojson',getGeoJson);
app.listen(8091, function() {
  console.log('Topojson API listening on port 8091');
});


