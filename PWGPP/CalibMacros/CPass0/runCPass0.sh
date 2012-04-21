#!/bin/bash

# Script to run:
#    1. reconstruction
#    2. calibration 
#
# Files assumed to be in working directory:
# recCPass0.C          - reconstruction macro
# runCalibTrain.C     - calibration/filtering macro
# Arguments (run locally):
#    1  - raw data file name
#    2  - number of events to be processed
#    3  - run number 
#    4  - OCDBPath
#    5  - optional trigger mask
# example:
# runCPass0.sh raw.root  50  104892 raw://

#ALIEN setting
# $1 = raw input filename
runNum=`echo $1 | cut -d "/" -f 6 | sed 's/^0*//'`
if [ $# -eq 1 ] ; then
  # alien Setup
  nEvents=99999999
  fileName="alien://"$1
  ocdbPath="raw://"
  triggerOption="?Trigger=kCalibBarrel"
fi;
if [ $# -ge 4 ] ; then
  # local setup
  fileName=$1
  nEvents=$2
  runNum=$3
  ocdbPath=$4
  triggerOption="?Trigger=kCalibBarrel"
fi
if [ $# -eq 5 ] ; then
  # local setup in case we provide the trigger mask
  # the trigger mask is first stripped of quotation characters
  triggerOption=${5//\"/}
fi

echo xxxxxxxxxxxxxxxxxxxxxxxxxxx
echo runCPass0.sh Input arguments
echo fileName=$fileName
echo nEvents=$nEvents
echo runNum=$runNum
echo ocdbPath=$ocdbPath
echo triggerOption=$triggerOption
echo xxxxxxxxxxxxxxxxxxxxxxxxxxx

if [ -f Run0_999999999_v3_s0.root ]; then
    mkdir -p TPC/Calib/Correction
    mv Run0_999999999_v3_s0.root TPC/Calib/Correction/
fi



echo File to be  processed $1
echo Number of events to be processed $nEvents

echo ">>>>>>>>> PATH is..."
echo $PATH
echo ">>>>>>>>> LD_LIBRARY_PATH is..."
echo $LD_LIBRARY_PATH
echo ">>>>>>>>> recCPass0.C is..."
#cat recCPass0.C
echo

echo ">>>>>>> Running AliRoot to reconstruct $1. Run number is $runNum..."

aliroot -l -b -q "recCPass0.C(\"$fileName\", $nEvents, \"$ocdbPath\", \"$triggerOption\")" 2>&1 | tee rec.log
mv syswatch.log syswatch_rec.log

echo ">>>>>>> Running AliRoot to make calibration..."
aliroot -l -b -q runCalibTrain.C\(\""$runNum\",\"AliESDs.root\",\"$ocdbPath"\"\)   2>&1 | tee calib.log
mv syswatch.log syswatch_calib.log
