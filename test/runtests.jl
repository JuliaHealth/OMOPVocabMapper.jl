using OMOPVocabMapper
using Test
using CSV  # Import the CSV package to read the output file
using DataFrames

# Define relative paths to the synthetic input files
icd_codes_file = joinpath(@__DIR__, "data/ICD_codes.csv")
concept_file = joinpath(@__DIR__, "data/concept.csv")
concept_relationship_file = joinpath(@__DIR__, "data/concept_relationship.csv")
output_file = joinpath(@__DIR__, "data/output/omopmappedcodes.csv")

# Ensure the output directory exists
if !isdir(joinpath(@__DIR__, "output"))
    mkpath(joinpath(@__DIR__, "output"))
end

@testset "My Function Tests" begin
    # Call the function without @test since we are not testing the return value
    map_icd_to_omop(icd_codes_file, concept_file, concept_relationship_file, output_file)
    
    # Test that the output file exists
    @test isfile(output_file)

    # Optionally, read the output file and check its content
    output_data = CSV.read(output_file, DataFrame)

    # Example checks (you can add more specific tests based on expected content)
    @test !isempty(output_data)  # Ensure the output file is not empty
    @test "ICD" in names(output_data)  # Check that a specific column exists
end
