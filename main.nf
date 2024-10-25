#!/usr/bin/env nextflow

import java.time.LocalDateTime

nextflow.enable.dsl = 2

include { hash_files }             from './modules/hash_files.nf'
include { hostile }                from './modules/hostile.nf'
include { pipeline_provenance }    from './modules/provenance.nf'
include { collect_provenance }     from './modules/provenance.nf'


workflow {

    ch_workflow_metadata = Channel.value([
        workflow.sessionId,
        workflow.runName,
        workflow.manifest.name,
        workflow.manifest.version,
        workflow.start,
    ])

    if (params.samplesheet_input != 'NO_FILE') {
        ch_fastq = Channel.fromPath(params.samplesheet_input).splitCsv(header: true).map{ it -> [it['ID'], it['R1'], it['R2']] }
    } else {
        ch_fastq = Channel.fromFilePairs( params.fastq_search_path, flat: true ).map{ it -> [it[0].split('_')[0], it[1], it[2]] }.unique{ it -> it[0] }
    }

    ch_index = Channel.from("${params.index}")

    main:
      hash_files(ch_fastq.map{ it -> [it[0], [it[1], it[2]]] }.combine(Channel.of("fastq-input")))

      hostile(ch_fastq.combine(ch_index))

      // Collect Provenance
      ch_sample_ids = ch_fastq.map{ it -> it[0] }
      ch_provenance = ch_sample_ids
      ch_pipeline_provenance = pipeline_provenance(ch_workflow_metadata)
      ch_provenance = ch_provenance.combine(ch_pipeline_provenance).map{ it ->     [it[0], [it[1]]] }
      ch_provenance = ch_provenance.join(hash_files.out.provenance).map{ it ->     [it[0], it[1] << it[2]] }
      ch_provenance = ch_provenance.join(hostile.out.provenance).map{ it ->        [it[0], it[1] << it[2]] }
      collect_provenance(ch_provenance)
}
