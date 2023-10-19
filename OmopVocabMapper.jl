using CSV, DataFrames, StatsBase, Query, Dates

# println("Enter the folder name for current ICD codes (/Users/mounikathakkallapally/Desktop/Brown/OmopVocabMapper/??):")
# # current dataset: breast_cancer
# working_drive = readline(stdin)
# cd("/Users/mounikathakkallapally/Desktop/Brown/OmopVocabMapper/$working_drive")

#load the csv files
ICD_codes = CSV.read("icd_codes.CSV", DataFrame)

ICD_codes.VALUE = replace.(ICD_codes.ICD, "." => "")

ICD9_codes = filter(row -> row.system == "ICD9CM", ICD_codes)

ICD10_codes = filter(row -> row.system == "ICD10CM", ICD_codes)

println("successfully loaded the ICD codes")


df_concept = CSV.read("CONCEPT.csv", DataFrame)

df_concept_relationship = CSV.read("CONCEPT_RELATIONSHIP.csv", DataFrame)



# Remove decimal points from the ICD-10 code column
df_concept.concept_code = replace.(df_concept.concept_code, "." => "")
println("successfully loaded the vocabulary files")

#sanity check
filter(row -> row.concept_code == "F81.0", df_concept)

#filter maps to relationship
df_concept_relationship_mapsto = filter(row -> (row.relationship_id == "Maps to"|| row.relationship_id == "Maps to value"), df_concept_relationship)

# sanity check
unique(df_concept_relationship_mapsto.relationship_id)

df_concept_relationship_mapsto_select = select(df_concept_relationship_mapsto, :concept_id_1, :concept_id_2, :relationship_id)

#filter the concept.csv for domain = condition
#df_concept_condition = filter(row -> row.domain_id == "Condition" || row.domain_id == "Observation", df_concept)

#filter for vocabulary_id  = ICD10CM and ICD9CM
df_concept_ICD9 = filter(row -> (row.vocabulary_id == "ICD9CM"), df_concept)

df_concept_ICD10 = filter(row -> (row.vocabulary_id == "ICD10CM"), df_concept)

df_concept_ICD9_select = select(df_concept_ICD9, :concept_id, :concept_code, :concept_name, :domain_id, :vocabulary_id)

rename!(df_concept_ICD9_select, :concept_name => :source_concept_name, :domain_id => :source_domain_id, :vocabulary_id => :source_vocabulary_id)

df_concept_ICD10_select = select(df_concept_ICD10, :concept_id, :concept_code, :concept_name, :domain_id, :vocabulary_id)

rename!(df_concept_ICD10_select, :concept_name => :source_concept_name, :domain_id => :source_domain_id, :vocabulary_id => :source_vocabulary_id)


#left join ICD9_codes and with the concept table on VALUE and concept_code

join_ICD9_concept = leftjoin(ICD9_codes, df_concept_ICD9_select, on = ( :VALUE => :concept_code))


# left join join_ICD_concept and df_concept_relationship_mapsto on concept_id and concept_id_1
join_ICD9_concept_relationship = leftjoin(join_ICD9_concept, df_concept_relationship_mapsto_select, on = (:concept_id => :concept_id_1))

ICD9_SNOMED_MAP = rename(join_ICD9_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :omop_concept_id)

#adding the concept name and domain id for the standard omop concept id---- for doing this join the above dataframe with the concept table on omop_concept_id and concept_id in concept table

icd9_omop_standard = leftjoin(ICD9_SNOMED_MAP, df_concept, on = (:omop_concept_id => :concept_id))

select!(icd9_omop_standard, Not(:concept_code))
#missing 4
count(ismissing,icd9_omop_standard.omop_concept_id)


#CSV.write("/data/ursa_research/n3c/mthakkal/radxup_project/highneeds/ICD_OMOP_codes/ICD9_OMOP_MAP.csv", icd9_omop_standard)


#left join ICD10_codes and df_concept_condition on VALUE and concept_code

join_ICD10_concept = leftjoin(ICD10_codes, df_concept_ICD10_select, on = (:VALUE => :concept_code))

# left join join_ICD10_concept and df_concept_relationship_mapsto on concept_id and concept_id_1
join_ICD10_concept_relationship = leftjoin(join_ICD10_concept, df_concept_relationship_mapsto_select, on = (:concept_id => :concept_id_1))

ICD10_SNOMED_MAP = rename(join_ICD10_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :omop_concept_id)

#adding the concept name and domain id for the standard omop concept id---- for doing this join the above dataframe with the concept table on omop_concept_id and concept_id in concept table

icd10_omop_standard = leftjoin(ICD10_SNOMED_MAP, df_concept, on = (:omop_concept_id => :concept_id))
select!(icd10_omop_standard, Not(:concept_code))

#missing 3
count(ismissing,icd10_omop_standard.omop_concept_id)


#CSV.write("/data/ursa_research/n3c/mthakkal/radxup_project/highneeds/ICD_OMOP_codes/ICD10_OMOP_MAP.csv", icd10_omop_standard)

test_filter = filter(row -> row.concept_id_2 == join_ICD9_concept.concept_id, df_concept_relationship_mapsto_select)

#combine both files

combined = vcat(icd9_omop_standard, icd10_omop_standard)

# CSV.write("/Users/mounikathakkallapally/Desktop/Brown/OmopVocabMapper/$working_drive/omopmappedcodes_$working_drive.CSV", combined)

CSV.write("omopmappedcodes.csv", combined)

println("successfully mapped the ICD codes to OMOP please check the repo folder with the name omopmappedcodes.CSV file for the OMOP codes")
#/data/ursa_software/riqi_code/Vocabularies/20230301/ ---- vocab files

# SELECT distinct cr.concept_id_2 AS snomed_concept_id,  c.concept_code AS icd10_code
# FROM cdm.concept_relationship cr
# JOIN cdm.concept c ON c.concept_id = cr.concept_id_1
# WHERE cr.relationship_id = 'Maps to' -- Use 'Maps to' relationship for ICD-10 to SNOMED mapping
#   AND c.concept_code in ('F81.0','F81.2', 'F81.8', '315.0', '315.00')



