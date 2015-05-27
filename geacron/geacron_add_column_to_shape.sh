#add a column to the shapefiles so that we can differentiate between years coming from different files
INPUTDIR=$1;
for f in $INPUTDIR/*.shp;
do
    #TODO: strip letters, and create integer column (affects downstream steps)
    name=${f%.shp};
    ogrinfo $f -sql "ALTER TABLE $name ADD COLUMN date character(21)";
    ogrinfo $f -dialect SQLite -sql "UPDATE $name SET date = '${name}'";
done;
