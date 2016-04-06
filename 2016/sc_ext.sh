#!/bin/bash

# sed \1d FileOUT.csv > FileMat.csv
 /Applications/MATLAB_R2012a.app/bin/matlab -nodesktop -nodisplay -r "matSVD($1,$2,$3)"
