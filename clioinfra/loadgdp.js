var pgLib = require('pg-promise');
var R = require('rsvp');
var mnmst = require('minimist');
var fs = require('fs');


var args = mnmst(process.argv.slice(2));

console.log('args!!!!!!!!!!!!!!');
console.log(args._);
var pgp = pgLib();

var cn = "postgres://"+args.u+":"+args.p+"@localhost:5432/geo";

var db = pgp(cn);

console.log(args.i);

var qu = "copy geoinfra.gdp from '"+args.i+"' csv header delimiter ';';"; 
console.log(qu);

db.connect()
.then(function(obj){
	sco = obj;
	//return sco.query("select * from bag.adres limit 1;");
	return sco.query(qu);
})
.then(function(data){
	console.log(data);
	console.log('HI!!!!');
	fs.writeFileSync(args.o, data[0]);
	process.exit();
})
.then(null,function(error){
	console.log(error)
process.exit(1);
});


