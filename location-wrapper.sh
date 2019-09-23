#!/bin/bash

# Set up Python 2.7
[ -f /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash ] && \
    source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash && \
    module load python/2.7

# Extract the input file
tar -xzf wn-geoip.tar.gz

# Run the geolocation code
cd wn-geoip
PYTHONPATH=src:$PYTHONPATH python src/wn-geoip.py data/GeoLite2-City.mmdb

# cleanup
cd ..
rm -r wn-geoip
