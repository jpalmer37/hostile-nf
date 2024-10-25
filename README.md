# hostile-nf
A nextflow pipeline for running Hostile dehosting software on a set of FASTQ inputs.

## Usage

```
nextflow run BCCDC-PHL/hostile-nf \
  --fastq_input </path/to/fastq/files> \
  --index <NAME_OF_INDEX> \  # optional; defaults to "human-t2t-hla"
  --outdir </path/to/outdir>
```

The pipeline also supports a 'samplesheet input' mode. Pass a samplesheet.csv file with the headers `ID`, `ASSEMBLY`:

```
nextflow run BCCDC-PHL/hostile-nf \
  --samplesheet_input </path/to/samplesheet.csv> \
  --outdir </path/to/outdir>
```

## Outputs

Outputs for each sample will be written to a separate directory under the output directory, named using the sample ID.

The following output files are produced for each sample.

```
sample-01
├── sample-01_20211202154752_provenance.yml
├── sample-01_dehosted_R1.fastq.gz
└── sample-01_dehosted_R2.fastq.gz
```

### Provenance
Each analysis will create a `provenance.yml` file for each sample. The filename of the `provenance.yml` file includes
a timestamp with format `YYYYMMDDHHMMSS` to ensure that a unique file will be produced if a sample is re-analyzed and outputs
are stored to the same directory.

```yml
- process_name: hostile
  tool_name: hostile
  tool_version: 1.1.0
  parameters:
- input_filename: sample-01_R1.fastq.gz
  input_path: /path/to/fastq/files/sample-01_R1.fastq.gz
  sha256: e291e09222b7f9a46968f4aa8c3a754c4b12758ea220d6e638a760d411e36697
- input_filename: sample-01_R2.fastq.gz
  input_path: /path/to/fastq/files/sample-01_R2.fastq.gz
  sha256: b12758ea220d6e638a760d411e36697e291e09222b7f9a46968f4aa8c3a754c4
- pipeline_name: BCCDC-PHL/hostile-nf
  pipeline_version: 0.1.0
- timestamp_analysis_start: 2024-10-16T09:05:01.524396
```
