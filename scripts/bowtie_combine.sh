#!/bin/bash
## HiC-Pro
## Copyleft 2015 Institut Curie                               
## Author(s): Nicolas Servant, Eric Viara
## Contact: nicolas.servant@curie.fr
## This software is distributed without any guarantee under the terms of the GNU General
## Public License, either Version 2, June 1991 or Version 3, June 2007.

##
## Combine two steps alignment files
##

dir=$(dirname $0)

while [ $# -gt 0 ]
do
    case "$1" in
	(-c) conf_file=$2; shift;;
	(-h) usage;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	(*)  break;;
    esac
    shift
done

CONF=$conf_file . $dir/hic.inc.sh

##
## Combine both Bowtie2 mapping
##
mapping_combine()
{
    local sample_dir="$1"
    local file="$2"
    local prefix=$(echo ${sample_dir}/$(basename $file) | sed -e 's/.bwt2glob.bam//')

    echo ${prefix} >> ${LOGFILE}

    mkdir -p ${BOWTIE2_FINAL_OUTPUT_DIR}/${sample_dir}    

    ## Merge local and global alignment
    cmd="${SAMTOOLS_PATH}/samtools merge -@ ${N_CPU} -n -f ${BOWTIE2_FINAL_OUTPUT_DIR}/${prefix}.bwt2merged.bam ${BOWTIE2_GLOBAL_OUTPUT_DIR}/${prefix}.bwt2glob.bam ${BOWTIE2_LOCAL_OUTPUT_DIR}/${prefix}.bwt2glob.unmap_bwt2loc.bam "
    #echo $cmd
    exec_cmd $cmd

    ## Sort merge file. In theory, should be perform by "merge -n", but do not work in some cases ... depending on read name ?
    cmd="${SAMTOOLS_PATH}/samtools sort -@ ${N_CPU} -n ${BOWTIE2_FINAL_OUTPUT_DIR}/${prefix}.bwt2merged.bam ${BOWTIE2_FINAL_OUTPUT_DIR}/${prefix}.bwt2merged.sorted"
    #echo $cmd
    exec_cmd $cmd
    
    cmd="mv ${BOWTIE2_FINAL_OUTPUT_DIR}/${prefix}.bwt2merged.sorted.bam ${BOWTIE2_FINAL_OUTPUT_DIR}/${prefix}.bwt2merged.bam"
    #echo $cmd
    exec_cmd $cmd
}

## Combine local and global alignments
for r in $(get_sam_for_combine)
do
    R1=$r
    R2=$(echo $r | get_R2)
    sample_dir=$(get_sample_dir $r)

    mapping_combine $sample_dir $R1 &
    mapping_combine $sample_dir $R2 &
    
    wait
done