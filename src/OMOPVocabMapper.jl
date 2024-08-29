module OMOPVocabMapper

using CSV, DataFrames, StatsBase, Query, Dates, InlineStrings

# Function to process ICD codes
function process_ICD_codes(ICD_type::String, df_concept::DataFrame, df_concept_relationship_mapsto_select::DataFrame, ICD_codes::DataFrame)
    println("Processing ICD type: $ICD_type")
    # filter df_concept file for the ICD type. Just to limit the category
    df_concept_ICD = filter(row -> row.vocabulary_id == ICD_type, df_concept)
    println("Number of entries in concept dataframe for $ICD_type: $(nrow(df_concept_ICD))")
    if nrow(df_concept_ICD) == 0
        println("Warning: No entries found for ICD type $ICD_type in concept file.")
        return DataFrame()
    end

    df_concept_ICD_select = select(df_concept_ICD, :concept_id, :concept_code, :concept_name, :domain_id, :vocabulary_id)
    rename!(df_concept_ICD_select, :concept_name => :source_concept_name, :domain_id => :source_domain_id, :vocabulary_id => :source_vocabulary_id)


    filtered_ICD_codes = filter(row -> row.system == ICD_type, ICD_codes)
    println("Number of entries in ICD codes dataframe for $ICD_type: $(nrow(filtered_ICD_codes))")
    if nrow(filtered_ICD_codes) == 0
        println("Warning: No entries found for ICD type $ICD_type in ICD codes file.")
        return DataFrame()
    end

    join_ICD_concept = leftjoin(filtered_ICD_codes, df_concept_ICD_select, on = (:VALUE => :concept_code))

    join_ICD_concept_filled = coalesce.(join_ICD_concept, 0)

    # Joining with concept relationship table
    join_ICD_concept_relationship = leftjoin(join_ICD_concept_filled, df_concept_relationship_mapsto_select, on = (:concept_id => :concept_id_1))

    # Renaming columns
    ICD_SNOMED_MAP = rename(join_ICD_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :omop_concept_id)

    ICD_SNOMED_MAP_filled = coalesce.(ICD_SNOMED_MAP, 0)

    # println("Performing final join with concept table...")
    icd_omop_standard = leftjoin(ICD_SNOMED_MAP_filled, df_concept, on = (:omop_concept_id => :concept_id))
    # select!(icd_omop_standard, Not(:concept_code))
    # println("Final join completed. Resulting Frame has $(nrow(icd_omop_standard)) rows.")
    # println("First few entries in icd_omop_standard:")
    # println(first(icd_omop_standard, 5))

    return icd_omop_standard
end

# Function to add multiple mapping indicator
function add_multiple_mapping_indicator(df::DataFrame)
    df_grouped = groupby(df, :VALUE)
    combined = combine(df_grouped, nrow => :count)
    combined.multiple_mappings = combined.count .> 1
    return leftjoin(df, combined[:, [:VALUE, :multiple_mappings]], on = :VALUE)
end


# Main function to map ICD codes to OMOP concepts
function map_icd_to_omop(icd_codes_file::String, concept_file::String, concept_relationship_file::String, output_file::String)
    println("Entered map_icd_to_omop function...")

    try
        println("Starting mapping process...")

        if !isfile(icd_codes_file)
            error("ICD codes file not found: $icd_codes_file")
        end
        if !isfile(concept_file)
            error("Concept file not found: $concept_file")
        end
        if !isfile(concept_relationship_file)
            error("Concept relationship file not found: $concept_relationship_file")
        end

        println("Reading ICD codes file...")
        ICD_codes = CSV.read(icd_codes_file, DataFrame)
        println("ICD codes file loaded. Number of rows: $(nrow(ICD_codes))")

        # println("Removing decimal points from ICD codes...")
        ICD_codes.VALUE = replace.(ICD_codes.ICD, "." => "")
        # println("First few entries in ICD codes file after processing:")
        # println(first(ICD_codes, 5))

        println("Reading concept file...")
        df_concept = CSV.read(concept_file, DataFrame)
        # println("Concept file loaded. Number of rows: $(nrow(df_concept))")

        println("Reading concept relationship file...")
        df_concept_relationship = CSV.read(concept_relationship_file, DataFrame)
        # println("Concept relationship file loaded. Number of rows: $(nrow(df_concept_relationship))")

        # println("Removing decimal points from concept codes...")
        df_concept.concept_code = replace.(df_concept.concept_code, "." => "")

        println("Filtering concept relationship for 'Maps to' and 'Maps to value' relationships...")
        df_concept_relationship_mapsto = filter(row -> (row.relationship_id == "Maps to" || row.relationship_id == "Maps to value"), df_concept_relationship)
        df_concept_relationship_mapsto_select = select(df_concept_relationship_mapsto, :concept_id_1, :concept_id_2, :relationship_id)
        # println("Filtered concept relationship file. Number of rows: $(nrow(df_concept_relationship_mapsto_select))")

        # println("Contents of the system column in ICD_codes:")
        # println(ICD_codes.system)
        # println("Type of system column: ", typeof(ICD_codes.system))

        # Convert InlineStrings.String7 to String if necessary
        ICD_codes.system = String.(ICD_codes.system)
        # println("Contents of the system column in ICD_codes after conversion:")
        # println(ICD_codes.system)
        # println("Type of system column after conversion: ", typeof(ICD_codes.system))

        unique_ICD_types = unique(ICD_codes.system)
        println("Unique ICD types found: $unique_ICD_types")

        combined_results = DataFrame()
        for ICD_type in ["ICD9CM", "ICD10CM"]
            if ICD_type in unique_ICD_types
                println("Processing ICD type: $ICD_type")
                icd_omop_standard = process_ICD_codes(ICD_type, df_concept, df_concept_relationship_mapsto_select, ICD_codes)
                if nrow(icd_omop_standard) > 0
                    combined_results = vcat(combined_results, icd_omop_standard)
                else
                    println("No valid mappings found for ICD type $ICD_type.")
                end
            else
                println("Skipping ICD type: $ICD_type as it is not found in the unique ICD types")
            end
        end

        if nrow(combined_results) > 0
            println("Adding multiple mapping indicator...")
            combined_results = add_multiple_mapping_indicator(combined_results)

            println("Writing combined results to output file...")
            CSV.write(output_file, combined_results)
            println("Successfully mapped the ICD codes to OMOP. Please check the output file: $output_file")
        else
            println("No mappings were generated. The output file will not be created.")
        end
    catch e
        println("Error: ", e)
    end
end

end # module