#!/bin/bash
# Script that converts .ds data to .fif
#
# Gustavo Sudre, 01/2013

dataDir='/home/watsonbe/Mary_MEG_data/'
task='rest'

dates=`ls $dataDir`
# for each directory in dataDir, get the list of files in it
for d in $dates 
do
	files=`ls $dataDir/$d`
	# for each file in the date folder, only run MNE if it's rest and it's 
	# not filtered
	for f in $files 
	do
		splitTask=(`echo $f | tr '_' ' '`)
		splitRaw=(`echo $f | tr '-' ' '`)
		if [ ${splitTask[1]} == $task ] && [ ${splitRaw[0]} == $f ]; then
			mne_ctf2fiff --ds $dataDir/$d/$f/ --fif tmp.fif
			mne_rename_channels --fif tmp.fif --alias ~/.mne/renameUPT001toSTI104.txt
			mne_process_raw --raw tmp.fif --projoff --lowpass 100 --highpass 0.6 --decim 2 --grad 3 \
				--save fifs/"$splitTask"_"$task"_LP100_HP0.6_CP3_DS300_raw.fif
		fi
	done
done
rm tmp.fif