{% test schema_change( model ) %}


with previous_updated_date as(
    select distinct profiling_date, 
    dense_rank() OVER(ORDER BY profiling_date DESC) as update_rank
    FROM {{ model }}
    qualify update_rank = 2

)

select *
from (
    select
       
     column_name ||'-'|| data_type

    from {{ model }}
    where profiling_date = current_date()

    and column_name || data_type not in 
    ( select  column_name || data_type from {{model}}  where profiling_date = (select profiling_date from previous_updated_date))

    UNION ALL 

    select
       
     column_name ||'-'|| data_type

    from {{ model }}
    where profiling_date = (select profiling_date from previous_updated_date)

    and column_name || data_type  not in 
    ( select column_name || data_type  from {{model}}  where profiling_date = current_date())

) validation_errors

{% endtest %}
