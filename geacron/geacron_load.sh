#load geacron shapefiles into single postgres table
user=$1;
password=$2;
INPUTDIR=$3;
LOGFILE=$4;

#We can't use lco's because we're updating/appending.

export PG_USE_COPY=YES;
for f in $INPUTDIR/*.shp;
do
    ogr2ogr -progress -update -append -f "PostgreSQL" PG:"dbname='geo' host='localhost' port='5432' user='$user' password='$password' active_schema=geoinfra" $f -nln geacron_import -nlt POLYGON | tee -a $LOGFILE;
done;
