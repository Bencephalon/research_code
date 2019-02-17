# After conversion from DCM to nii using convert_ncr_to_nii.sh, use this script
# to create brain mask, QC, and run eddy

module load CUDA/7.5
module load fsl
module load afni

s=$1;

cd /scratch/sudregp/dcm_dti/${s}

# FSL takes bvecs in the 3 x volumes format
fslroi dwi b0 0 1
bet b0 b0_brain -m -f 0.2

# make QC images for brain mask
@chauffeur_afni                             \
    -ulay  dwi.nii.gz[0]                         \
    -olay  b0_brain_mask.nii.gz                        \
    -opacity 4                              \
    -prefix   QC/brain_mask              \
    -montx 6 -monty 6                       \
    -set_xhairs OFF                         \
    -label_mode 1 -label_size 3             \
    -do_clean

nvol=`cat dwi_comb_cvec.dat | wc -l`;
idx=''; for i in `seq 1 $nvol`; do 
    a=$a' '1;
done;
echo $a > index.txt
echo "0 -1 0 0.102" > acqparams.txt

# eddy_openmp --imain=dwi --mask=b0_brain_mask --index=index.txt \
#     --acqp=acqparams.txt --bvecs=dwi_cvec.dat --bvals=dwi_bval.dat \
#     --fwhm=0 --flm=quadratic --out=eddy_unwarped_images --cnr_maps --repol --mporder=6

cp ../my_slspec.txt ./
eddy_cuda --imain=dwi --acqp=acqparams.txt --index=index.txt \
    --mask=b0_brain_mask --bvals=dwi_bval.dat --bvecs=dwi_rvec.dat \
    --out=eddy_s2v_unwarped_images --niter=8 --fwhm=10,6,4,2,0,0,0,0 \
    --repol --ol_type=both --mporder=8 --s2v_niter=8 \
    --slspec=my_slspec.txt --cnr_maps