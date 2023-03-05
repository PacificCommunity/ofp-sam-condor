#!/bin/bash

MFCL=./mfclo64

FRQ=swo.frq

INI=swo.ini

echo "HERE0"
echo $MFCL
echo "HERE01"
#------------------------
#  PHASE 0 - create initial par file
#  ------------------------
#
if [ ! -f 00.par ]; then
   echo "HERE02"
   $MFCL $FRQ $INI  00.par -makepar
   echo "HERE03"
fi
echo "HERE1"
#exit
#  ------------------------
#  PHASE 1 - initial par
#  ------------------------
#
if [ ! -f 01.par ]; then
  echo PHASE1
  $MFCL  $FRQ 00.par 01.par -file - <<PHASE1
  1 32 6          # Set control phase: keep growth parameters fixed use - set_shark_no_vonb_control_switches()
  1 12 0          # Turn off growth estimation
  1 13 0          # Turn off growth estimation
#
# Population scaling
  2 32 1          # estimate the totpop parameter
  2 113 0         # scaling init pop - turned off
  2 177 1         # use old totpop scaling method
#
# Recruitment
  2 30 1          # Estimate total recruitment devs (temporal)
  1 149 100       # recruitment deviations penalty
  2 57 1          # sets no. of recruitments per year to 1
  2 93 1          # sets no. of recruitments per year to 1 (is this used?)
  2 178 1         # set constraint on sum_reg (reg_rec_diff * pop_delta) = 1 for all t
#
# Initial population
  2 69 1          # sets generic movement option (now default)
  2 94 2          # Init. pop strategy based upon Z
  2 95 20  # initial age structure based on Z for 1st 20 periods
#
# Selectivities
  -999 26 2       # sets length-dependent selectivity option
# sets decreasing (cubic) selectivity for most longline fisheries
 -999 57 3        # uses cubic spline selectivity
  -999 61 5
# sets non-decreasing (logistic) selectivity for southern longline fisheries
#  -3 61 0
#  -10 57 1         # logistic for DW_2S fishery
#  -10 61 0
# grouping of fisheries with common selectivity
  -1 24 1
  -2 24 2
  -3 24 3
  -4 24 4
  -5 24 5
  -6 24 6
  -7 24 7
  -8 24 7
  -9 24 8
  -10 24 9
  -11 24 10
  -12 24 11
  -13 24 12
# Set grouping of fisheries with common catchability at start of time series
  -1 60 1
  -2 60 2
  -3 60 3
  -4 60 4
  -5 60 5
  -6 60 6
  -7 60 7
  -8 60 8
  -9 60 9
  -10 60 10
  -11 60 11
  -12 60 12
  -13 60 13
# grouping of fisheries with common catchability
  -1 29 1
  -2 29 2
  -3 29 3
  -4 29 4
  -5 29 5
  -6 29 6
  -7 29 7
  -8 29 8
  -9 29 9
  -10 29 10
  -11 29 11
  -12 29 12
  -13 29 13
# sets penalties for effort deviations (negative penalties force effort devs
# to be zero when catch is unknown)
 -999 13 -3      # higher for longline fisheries where effort is standardized
  -1 13 -3
  -2 13 1
  -3 13 -3
  -4 13 1
  -5 13 -3
  -6 13 -3
  -7 13 1
  -8 13 1
  -9 13 -3
  -10 13 -3
  -11 13 1
  -12 13 -3
  -13 13 -3
## use time varying effort weight for LL fisheries
 -999 66 0
  -2 66 1
  -4 66 1
  -7 66 1
  -8 66 1
  -11 66 1
# sets penalties for catchability deviations
   -999 15 50       # default penalty
#
# Fishing mortality max
  2 116 70        # default value for rmax in the catch equations
#
# Relative weight of size data
  -999 49 20  # old comment:  # divide LL LF sample sizes by 20 (default=10)
  -999 50 20  # old comment:  # divide LL WF sample sizes by 20 (default=10)
#
# Size data likelihood assumption
  1 141 3         # sets likelihood function for LF data to normal
  1 139 3         # sets likelihood function for WF data to normal (YT 2017/02/28)
#
# steepness
  2 162 0         # no estimation of steepness
# -3 57 1   # logistic DW1S
# -3 75 2
# -10 57 1  # logistic DW2S
# -10 75 2
 -1 57 3 # default=cubitc spline
########## Dome shape
 -1  61 3  -1 3 15  #-1 75 1 # -1 16 2
 -2  61 3  -2 3 15  -2 75 1 # -2 16 2
