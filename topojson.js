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


var getGeojson = function(req, res) {
db.connect()
    .then(function(obj){
        sco = obj;
        
        //modify query to select 1 or multiple countries
        var eqorin, sel;
        console.log(req.query.country.split(',').length);
        if (req.query.country.split(',').length > 1) {
            eqorin = ' IN ';
            sel = "('"+req.query.country.split(',').join("','")+"')";
        } else {
            eqorin = ' = ';
            sel = "'"+req.query.country+"'";
        }
        console.log(eqorin+sel);
        var qu = "SELECT row_to_json(fc) FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features FROM (SELECT 'Feature' As type, ST_AsGeoJSON(lg.geometry)::json As geometry, row_to_json((SELECT l FROM (SELECT (concept_id||extract(year from lower(time))::text) as id, name, lower(time) as begin, upper(time) as end) As l )) As properties FROM geoinfra.entities As lg where source_id = 1 and name"+eqorin+sel+") As f) As fc;";
        return sco.query(qu);
    })
    .then(function(data){
          res.setHeader('Content-Type', 'application/json');
        //build a GeoJSON feature and return it
          data[0].row_to_json.totalFeatures = data[0].row_to_json.features.length;
        //  var tj = makeTopo(data[0].row_to_json);
        //  res.send(tj);
            res.send(data[0].row_to_json);

    })
    .then(null,function(error){
        return res.status(500).send('Internal server error. check your server logs for more details');
    process.exit(1);
    });    
    
    
}

var getCountries = function(req, res) {
    db.connect()
    .then(function(obj){
        sco = obj;
        
        //modify query to select 1 or multiple countries
        var eqorin, sel;
        console.log(req.query.country.split(',').length);
        if (req.query.country.split(',').length > 1) {
            eqorin = ' IN ';
            sel = "('"+req.query.country.split(',').join("','")+"')";
        } else {
            eqorin = ' = ';
            sel = "'"+req.query.country+"'";
        }
        console.log(eqorin+sel);
        var qu = "SELECT row_to_json(fc) FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features FROM (SELECT 'Feature' As type, ST_AsGeoJSON(lg.geometry)::json As geometry, row_to_json((SELECT l FROM (SELECT (concept_id||extract(year from lower(time))::text) as id, name, lower(time) as begin, upper(time) as end) As l )) As properties FROM geoinfra.entities As lg where source_id = 1 and name"+eqorin+sel+") As f) As fc;";
        return sco.query(qu);
    })
    .then(function(data){
          res.setHeader('Content-Type', 'application/json');
        //build a GeoJSON feature and return it
          data[0].row_to_json.totalFeatures = data[0].row_to_json.features.length;
          var tj = makeTopo(data[0].row_to_json);
          res.send(tj);
 //           res.send(data[0].row_to_json);

    })
    .then(null,function(error){
        return res.status(500).send('Internal server error. check your server logs for more details');
    process.exit(1);
    });
    
    
    
}



var makeTopo = function(data){
    var tj = topojson.topology({collection:data},{"property-transform": function(feature){return feature.properties}});
    return tj;
    
    
}

app.get('/', function(req, res) {
  res.send({
    name: 'Demo',
    version: '0.0.0',
    message: 'Returning topojson'
  });
});

app.get('/topojson', getCountries);
app.get('/geojson',getGeojson);
app.listen(8091, function() {
  console.log('Topojson API listening on port 8091');
});


