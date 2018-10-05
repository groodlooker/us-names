connection: "se_pbl"

# include all the views
include: "*.view"

datagroup: ryans_mad_analysis_datagroup {
  sql_trigger: SELECT MAX(item) FROM deals;;
  max_cache_age: "1 hour"
}

persist_with: ryans_mad_analysis_datagroup

explore: us_names {}

explore: name_count_prediction {
  join: name_rank {
    fields: [name_rank.name_rank_year_gender,name_rank.name_rank_gender]
    sql_on: ${name_count_prediction.name} = ${name_rank.name}
    and ${name_count_prediction.gender} = ${name_rank.gender}
    and ${name_count_prediction.year} = ${name_rank.year};;
    relationship: one_to_one
    type: inner
  }
}