# -3  61 3   -3 16 1  # -3 75 1 #  -3  57 1  -3 3 15  -3 75 2       #  logistic DW1S
 -3  57 3 -3 61 5   -3 16 1  # -3 3 15  
 -4  61 3  -4 71 1  # Fish 4 have 2 time blocks
 -5  61 3  -5 3 15  # -5 75 1 # 
 -6  61 3  -6 3 15   # -7 16 2
 -7  61 3  -7 3 19  -7 75 2  -7 16 2 #-7 75 2
 -8  61 3  -8 3 19  -8 75 2  -8 16 2 #-8 75 2
 -9 57 1  -9 3 15  -9 75 6 # logistic DW2S
 -10 61 3  -10 3 18 # -11 16 2
 -11 61 3  -11 3 15 # -12 16 2
 -12 61 3  -12 3 15 # -13 16 2
 -13 61 3  -13 3 15  # -14 16 2
 -999 3 18   # Thefore all fishery has default value of ff3
 -10 66 0
 -3 49 10
 -9 49 10
  -4 49 20
  -4 50 20
  -10 49 20
  -10 50 20
 # exclude  the estimation of temporal recruitment for terminal time period
 1 400 2 # exclude 2 teminal time period to estimate rec devs
 1 398 1 # geometric mean for parest_flags(400)  
PHASE1
fi
#exit
#  ---------
#   PHASE 2
#  ---------
if [ ! -f 02.par ]; then
  nice $MFCL $FRQ 01.par 02.par -file - <<PHASE2
  1 149 100       # set penalty on recruitment devs to 400/10
  -999 4 4        # estimate effort deviates - possibly not needed
  1 189 1         # write length.fit and weight.fit
  1 190 1         # write plot-xxx.par.rep
  1 1 200         # set max. number of function evaluations per phase to 200
  1 50 -2         # set convergence criterion to 1E-02
  -999 14 10      # Penalties to stop F blowing out
  2 35 10         # Set effdev bounds to +- 10 (need to do AFTER phase 1)
  2 144 100000
  1 1 1000
  1 188 1
PHASE2
fi
#exit
#  ---------
#
# recruitmentConstraints 02.par 0.8
#
#   PHASE 3
#  ---------
if [ ! -f 03.par ]; then
  nice $MFCL $FRQ 02.par 03.par -file - <<PHASE3
  2 70 1          # activate parameters and turn on
  2 71 1          # estimation of temporal changes in recruitment distribution
  2 110 50      # so penalty is 10/10=1 ->CV=0.71
PHASE3
fi
#  ---------
#   PHASE 4
#  ---------
if [ ! -f 04.par ]; then
  nice $MFCL $FRQ 03.par 04.par -file - <<PHASE4
  2 68 0
PHASE4
fi
#  ---------
#   PHASE 5
#  ---------
if [ ! -f 05.par ]; then
  nice $MFCL $FRQ 04.par 05.par -file - <<PHASE5
  -999 27 1       # estimate seasonal catchability for all fisheries
PHASE5
fi
#  ---------
#   PHASE 6
#  ---------
if [ ! -f 06.par ]; then
  nice $MFCL $FRQ 05.par 06.par -file - <<PHASE6
# Estimate catchability time-series for defined fisheries and assume a random walk according to defined frequency
  -1 10 1
  -2 10 0
  -3 10 1
  -4 10 0
  -5 10 1
  -6 10 1
  -7 10 0
  -8 10 0
  -9 10 1
  -10 10 1
  -11 10 0
  -12 10 1
  -13 10 1
  -999 23 23      # and do a random-walk step every 23+1 months
PHASE6
fi
#  ---------
#   PHASE 7
#  ---------
if [ ! -f 07.par ]; then
  nice $MFCL $FRQ 06.par 07.par -file - <<PHASE7
# Estimate average proportion of recruitment coming from each region
  -100000 1 1
  -100000 2 1
PHASE7
fi
#exit
#  ---------
#   PHASE 8
#  ---------
if [ ! -f 08.par ]; then
  nice $MFCL $FRQ 07.par 08.par -file - <<PHASE8
  2 145 2       # use SRR parameters pen=6 -> CV=0.29 pen=2 -> CV=0.50
  2 146 1        # estimate SRR parameters
  2 163 0        # use steepness parameterization of B&H SRR
  1 149 0  # old comment:  # negligible penalty on recruitment devs
  2 147 0  # old comment:  # time period between spawning and recruitment
  2 148 8  # old comment:  # period for MSY calc - last 20 quarters
  2 155 0  # old comment:  # but not including last year
  2 200 2  # 
  2 199 64 # exclude terminal 2 time periods(years) for estimation of B-H SRR
