# Runs the new version (3.1.1) of DIFFPREP after some preprocessing
# based on FATCAT tutorials.
# Assumes there is an edti folder inside top_dir/maskid <--- review this later,
# because the importing tool is capable of figuring out the DTI from the image folder
# Also, the anatomy script from fatcat can take in DICOMs, so even the MIPAV step
# shouldn't be necessary
top_dir=$1;
m=$2;

template_dir=/data/${USER}/fatcat_proc_mni_ref/

# grab bval from a random .dcm. Assumes it's constant for all volumes
dcm_file=`ls -1 ${top_dir}/${m}/edti/*/*100.dcm | head -1`;
dcm_tag=`dicom_hdr $dcm_file | grep "0043 1039"`
bval=`echo $dcm_tag | awk '{print $NF}' | sed "s/\/\///g"  | awk -F '\' '{print $1}'`

echo Using max bval = $bval

# selecting correct gradient file
if [ -e ${top_dir}/${m}/edti/cdiflistOriginalAndReplayedCombined ]; then
	gradient_file=${top_dir}/${m}/edti/cdiflistOriginalAndReplayedCombined;
elif [ -e ${top_dir}/${m}/edti/cdiflist09 ]; then
	gradient_file=${top_dir}/${m}/edti/cdiflist09;
elif [ -e ${top_dir}/${m}/edti/cdiflist08 ]; then
	gradient_file=${top_dir}/${m}/edti/cdiflisl08;
else
	echo 'Could not find any gradient file!';
	exit 1;
fi

echo Using $gradient_file

ImportDICOM -i ${top_dir}/${m}/edti/ \
    -o ${top_dir}/${m}/diffprep311 \
    -b $bval -g $gradient_file;

fat_proc_axialize_anat -inset ${top_dir}/${m}/edti/t2_struc.nii \
    -prefix ${top_dir}/${m}/diffprep311_proc/t2w \
    -mode_t2w \
    -refset ${template_dir}/mni_icbm152_t2_relx_tal_nlin_sym_09a_ACPCE.nii.gz \
    -extra_al_wtmask ${template_dir}/mni_icbm152_t2_relx_tal_nlin_sym_09a_ACPCE_wtell.nii.gz \
    -out_match_ref;

cd ${top_dir}/${m}/diffprep311_proc;
gunzip t2w.nii.gz;

DIFFPREP -i ${top_dir}/${m}/diffprep311_proc/diffprep311.list \
    --structural ${top_dir}/${m}/diffprep311_proc/t2w.nii \
    --reg_settings example_registration_settings.dmc --do_QC 0


