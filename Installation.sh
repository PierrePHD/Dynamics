#!/bin/sh

for iter in Autres Castem Latex Maple Matlab
do
	git clone https://github.com/PierrePHD/Dynamics.git
	mv Dynamics/ $iter/
	cd $iter/
	git checkout -b $iter origin/$iter
	git branch -d master
	cd ..
done

cd Autres
chmod a+x Installation.sh push.sh pull.sh Cluster/scriptJobs.sh