#  2 153 31       # beta prior for steepness
#  2 154 16       # beta prior for steepness
#  1 1 1000       #maximum of 1000 function evaluations for the final phase - TO BEGIN WITH
  1 50 -3        #convergence criteria of 10^-3
  -999 55 1      # No-fishing calcs
  2 193 1        # Fishing impact analysis
  1 1 8000
  2 161 1  # set bias correction of BH SRR
PHASE8
fi
#exit
# ------------
#   PHASE 9
# ------------
if [ ! -f 09.par ]; then
  $MFCL $FRQ 08.par 09.par -file - <<PHASE9
  1 1 10000 # In crease maximum function evaluation to 10000
PHASE9
fi

#################

EPS=1.0e-3
GRAD=$(grep -r -h gradient  -A 1  09.par |tail -1)
echo GRAD=$GRAD
## do another phaze if gradient is large
XX=$(Rscript -e "($GRAD > $EPS)")
echo "XX=$XX"
if [ ! -f 10.par ]; then
  if [  $(perl -e  "if($GRAD >  $EPS){print(1)}else{print(0)}") == 1 ]  ; then
    $MFCL $FRQ 09.par 10.par  -switch 2 1 1 10000 1 50 -3
    GRAD=$(grep -h -r gradient  -A 1  10.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  10.par |tail -1)
    echo "Max gradient is  $GRAD"

## do another phaze if gradient is large
if [ ! -f 11.par ]; then
  if [  $(perl  -e "if($GRAD >  $EPS){print(1)}else{print(0)}") == 1 ] ; then
  $MFCL $FRQ 10.par 11.par  -switch 1 1 1 10000
    echo "TRUE here 1"
    GRAD=$(grep -h -r gradient  -A 1  11.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  11.par |tail -1)
    echo "Max gradient is  $GRAD"

## do another phaze if gradient is large
if [ ! -f 12.par ]; then
  if [  $(perl -e "if($GRAD > $EPS){print(1)}else{print(0)}") ==  1 ]  ; then
  $MFCL $FRQ 11.par 12.par  -switch 1 1 1 10000
    echo "TRUE here2"
    GRAD=$(grep -h -r gradient  -A 1  12.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  12.par |tail -1)
    echo "Max gradient is  $GRAD"

## do another phaze if gradient is large
if [ ! -f 13.par ]; then
  if [ $(perl -e "if($GRAD > $EPS){print(1)}else{print(0)}") == 1  ] ; then
    $MFCL $FRQ 12.par 13.par  -switch 1 1 1 10000
    echo "TRUE here3"
    GRAD=$(grep -h -r gradient  -A 1  13.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  13.par |tail -1)
    echo "Max gradient is  $GRAD"

## do another phaze if gradient is large
if [ ! -f 14.par ]; then
  if [ $(perl -e "if($GRAD > $EPS){print(1)}else{print(0)}")  == 1 ] ; then
    $MFCL $FRQ 13.par 14.par  -switch 1 1 1 10000
    echo "TRUE here4"
    GRAD=$(grep -h -r gradient  -A 1  14.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  14.par |tail -1)
    echo "Max gradient is  $GRAD"

# do another phaze if gradient is large
if [ ! -f 15.par ]; then
  if [ $(perl -e "if($GRAD > $EPS){print(1)}else{print(0)}") == 1  ] ; then
    $MFCL $FRQ 14.par 15.par  -switch 1 1 1 10000
    echo "TRUE here3"
    GRAD=$(grep -h -r gradient  -A 1  15.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  15.par |tail -1)
    echo "Max gradient is  $GRAD"

## do another phaze if gradient is large
if [ ! -f 16.par ]; then
  if [ $(perl -e "if($GRAD > $EPS){print(1)}else{print(0)}")  == 1 ] ; then
    $MFCL $FRQ 15.par 16.par  -switch 1 1 1 10000
    echo "TRUE here4"
    GRAD=$(grep -h -r gradient  -A 1  16.par |tail -1)
    echo "Max gradient is  $GRAD"
  else
    exit
  fi
fi

    GRAD=$(grep -h -r gradient  -A 1  16.par |tail -1)
    echo "Max gradient is  $GRAD"

