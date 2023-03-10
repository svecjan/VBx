#!/bin/bash

# INSTRUCTION=xvectors
# INSTRUCTION=diarization
INSTRUCTION=xvec_diar
METHOD="AHC+VB" #$2 # AHC or AHC+VB
SET=dev
# SET=eval

exp_dir=$1 # output experiment directory
xvec_dir=$2 # output xvectors directory
# WAV_DIR=$5 # wav files directory
# FILE_LIST=$6 # txt list of files to process
# LAB_DIR=$7 # lab files directory with VAD segments
# RTTM_DIR=$8 # reference rttm files directory

# Fede setup (matylda4)
# WAV_DIR=/mnt/matylda4/landini/data/DIHARD2019/wavs/single_channel/$SET
# FILE_LIST=/mnt/matylda4/landini/data/DIHARD2019/lists/single_channel/"$SET"_SCH_2019_files.txt
# LAB_DIR=/mnt/matylda4/landini/data/DIHARD2019/sad/single_channel/$SET
# RTTM_DIR=/mnt/matylda4/landini/data/DIHARD2019/rttms/ORIGINAL/single_channel/$SET

# Fede setup (scratch)
WAV_DIR=/mnt/scratch/tmp/isvecjan/DIHARD2019/wavs/single_channel/$SET
FILE_LIST=/mnt/scratch/tmp/isvecjan/DIHARD2019/lists/single_channel/"$SET"_SCH_2019_files.txt
LAB_DIR=/mnt/scratch/tmp/isvecjan/DIHARD2019/sad/single_channel/$SET
RTTM_DIR=/mnt/scratch/tmp/isvecjan/DIHARD2019/rttms/ORIGINAL/single_channel/$SET

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PREDICT_SCRIPT=$DIR/VBx/predict.py
# PREDICT_SCRIPT=$DIR/VBx/predict.resnet_split.py

if [[ $INSTRUCTION = "xvec_diar" ]] || [[ $INSTRUCTION = "xvectors" ]]; then
	WEIGHTS_DIR=$DIR/VBx/models/ResNet101_16kHz/nnet
	if [ ! -f $WEIGHTS_DIR/raw_81.pth ]; then
	    cat $WEIGHTS_DIR/raw_81.pth.zip.part* > $WEIGHTS_DIR/unsplit_raw_81.pth.zip
		unzip $WEIGHTS_DIR/unsplit_raw_81.pth.zip -d $WEIGHTS_DIR/
	fi

	WEIGHTS=$DIR/VBx/models/ResNet101_16kHz/nnet/raw_81.pth
	EXTRACT_SCRIPT=$DIR/VBx/extract.sh
	DEVICE=cpu

	mkdir -p $xvec_dir
	$EXTRACT_SCRIPT ResNet101 $WEIGHTS $WAV_DIR $LAB_DIR $FILE_LIST $xvec_dir $DEVICE $PREDICT_SCRIPT

	# Replace this to submit jobs to a grid engine
	# bash $xvec_dir/xv_task
	manage_task.sh -sync yes -tc 200 $xvec_dir/xv_task
fi


BACKEND_DIR=$DIR/VBx/models/ResNet101_16kHz
if [[ $INSTRUCTION = "xvec_diar" ]] || [[ $INSTRUCTION = "diarization" ]]; then
	TASKFILE=$exp_dir/diar_"$METHOD"_task
	OUTFILE=$exp_dir/diar_"$METHOD"_out
	rm -f $TASKFILE $OUTFILE
	mkdir -p $exp_dir/lists

	thr=-0.015
	smooth=7.0
	lda_dim=128
	Fa=0.2
	Fb=6
	loopP=0.35
	OUT_DIR=$exp_dir/out_dir_"$METHOD"
	if [[ ! -d $OUT_DIR ]]; then
		mkdir -p $OUT_DIR
		while IFS= read -r line; do
			grep $line $FILE_LIST > $exp_dir/lists/$line".txt"
			# python3="unset PYTHONPATH ; unset PYTHONHOME ; export PATH=\"/mnt/matylda5/iplchot/python_public/anaconda3/bin:$PATH\""
			echo "source /mnt/matylda3/isvecjan/miniconda3/bin/activate /mnt/matylda3/isvecjan/miniconda3/envs/VBx ; python $DIR/VBx/vbhmm.py --init $METHOD --out-rttm-dir $OUT_DIR/rttms --xvec-ark-file $xvec_dir/xvectors/$line.ark --segments-file $xvec_dir/segments/$line --plda-file $BACKEND_DIR/plda --xvec-transform $BACKEND_DIR/transform.h5 --threshold $thr --init-smoothing $smooth --lda-dim $lda_dim --Fa $Fa --Fb $Fb --loopP $loopP" >> $TASKFILE
		done < $FILE_LIST
		# bash $TASKFILE > $OUTFILE
		manage_task.sh -sync yes -tc 20 $TASKFILE

		# Score
		cat $OUT_DIR/rttms/*.rttm > $OUT_DIR/sys.rttm
		cat $RTTM_DIR/*.rttm > $OUT_DIR/ref.rttm
		$DIR/dscore/score.py --collar 0.25 -r $OUT_DIR/ref.rttm -s $OUT_DIR/sys.rttm > $OUT_DIR/result_fair
		$DIR/dscore/score.py --collar 0.0 -r $OUT_DIR/ref.rttm -s $OUT_DIR/sys.rttm > $OUT_DIR/result_full
	fi
fi