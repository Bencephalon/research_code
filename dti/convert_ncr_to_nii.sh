# Script to convert the DICOMs obtained in our protocol, which need the gradient
# files, to NIFTI format that can be understood by FSL.
#
# Usage: bash convert_ncr_to_nii.sh /path/to/maskid
#
# script expects mr_dirs and gradient file inside /path/to/maskid

module load TORTOISE
module load afni

if [ ! -d $1 ]; then
    echo Could not find directory $1;
    exit 1;
else
    cd $1;
    # quick hack that if there are two cdi files we should use the last one
    gradient_file=`/bin/ls -1 | grep cdi | tail -1`;
    echo Using $gradient_file for gradients!
    /bin/ls -1 | grep -v cdi > mr_dirs.txt;
    # remove first line
    tail -n +2 $gradient_file | split -l 20 -a 1 -d - grads;

    # The idea behind doing it per session comes from an email from Irfan, who said
    # that TORTOISE v2 used directory structure, but ImportDICOM (and dcm2nixx) use
    # the DICOM series number written in the header. Somehow the scanner is writing
    # the series number wrong, and then the DICOMs get imported incorrectly. If we do
    # it by scan, like TORTOISE v2 used to do, and provide the correct gradients, it
    # should work fine.
    cnt=0
    nii='-innii'
    bval='-inbval'
    bvec='-inbvec'
    for mr_dir in `cat mr_dirs.txt`; do
        ImportDICOM -i $mr_dir -o s${cnt} -b 1100 -g grads${cnt};
        TORTOISEBmatrixToFSLBVecs s${cnt}_proc/s${cnt}.bmtxt;
        nii=$nii' 's${cnt}_proc/s${cnt}.nii
        bval=$bval' 's${cnt}_proc/s${cnt}.bvals
        bvec=$bvec' 's${cnt}_proc/s${cnt}.bvecs
        let cnt=${cnt}+1;
    done
    fat_proc_convert_dcm_dwis $nii $bval $bvec -prefix dwi_comb -flip_x
fi