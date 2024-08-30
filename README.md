# OmopVocabMapper

OmopVocabMapper is a Julia package for mapping various medical vocabularies to the OMOP standard vocabulary. It provides functionalities to convert terminology codes from different sources, starting with ICD (International Classification of Diseases) to the corresponding OMOP concept IDs, with the ability to indicate ICD codes that map to multiple OMOP concept IDs.

## Features

- Mapping ICD codes to OMOP concept IDs: The library currently supports the mapping of ICD9CM and ICD10CM codes to their respective OMOP concept IDs.
- Reusability: We are actively working on expanding the functionality to support mapping of additional vocabularies like RXNORM, CPT, NDC, and more, making the library versatile and adaptable to different terminologies.

## installation 

1. **Clone the repository:**

```
sh
git clone https://github.com/bcbi/OMOPVocabMapper.jl.git
cd OMOPVocabMapper
```

2. **Open Julia and activate the package environment:**

```
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Uage

### Preparing the Data

Ensure you have the following CSV files in your working directory:
- 'icd_codes.csv': Contains the ICD codes. Input file structure ICD, system (ICD9CM, ICD10CM)
- 'CONCEPT.csv' Vocabulary file from athena
- 'CONCEPT_RELATIONSHIP.csv': Vocabulary file from athena

### Running the Mapping

1. **Include the module and use it in your script or Julia REPL:**

    ```julia
    using OMOPVocabMapper
    ```

2. **Call the `map_icd_to_omop` function:**

    ```julia
    OMOPVocabMapper.map_icd_to_omop(
        "path/to/icd_codes.csv",
        "path/to/CONCEPT.csv",
        "path/to/CONCEPT_RELATIONSHIP.csv",
        "path/to/output/omopmappedcodes.csv"
    )
    ```

### Example

Here’s an example of running the mapping from a script:

1. Create a script named `run_mapping.jl`:

    ```julia
    # run_mapping.jl
    include("src/OMOPVocabMapper.jl")
    using .OMOPVocabMapper

    OMOPVocabMapper.map_icd_to_omop(
        "icd_codes.csv",
        "CONCEPT.csv",
        "CONCEPT_RELATIONSHIP.csv",
        "omopmappedcodes.csv"
    )
    ```

2. Run the script in Julia:

    ```julia
    include("run_mapping.jl")
    ```


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

