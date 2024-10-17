# OmopVocabMapper

[![DOI](https://zenodo.org/badge/651648334.svg)](https://doi.org/10.5281/zenodo.13883120)

OmopVocabMapper is a Julia package for mapping various medical vocabularies to the OMOP standard vocabulary. It provides functionalities to convert terminology codes from different sources, starting with ICD (International Classification of Diseases) to the corresponding OMOP concept IDs, with the ability to indicate ICD codes that map to multiple OMOP concept IDs.

## Features

- Mapping ICD codes to OMOP concept IDs: The library currently supports the mapping of ICD9CM and ICD10CM codes to their respective OMOP concept IDs.
- Reusability: We are actively working on expanding the functionality to support mapping of additional vocabularies like RXNORM, CPT, NDC, and more, making the library versatile and adaptable to different terminologies.


## Usage

### Preparing the Data

Ensure you have the following CSV files in your working directory:
- icd_codes.csv
- CONCEPT.csv 
- CONCEPT_RELATIONSHIP.csv

### `icd_codes.csv` File Format

When using the `map_icd_to_omop` function, you need to provide a CSV file that contains ICD codes and their corresponding system types. The CSV file can have any name, but make sure to specify the correct file path and name when using the function.

#### Mandatory Columns:

1. **`ICD`**: This column should contain the ICD codes. **Important**: Make sure that codes like `428.0` or those with leading zeros (e.g., `012.5`) retain their format. This often happens when editing CSV files in spreadsheet software (like Excel) that might automatically remove trailing zeros or convert codes to numbers. Be cautious when creating the CSV file to ensure the ICD codes are preserved correctly.

2. **`system`**: This column should specify the ICD code system used for each code. The values should be either `ICD9CM` or `ICD10CM`.

#### Example:

Your CSV file should look like the following:

| ICD     | system  |
|---------|---------|
| 428     | ICD9CM  |
| 428.0   | ICD9CM  |
| I50.9   | ICD10CM |
| 012.5   | ICD9CM  |
| J44.1   | ICD10CM |

### Important Notes:
- Make sure the `ICD` column preserves both numeric and alphanumeric codes exactly as they are, without removing decimal points or leading/trailing zeros.
- The `system` column specifies the version of ICD codes, either `ICD9CM` or `ICD10CM`.
- Ensure your CSV file is properly saved, and provide the correct path and file name when calling the `map_icd_to_omop` function.
- It can also have other columns like name.

### Downloading the vocabulary files from Athena
- From Athena https://athena.ohdsi.org/search-terms/start download the vocabulary files. From the downloaded files copy only the required CONCEPT.csv and CONCEPT_RELATIONSHIP.csv files to the working dircetory.

### Running the Mapping

1. **Include the module and use it in your script or Julia REPL:**
    
    ```julia
    using Pkg
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Reference

Thakkallapally M, Bradenday J, Aluthge D, Sarkar IN, Crowley KM, Chen E. OMOPVocabMapper: A Tool for Mapping ICD Codes to OMOP Concepts. AMIA 2024 Annual Symposium. [Poster Abstract] - Accepted




