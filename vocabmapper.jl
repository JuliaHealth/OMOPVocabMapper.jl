@info "Loading packages..."
using CSV
using DataFrames
using StatsBase
using Query
using Dates

@info "Loading CSV files..."
ICD_codes = CSV.read("/data/ursa_research/radxup/daluthge/highneeds.icd.csv.2023.05.05", DataFrame) #21740 | Unique = 20306
df_concept = CSV.read("/data/ursa_software/riqi_code/Vocabularies/20230301/CONCEPT.csv", DataFrame)
df_concept_relationship = CSV.read("/data/ursa_software/riqi_code/Vocabularies/20230301/CONCEPT_RELATIONSHIP.csv", DataFrame)

# Show description of DataFrame, including number of unique values in each row
function fully_describe(DF)
	q = describe(DF)
	q.num_unique_vals = map(x->length(DF[!,x] |> unique), names(DF))
	q
end
println()
println("Summary of ICD Codes:")
show(
	fully_describe(ICD_codes),
	allrows=true, allcols=true
) 
println()
println()

@info "Mapping codes..."
# Remove decimal points from the ICD codes
ICD_codes.VALUE = replace.(ICD_codes.VALUE, "." => "")
df_concept.concept_code = replace.(df_concept.concept_code, "." => "")
@assert isempty(filter(x->contains(x.VALUE, "."), ICD_codes))

# mapping codes according to the vocabulary to avoid wrong mappings example E000 and E00.0
code_systems = groupby(ICD_codes, :SYSTEM)
df_concept_relationship_mapsto = filter(row -> row.relationship_id == "Maps to", df_concept_relationship)
df_concept_relationship_mapsto_select = select(df_concept_relationship_mapsto, :concept_id_1, :concept_id_2)

#filter the concept.csv for domain = condition
#df_concept_condition = filter(row -> row.domain_id == "Condition" || row.domain_id == "Observation", df_concept)

#filter for vocabulary_id  = ICD10CM and ICD9CM
# I removed :concept_name. Is this field haunted?
df_concept_systems = groupby(df_concept, :vocabulary_id)
df_concept_ICD9_select = select(df_concept_systems[("ICD9CM",)], :concept_id, :concept_code, :domain_id, :vocabulary_id)
df_concept_ICD10_select = select(df_concept_systems[("ICD10CM",)], :concept_id, :concept_code, :domain_id, :vocabulary_id)

@info "Combining tables..."
#left join ICD codes and df_concept_condition on VALUE and concept_code
join_ICD9_concept = leftjoin(code_systems[("ICD-9-CM",)], df_concept_ICD9_select, on = Pair(:VALUE, :concept_code))
join_ICD10_concept = leftjoin(code_systems[("ICD-10-CM",)], df_concept_ICD10_select, on = Pair(:VALUE, :concept_code))

# left join join_ICD_concept and df_concept_relationship_mapsto on concept_id and concept_id_1
join_ICD9_concept_relationship = leftjoin(join_ICD9_concept, df_concept_relationship_mapsto_select, on = Pair(:concept_id, :concept_id_1), matchmissing=:notequal)
join_ICD10_concept_relationship = leftjoin(join_ICD10_concept, df_concept_relationship_mapsto_select, on = Pair(:concept_id, :concept_id_1), matchmissing=:notequal)

ICD9_SNOMED_MAP = rename!(join_ICD9_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :OMOP_concept_id)
ICD10_SNOMED_MAP = rename!(join_ICD10_concept_relationship, :concept_id => :source_concept_id, :concept_id_2 => :OMOP_concept_id)

@info "Verifying results..."
@assert count(ismissing,ICD9_SNOMED_MAP.OMOP_concept_id) == 4
@assert count(ismissing,ICD10_SNOMED_MAP.OMOP_concept_id) == 3

@info "Exporting results..."
CSV.write("/data/ursa_research/n3c/OmopVocabMapper/ICD9_OMOP_MAP.csv", ICD9_SNOMED_MAP)
CSV.write("/data/ursa_research/n3c/OmopVocabMapper/ICD10_OMOP_MAP.csv", ICD10_SNOMED_MAP)

#/data/ursa_software/riqi_code/Vocabularies/20230301/ ---- vocab files

# SELECT distinct cr.concept_id_2 AS snomed_concept_id,  c.concept_code AS icd10_code
# FROM cdm.concept_relationship cr
# JOIN cdm.concept c ON c.concept_id = cr.concept_id_1
# WHERE cr.relationship_id = 'Maps to' -- Use 'Maps to' relationship for ICD-10 to SNOMED mapping
#   AND c.concept_code in ('F81.0','F81.2', 'F81.8', '315.0', '315.00')
