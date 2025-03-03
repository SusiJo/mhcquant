process OPENMS_PEPTIDEINDEXER {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::openms=2.6.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/openms:2.6.0--h4afb90d_0' :
        'quay.io/biocontainers/openms:2.6.0--h4afb90d_0' }"

    input:
        tuple val(meta), path(idxml), path(fasta)

    output:
        tuple val(meta), path("*.idXML"), emit: idxml
        path "versions.yml"             , emit: versions

    script:
        def prefix           = task.ext.prefix ?: "${idxml.baseName}_-_idx"

        """
        PeptideIndexer -in $idxml \\
                -out ${prefix}.idXML \\
                -threads $task.cpus \\
                -fasta $fasta \\
                -decoy_string DECOY \\
                -enzyme:specificity none

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            openms: \$(echo \$(FileInfo --help 2>&1) | sed 's/^.*Version: //; s/-.*\$//' | sed 's/ -*//; s/ .*\$//')
        END_VERSIONS
        """
}
