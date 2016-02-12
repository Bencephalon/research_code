# we have to create separate solar directories, so the SOLAR residual files don't get overwritten as we run multiple voxels in parallel
phen_file=$1
v=$2
tmp_dir=~/data/tmp/
solar_dir=~/data/solar_paper_v2/
vox=`printf "%05d" $v`
mkdir ${tmp_dir}/${phen_file}
mkdir ${tmp_dir}/${phen_file}/${vox}
cp ${solar_dir}/pedigree.csv ${solar_dir}/procs.tcl ${solar_dir}/${phen_file}.csv ${tmp_dir}/${phen_file}/${vox}/
cd ${tmp_dir}/${phen_file}/${vox}/
solar run_ica_voxel $phen_file $v
mv ${tmp_dir}/${phen_file}/${vox}/i_v${v}/polygenic.out ${tmp_dir}/${phen_file}/v${vox}_polygenic.out
rm -rf ${tmp_dir}/${phen_file}/${vox}
