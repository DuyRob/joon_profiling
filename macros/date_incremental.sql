{% macro date_incremental(date_column, increment = 1 ,is_day_incremental = True) %}
  {{ return(adapter.dispatch('date_incremental')( date_column, increment,is_day_incremental)) }}
{% endmacro %}

{% macro snowflake__date_incremental(date_column, increment, is_day_incremental) %}
{%- if execute -%}
     
    {% if is_incremental() %}
    {%- set get_last_updated  -%}
      select 
        last_altered     {# This is the latest altered date of the table, in information_schema.tables #}
      from {{this.database}}.information_schema.tables
      where table_schema = UPPER('{{this.schema}}')   {# Value returned in dbt class is in lower case, while value recorded within information_schema is always uppercase #}
      and table_name = UPPER('{{this.include(database=false, schema=false)}}')
    {%- endset -%}
    {%- set last_updated = run_query(get_last_updated).columns[0].values() -%}
    {% if not is_day_incremental %}
      and {{ date_column }} >= (select dateadd('hour', -{{ increment }}, datetime('{{ last_updated[0] }}')))
    {% else %} 
      and {{ date_column }} >= (select dateadd('day', -{{ increment }}, date('{{ last_updated[0] }}')))
    {% endif %}
   {% endif %}
{% endif %}
{% endmacro %}



{% macro bigquery__date_incremental(date_column, increment, is_day_incremental) %}
{%- if execute -%}
    {% if is_incremental() %}
        {%- set get_last_updated  -%}
          select 
            TIMESTAMP_MILLIS(last_modified_time)  
          from {{this.database}}.{{this.schema}}.__TABLES__
          where table_id = '{{this.include(database=false, schema=false)|replace("`","")}}'
      {%- endset -%}
      {%- set last_updated = run_query(get_last_updated).columns[0].values() -%}
      {% if not is_day_incremental %}
          and {{ date_column }} >= (select datetime_sub( datetime('{{ last_updated[0] }}'), INTERVAL {{ increment }} HOUR ))
       {% else %} 
          and {{ date_column }} >= (select date_sub(date('{{ last_updated[0] }}'), INTERVAL {{ increment }} DAY ))
      {% endif %}
    {% endif %}
{% endif %}
{% endmacro %}