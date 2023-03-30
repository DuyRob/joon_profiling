Welcome to your new dbt project!

### Joon Source-Profiler
A profiling alternative that's completly run on dbt cloud. Currently available for BigQuery

### Functionality: 
- Scan newly ingested data from source tables 
- Store the daily scanned statistics into a table, which can then be visualized. 
- Warn if the degree of null in a columns exceed a certain values. 
- Warn if source data schema were changed compare to previous days. 

### How to use:
- Install this package + dbt_utils using dbt deps. This package depends on dbt_utils.
- Create a new profiling folder within your models. Specify the schema to save your profiling models to in your dbt_project.yml
```
    profiling:
      +database: your_database
      +materialized: table
      +schema: schema_name
      
```


- Generate profile tables using joon_profliling.source_profiling:
```
 dbt run-operation joon_profliling.source_profiling --args '{"source_name": "source", "table_name": "table", "check_na" =True, date_incremental: "date","condition":"and abc = def"}'
 ```
source_name, table_name:String. The source and table name of the table we're profiling for, as included in the yml file 
check_na: True/False. Whether or not to check for n/a, --, __, '' values in strings . Default True
date_incremental: Whether to profile table incrementally. Default none. Provide the column name of the partitioning date table for daily incremental run instead of re-runing 
condition: SQL condition in the form of "and ...." .Extra condition to apply to the profile table. Ie.When a table must have a restriction for the partitioned field. 

Paste the generated files to your profile folder


- Generate the yml files with tests applied. Use the same schema as specified in your dbt project. 
```
 dbt run-operation joon_profliling.profile_yml --args '{"dataset":"schema_name"}
 ```
 Paste the result yml to your profile folder 

