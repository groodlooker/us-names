view: name_rank {

    derived_table: {
      explore_source: us_names {
        column: name {}
        column: year {}
        column: total_number {}
        column: gender {}
        derived_column: name_rank_year {
          sql: RANK() OVER(PARTITION BY year ORDER BY total_number DESC) ;;
        }
        derived_column: name_rank_year_gender {
          sql: RANK() OVER(PARTITION BY year, gender ORDER BY total_number DESC) ;;
        }
#         derived_column: name_rank_year_state {
#           sql: RANK() OVER(PARTITION BY year, state ORDER BY total_number DESC) ;;
#         }
#         derived_column: name_rank_year_state_gender {
#           sql: RANK() OVER(PARTITION BY year, state, gender ORDER BY total_number DESC) ;;
#         }
        derived_column: name_rank_gender {
          sql: RANK() OVER(PARTITION BY gender ORDER BY total_number DESC) ;;
        }
        filters: {
          field: us_names.year
          value: ">2004"
        }
      }

    }
    dimension: name {}
    dimension: gender {}
    dimension: year {
      type: number
    }
    dimension: total_number {
      type: number
    }
#     dimension: state {}
    dimension: name_rank_year {
      type: number
      map_layer_name: us_states
    }
    dimension: name_rank_gender {
      type: number
    }
    measure: min_rank_gender_year {
      type: min
      sql: ${name_rank_year_gender} ;;
    }
    dimension: name_rank_year_gender {
      type: number
    }
    dimension: name_rank_year_state {
      type: number
    }
    dimension: name_rank_year_state_gender {
      type: number
    }
    measure: name_bump {
      type: string
      label: "Top Names"
      sql: MAX(${name}) ;;
      drill_fields: [name_count_prediction.state,name_count_prediction.total_name_count]
    }

}

explore: name_rank {}


view: min_name_rank {
  derived_table: {
    explore_source: name_rank {
      column: name {}
      column: gender {}
      column: min_rank_gender_year {}
    }
  }
  dimension: pk {
    type: string
    primary_key: yes
    sql: concat(${name},${gender}) ;;
  }
  dimension: name {}
  dimension: gender {}
  dimension: min_rank_gender_year {
    type: number
  }
}
