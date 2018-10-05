## Data for model input ##
view: names_input_data {
  derived_table: {
    explore_source: us_names {
      column: gender {}
      column: name {}
      column: number {}
#       column: state {}
      column: year {}
      filters: {
        field: us_names.year
        value: ">2004"
      }
    }

  }
  dimension: gender {}
  dimension: name {}
  dimension: number {
    type: number
  }
#   dimension: state {}
  dimension: year {
    type: number
  }
}

## Model Creation ##

view: name_count_regression {
  derived_table: {
    datagroup_trigger: ryans_mad_analysis_datagroup
    sql_create:
      create or replace model ${SQL_TABLE_NAME}
      options(model_type='linear_reg',labels=['number'],
      max_iteration=100) as
      select *
      from ${names_input_data.SQL_TABLE_NAME};;
  }
}

explore: model_info {}

view: model_info {
  derived_table: {
    sql: select * from ml.training_info(model ${name_count_regression.SQL_TABLE_NAME}) ;;
  }
  dimension: training_run {type:number}
  dimension: iteration {type:number}
  dimension: loss {type:number}
  dimension: eval_loss {type:number}
  dimension: duration_ms {type:number}
  dimension: learning_rate {type:number}
  measure: iterations {type:count}
  measure: total_loss {type:sum sql:${loss};;}
}

## Model Output and Evaluation ##

explore: name_count_model_performance {}

view: name_count_model_performance {
  derived_table: {
    sql: select * from ml.evaluate(
          model ${name_count_regression.SQL_TABLE_NAME},
          (select * from ${names_input_data.SQL_TABLE_NAME}));;
  }
  dimension: mean_squared_error {type:number value_format_name:decimal_2}
  dimension: r2_score {type:number value_format_name:decimal_2}
  dimension: mean_absolute_error{type: number value_format_name:decimal_2}
  dimension: mean_squared_log_error {type:number value_format_name:decimal_2}
  dimension: median_absolute_error {type:number value_format_name:decimal_2}
}

view: name_count_prediction {
  derived_table: {
    sql: select * from ml.predict(
        model ${name_count_regression.SQL_TABLE_NAME},
        (select * from ${names_input_data.SQL_TABLE_NAME}));;
  }
  dimension: predicted_number {
    type: number
  }
  dimension: gender {
    type: string
  }
  dimension: number {
    type: number
  }
  dimension: name {
    type: string
    hidden: no
  }
  measure: name_bump {
    type: string
    label: "Top Names"
    sql: MAX(${name_rank.name}) ;;
    drill_fields: [total_name_count]
  }
#   dimension: state {type:string hidden:no map_layer_name:us_states}
  dimension: year {type:number hidden:no}
  dimension: residual {
    type: number
    sql: abs(${predicted_number} - ${number}) ;;
  }
  measure: average_error {type:average sql:${residual};;}
  measure: total_name_count {type:sum sql: ${number};; value_format_name:decimal_0}
  measure: total_predicted_name_count {type:sum sql: ${predicted_number};; value_format_name:decimal_0}
}
