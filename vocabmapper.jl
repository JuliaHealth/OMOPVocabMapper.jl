using CSV, DataFrames, StatsBase, Query, Dates


#load the csv files
ICD_codes = CSV.read("/data/ursa_research/radxup/daluthge/highneeds.icd.csv.2023.05.05", DataFrame) #21740 | Unique = 20306

#there are few VALUES with decimal points so removing them
ICD_codes.VALUE = replace.(ICD_codes.VALUE, "." => "")

# mapping codes according to the vocabulary to avoid wrong mappings example E000 and E00.0
ICD9_codes = filter(row -> row.SYSTEM == "ICD-9-CM", ICD_codes)

ICD10_codes = filter(row -> row.SYSTEM == "ICD-10-CM", ICD_codes)

# import vocab tables
df_concept = CSV.read("/data/ursa_software/riqi_code/Vocabularies/20230301/CONCEPT.csv", DataFrame)

df_concept_relationship = CSV.read("/data/ursa_software/riqi_code/Vocabularies/20230301/CONCEPT_RELATIONSHIP.csv", DataFrame)

# Remove decimal points from the ICD-10 codes in concept table
df_concept.concept_code = replace.(df_concept.concept_code, "." => "")

#sanity check
filter(row -> row.concept_code == "F81.0", df_concept)

#filter maps to relationship
df_concept_relationship_mapsto = filter(row -> row.relationship_id == "Maps to", df_concept_relationship)

df_concept_relationship_mapsto_select = select(df_concept_relationship_mapsto, :concept_id_1, :concept_id_2)

#filter the concept.csv for domain = condition
#df_concept_condition = filter(row -> row.domain_id == "Condition" || row.domain_id == "Observation", df_concept)

#filter for vocabulary_id  = ICD10CM and ICD9CM
df_concept_ICD9 = filter(row -> (row.vocabulary_id == "ICD9CM"), df_concept)

df_concept_ICD10 = filter(row -> (row.vocabulary_id == "ICD10CM"), df_concept)

df_concept_ICD9_select = select(df_concept_ICD9, :concept_id, :concept_code, :concept_name, :domain_id, :vocabulary_id)

df_concept_ICD10_select = select(df_concept_ICD10, :concept_id, :concept_code, :concept_name, :domain_id, :vocabulary_id)


#left join ICD9_codes and df_concept_condition on VALUE and concept_code

join_ICD9_concept = join(ICD9_codes, df_concept_ICD9_select, on = (:VALUE, :concept_code), kind = :left)

# left join join_ICD_concept and df_concept_relationship_mapsto on concept_id and concept_id_1
join_ICD9_concept_relationship = join(join_ICD9_concept, df_concept_relationship_mapsto_select, on = (:concept_id, :concept_id_1), kind = :left)

ICD9_SNOMED_MAP = rename!(join_ICD9_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :OMOP_concept_id)

#missing 4
count(ismissing,ICD9_SNOMED_MAP.OMOP_concept_id)


CSV.write("/data/ursa_research/n3c/mthakkal/radxup_project/highneeds/ICD9_OMOP_MAP.csv", ICD9_SNOMED_MAP)


#left join ICD10_codes and df_concept_condition on VALUE and concept_code

join_ICD10_concept = join(ICD10_codes, df_concept_ICD10_select, on = (:VALUE, :concept_code), kind = :left)

# left join join_ICD10_concept and df_concept_relationship_mapsto on concept_id and concept_id_1
join_ICD10_concept_relationship = join(join_ICD10_concept, df_concept_relationship_mapsto_select, on = (:concept_id, :concept_id_1), kind = :left)

ICD10_SNOMED_MAP = rename!(join_ICD10_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :OMOP_concept_id)

#missing 3
count(ismissing,ICD10_SNOMED_MAP.OMOP_concept_id)


CSV.write("/data/ursa_research/n3c/mthakkal/radxup_project/highneeds/ICD10_OMOP_MAP.csv", ICD10_SNOMED_MAP)



#/data/ursa_software/riqi_code/Vocabularies/20230301/ ---- vocab files

# SELECT distinct cr.concept_id_2 AS snomed_concept_id,  c.concept_code AS icd10_code
# FROM cdm.concept_relationship cr
# JOIN cdm.concept c ON c.concept_id = cr.concept_id_1
# WHERE cr.relationship_id = 'Maps to' -- Use 'Maps to' relationship for ICD-10 to SNOMED mapping
#   AND c.concept_code in ('F81.0','F81.2', 'F81.8', '315.0', '315.00')
