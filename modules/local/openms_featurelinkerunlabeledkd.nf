// Import generic module functions
include { initOptions; saveFiles; getSoftwareName; getProcessName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process OPENMS_FEATURELINKERUNLABELEDKD {
    tag "$meta.id"
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'Intermediate_Results', publish_id:'Intermediate_Results') }

    conda (params.enable_conda ? "bioconda::openms-thirdparty=2.6.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/openms-thirdparty:2.6.0--0"
    } else {
        container "quay.io/biocontainers/openms-thirdparty:2.6.0--0"
    }

    input:
        tuple val(meta), path(features)

    output:
        tuple val(meta), path("*.consensusXML"), emit: consensusxml
        path "versions.yml", emit: versions

    script:
        def software = getSoftwareName(task.process)
        def prefix = options.suffix ? "${meta.id}_${options.suffix}" : "${meta.id}_all_features_merged"

        """
            FeatureLinkerUnlabeledKD -in ${features} \\
                -out '${prefix}.consensusXML' \\
                -threads ${task.cpus}

            cat <<-END_VERSIONS > versions.yml
            ${getProcessName(task.process)}:
                openms-thirdparty: \$(echo \$(FileInfo --help 2>&1) | sed 's/^.*Version: //; s/-.*\$//' | sed 's/ -*//; s/ .*\$//')
            END_VERSIONS
        """
}
