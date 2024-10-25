process hostile {
    
    tag { sample_id }
    
    publishDir "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}*dehosted*.fastq.gz"
    
    input:
    tuple val(sample_id), path(reads_1), path(reads_2), val(index)
    
    output:
    tuple val(sample_id), path("${sample_id}_dehosted_R1.fastq.gz"), path("${sample_id}_dehosted_R2.fastq.gz"), emit: reads
    tuple val(sample_id), path("${sample_id}_hostile_provenance.yml"), emit: provenance
    
    script:
    """
    printf -- "- process_name: hostile\\n"                                                    >> ${sample_id}_hostile_provenance.yml
    printf -- "  tools:\\n"                                                                   >> ${sample_id}_hostile_provenance.yml
    printf -- "  - tool_name: hostile\\n"                                                    >> ${sample_id}_hostile_provenance.yml
    printf -- "    tool_version: \$(hostile --version)\\n"                                  >> ${sample_id}_hostile_provenance.yml
    printf -- "    parameters:\\n"                                                           >> ${sample_id}_hostile_provenance.yml
    printf -- "      - name: index\\n"                                                       >> ${sample_id}_hostile_provenance.yml
    printf -- "        value: ${index}\\n"                                                   >> ${sample_id}_hostile_provenance.yml
    
    hostile clean \
        --fastq1 ${reads_1} \
        --fastq2 ${reads_2} \
        --index ${index} \
        --threads ${task.cpus} \
        --out-dir . \
        --force
    
    mv *clean_1.fastq.gz ${sample_id}_dehosted_R1.fastq.gz
    mv *clean_2.fastq.gz ${sample_id}_dehosted_R2.fastq.gz
    """
}
