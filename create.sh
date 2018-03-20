# This script downloads OSM maptiles from the GeoFabrik server and passes 
# it through PlanetSplitter.


# EDIT THIS to set the names of the maptile files to download from GeoFabrik.
files="asia/malaysia-singapore-brunei-latest.osm.bz2"
server="download.geofabrik.de"


# Download the files

for file in $files; do
   wget -N http://$server/$file
done


# Process the data

planetsplitter --errorlog *.osm.bz2