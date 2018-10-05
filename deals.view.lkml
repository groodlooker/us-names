view: deals {
  sql_table_name: black_friday.deals ;;

  dimension: categories {
    type: string
    sql: ${TABLE}.Category ;;
  }

  dimension: category {
    type: string
    sql: split(${categories},">>")[offset(0)] ;;
  }

  dimension: sub_category {
    type: string
    sql: if(array_length(split(${categories},">>")) = 2, split(${categories},">>")[offset(1)],"") ;;
  }

  dimension: is_numeric {
    type: yesno
    sql: ${TABLE}.is_numeric ;;
  }

  dimension: item {
    type: string
    sql: ${TABLE}.Item ;;
  }

  dimension: original_price {
    type: string
    sql: ${TABLE}.Original_Price ;;
  }

  dimension: sale_price {
    type: string
    sql: ${TABLE}.Sale_Price ;;
  }

  dimension: is_not_null {
    type: yesno
    sql: if(ifnull(${original_price},'1') = '1',1,0) + if(ifnull(${sale_price},'1') = '1',1,0) = 0;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.Store ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}.URL ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
