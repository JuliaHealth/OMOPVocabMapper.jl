# OmopVocabMapper

OmopVocabMapper is a Julia package for mapping various medical vocabularies to the OMOP standard vocabulary. It provides functionalities to convert terminology codes from different sources, starting with ICD (International Classification of Diseases) to the corresponding OMOP concept IDs, with the ability to indicate ICD codes that map to multiple OMOP concept IDs.

## Features

- Mapping ICD codes to OMOP concept IDs: The library currently supports the mapping of ICD9CM and ICD10CM codes to their respective OMOP concept IDs.
- Reusability: We are actively working on expanding the functionality to support mapping of additional vocabularies like RXNORM, CPT, NDC, and more, making the library versatile and adaptable to different terminologies.


## Uage

### Preparing the Data

Ensure you have the following CSV files in your working directory:
- 'icd_codes.csv': Contains the ICD codes. Input file structure ICD, system (ICD9CM, ICD10CM) to match with the concept.csv vocab files 
- 'concept.csv' Vocabulary file from athena
- 'concept_relationship.csv': Vocabulary file from athena

### Downloading the vocabulary files from Athena
- In Athena https://athena.ohdsi.org/search-terms/start go to the downloads and give the required information and download the files. All the vocabulary files will be downloaded but ensure to copy on the required concept.csv and concept_relationship.csv files to the working dircetory.

### Running the Mapping

1. **Include the module and use it in your script or Julia REPL:**
    
    ```julia
    Pkg.add("OMOPVocabMapper")
    using OMOPVocabMapper
    ```

2. **Call the `map_icd_to_omop` function:**

    ```julia
    map_icd_to_omop(
        "path/to/icd_codes.csv",
        "path/to/concept.csv",
        "path/to/concept_relationship.csv",
        "path/to/output/omopmappedcodes.csv"
    )
    ```

### Example

Here’s an example of running the mapping from a script:

1. Create a script named `run_mapping.jl`:

    ```julia
    # run_mapping.jl
    Pkg.add("OMOPVocabMapper")
    using OMOPVocabMapper

    OMOPVocabMapper.map_icd_to_omop(
        "path/to/icd_codes.csv",
        "path/to/concept.csv",
        "path/to/concept_relationship.csv",
        "path/to/omopmappedcodes.csv"
    )
    ```

2. Run the script in Julia:

    ```julia
    include("run_mapping.jl")
    ```


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation Information

[![DOI](https://zenodo.org/badge/651648334.svg)](https://doi.org/10.5281/zenodo.13883120)

@software{OMOPVocabMapper,
author = {Thakkallapally, Mounika},
doi = {10.5281/zenodo.13883120},
title = {{OMOPVocabMapper 0.1.0}},
version = {0.1.0},
year = {2024}
}




