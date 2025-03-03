process OPENMS_FEATURELINKERUNLABELEDKD {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::openms-thirdparty=2.6.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/openms-thirdparty:2.6.0--0' :
        'quay.io/biocontainers/openms-thirdparty:2.6.0--0' }"

    input:
        tuple val(meta), path(features)

    output:
        tuple val(meta), path("*.consensusXML"), emit: consensusxml
        path "versions.yml"                    , emit: versions

    script:
        def prefix           = task.ext.prefix ?: "${meta.id}_all_features_merged"

        """
        FeatureLinkerUnlabeledKD -in $features \\
            -out '${prefix}.consensusXML' \\
            -threads $task.cpus

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            openms-thirdparty: \$(echo \$(FileInfo --help 2>&1) | sed 's/^.*Version: //; s/-.*\$//' | sed 's/ -*//; s/ .*\$//')
        END_VERSIONS
        """
}
