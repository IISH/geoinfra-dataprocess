#add a column to the shapefiles so that we can differentiate between years coming from different files
INPUTDIR=$1;
LOGFILE=$2;
shopt -s nullglob
echo "INPUTDIR IS: ..... $INPUTDIR";
for f in ${INPUTDIR}/*.shp;
do
    #TODO: strip letters, and create integer column (affects downstream steps)
    temp=${f##*/};    
    name=${temp%.shp};
    echo $name;
    ogrinfo $f -sql "ALTER TABLE $name ADD COLUMN date character(21)";
    ogrinfo $f -dialect SQLite -sql "UPDATE $name SET date = '${name}'";
    echo "done $f";
done;

echo "edited all shapefiles" | tee -a $LOGFILE;
