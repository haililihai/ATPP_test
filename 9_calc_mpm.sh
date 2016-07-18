#! /bin/bash

PIPELINE=$1
shift
WD=$1
shift
PREFIX=$1
shift
PART=$1
shift
SUB_LIST=$1
shift
MAX_CL_NUM=$1
shift
NIFTI=$1
shift
METHOD=$1
shift
MPM_THRES=$1
shift
VOX_SIZE=$1
shift
LEFT=$1
shift
RIGHT=$1

matlab -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');calc_mpm_group_xmm('${WD}','${PREFIX}','${PART}','${SUB_LIST}',${MAX_CL_NUM},'${METHOD}',${MPM_THRES},${VOX_SIZE},${LEFT},${RIGHT});exit"
