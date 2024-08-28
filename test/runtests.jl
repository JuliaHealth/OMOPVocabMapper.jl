# test/test_mapping.jl
using OMOPVocabMapper

# Ensure paths are correct
icd_codes_path = "/Users/mounikathakkallapally/Documents/bcbi-projects/OMOPVocabMapper.jl/icd_codes.csv"
concept_path = "/Users/mounikathakkallapally/Documents/bcbi-projects/OMOPVocabMapper.jl/CONCEPT.csv"
concept_relationship_path = "/Users/mounikathakkallapally/Documents/bcbi-projects/OMOPVocabMapper.jl/CONCEPT_RELATIONSHIP.csv"
output_path = "omopmappedcodes.csv"

println("Starting the test script...")

OMOPVocabMapper.map_icd_to_omop(icd_codes_path, concept_path, concept_relationship_path, output_path)

println("Test script completed.")