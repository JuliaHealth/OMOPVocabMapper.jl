# OmopVocabMapper

OmopVocabMapper is a Julia-based library for mapping various medical vocabularies to the OMOP standard vocabulary. It provides functionalities to convert terminology codes from different sources, starting with ICD (International Classification of Diseases), to the corresponding OMOP concept IDs.

## Features

- Mapping ICD codes to OMOP concept IDs: The library currently supports the mapping of ICD codes to their respective concept IDs in the OMOP vocabulary.
- Reusability: We are actively working on expanding the functionality to support mapping of additional vocabularies like RXNORM, CPT, NDC, and more, making the library versatile and adaptable to different terminologies.

## Development

It is much easier to import code into Stronghold than to export.
So, I like to avoid writing new code in Stronghold.
Here is my workflow:

1. `git pull` # Get the latest version before making changes
1. Edit the code
1. `pbcopy <OmopVocabMapper.jl` # Copy file to clipboard
1. Paste code into file on Stronghold
1. Run code on Stronghold
1. If there's an error, repeat steps 2-5
1. Commit the changes and push to the repo
 

