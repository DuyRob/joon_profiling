{% macro profiling_yaml(dataset) %}
  {{ return(adapter.dispatch('profiling_yaml')(dataset)) }}
{% endmacro %}

{% macro bigquery__profiling_yaml(dataset) %}
{% set schema_query %}
select table_id from `{{target.database}}.{{dataset}}.__TABLES__`
where 1=1
{% endset %}
{% if execute %}
{%- set model_list = run_query(schema_query).columns[0].values()|list  -%}
{%- set model_yaml = [] -%}

{% do model_yaml.append('version: 2') %}
{% do model_yaml.append('') %}
{% do model_yaml.append('models:') %}
{% for model_name in model_list  if '_dbt_tmp' not in model_name %}
{% do model_yaml.append('  - name: ' ~ model_name | lower) %}
{% do model_yaml.append('    description: ""') %}
{% do model_yaml.append('    tests:') %}
{% do model_yaml.append('      - schema_change') %}
{% do model_yaml.append('    columns:') %}
{% do model_yaml.append('      - name: not_null_propotion:') %}
{% do model_yaml.append('        tests:') %}
{% do model_yaml.append('          - dbt_utils.accepted_range:') %}
{% do model_yaml.append('              min_value: 0.9') %}
{% do model_yaml.append('      - name: row_count:') %}
{% do model_yaml.append('        tests:') %}
{% do model_yaml.append('          - dbt_utils.accepted_range:') %}
{% do model_yaml.append('              min_value: 1') %}
{% do model_yaml.append('\n') %}
{%- endfor -%}
    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}



{% macro snowflake__profiling_yaml(dataset) %}
{% set schema_query %}
    select 
        last_altered 
      from {{target.database}}.information_schema.tables
      where table_schema = UPPER('{{dataset}}')
{% endset %}
{% if execute %}
{%- set model_list = run_query(schema_query).columns[0].values()| map('lower')|list  -%}
{%- set model_yaml = [] -%}

{% do model_yaml.append('version: 2') %}
{% do model_yaml.append('') %}
{% do model_yaml.append('models:') %}
{% for model_name in model_list  if '_dbt_tmp' not in model_name %}
{% do model_yaml.append('  - name: ' ~ model_name | lower) %}
{% do model_yaml.append('    description: ""') %}
{% do model_yaml.append('    tests:') %}
{% do model_yaml.append('      - schema_change') %}
{% do model_yaml.append('    columns:') %}
{% do model_yaml.append('      - name: not_null_propotion:') %}
{% do model_yaml.append('        tests:') %}
{% do model_yaml.append('          - dbt_utils.accepted_range:') %}
{% do model_yaml.append('              min_value: 0.9') %}
{% do model_yaml.append('      - name: row_count:') %}
{% do model_yaml.append('        tests:') %}
{% do model_yaml.append('          - dbt_utils.accepted_range:') %}
{% do model_yaml.append('              min_value: 1') %}
{% do model_yaml.append('\n') %}
{%- endfor -%}

    
    {% set joined = model_yaml | join ('\n') %} 
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
