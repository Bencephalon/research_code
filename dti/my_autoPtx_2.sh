#!/bin/bash
#   Automated probabilistic tractography plugin for FSL; second stage.
#
#   Performs tractography as used in De Groot et al., NeuroImage 2013.
#   2013, Marius de Groot
#
#   LICENCE
#
#   AutoPtx, plugin for FSL, Release 0.1 (c) 2013, Erasmus MC, University
#   Medical Center (the "Software")
#
#   The Software remains the property of the Erasmus MC, University Medical
#   Center ("the University").
#
#   The Software is distributed "AS IS" under this Licence solely for
#   non-commercial use in the hope that it will be useful, but in order
#   that the University as a charitable foundation protects its assets for
#   the benefit of its educational and research purposes, the University
#   makes clear that no condition is made or to be implied, nor is any
#   warranty given or to be implied, as to the accuracy of the Software, or
#   that it will be suitable for any particular purpose or for use under
#   any specific conditions.  Furthermore, the University disclaims all
#   responsibility for the use which is made of the Software.  It further
#   disclaims any liability for the outcomes arising from using the
#   Software.
#
#   The Licensee agrees to indemnify the University and hold the University
#   harmless from and against any and all claims, damages and liabilities
#   asserted by third parties (including claims for negligence) which arise
#   directly or indirectly from the use of the Software or the sale of any
#   products based on the Software.
#
#   No part of the Software may be reproduced, modified, transmitted or
#   transferred in any form or by any means, electronic or mechanical,
#   without the express permission of the University.  The permission of
#   the University is not required if the said reproduction, modification,
#   transmission or transference is done without financial return, the
#   conditions of this Licence are imposed upon the receiver of the
#   product, and all original and amended source code is included in any
#   transmitted product.  You may be held legally responsible for any
#   copyright infringement that is caused or encouraged by your failure to
#   abide by these terms and conditions.
#
#   You are not permitted under this Licence to use this Software
#   commercially.  Use for which any financial return is received shall be
#   defined as commercial use, and includes (1) integration of all or part
#   of the source code or the Software into a product for sale or license
#   by or on behalf of Licensee to third parties or (2) use of the Software
#   or any derivative of it for research with the final aim of developing
#   software products for sale or license to a third party or (3) use of
#   the Software or any derivative of it for research with the final aim of
#   developing non-software products for sale or license to a third party,
#   or (4) use of the Software to provide any service to an external
#   organisation for which payment is received.  If you are interested in
#   using the Software commercially, please contact the technology transfer
#   company of the University to negotiate a licence.  Contact details are:
#   tto@erasmusmc.nl quoting reference SOPHIA #2013-012 and the
#   accompanying paper DOI: 10.1016/j.neuroimage.2013.03.015.
#
# GS: Created this version to run everything locally

prewd=$PWD
execPath=`dirname $0`
cd $execPath
execPath=$PWD
cd $prewd

jobs=jobs
subjects=$1
dataDir=/data/NCR_SBRB/dti_fdt
structures=$execPath/structureList
track=$execPath/trackSubjectStruct
logDir=logs

mkdir -p $jobs $logDir

mkdir $dataDir/tracts
while read sub; do
    mkdir $dataDir/tracts/sub
done < $subjects

jid=1
while read structstring; do
    struct=`echo $structstring | awk '{print $1}'`
    nseed=`echo $structstring | awk '{print $2}'`
    wallt=`echo $structstring | awk '{print $3}' | tr ':' ' '`
    hours=`echo $wallt | awk '{print $1}'`
    minutes=`echo $wallt | awk '{print $2}'`
    time=$(( 60 * hours + minutes ))

    job=$jobs/commands_${jid}
    rm -f $job
    i=0
    while read sub; do
      echo "cd /lscratch/$SLURM_JOBID; ln -s $dataDir/preproc .; $track $sub $struct $nseed 2>&1 > /dev/null; cp -r tracts/$sub/$struct $dataDir/tracts/$sub/" >> $job
    done < $subjects
    $FSLDIR/bin/fsl_sub -N ptx.${struct}_${jid} -l $logDir -T $time -t $job
    let $(( jid += 1 ))
done < $structures