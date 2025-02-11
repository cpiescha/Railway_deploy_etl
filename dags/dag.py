from datetime import timedelta,datetime
# The DAG object; we'll need this to instantiate a DAG
from airflow.models import DAG
#from airflow.operators.python import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.providers.mongo.hooks.mongo import MongoHook
from operators.mongodb_file_operator import MongoDBOperator
from airflow.operators.python import PythonOperator
import json
# from operators import PostgresFileOperator

#defining DAG arguments
# You can override them on a per-task basis during operator initialization

    
    
default_args = {
     'owner': 'camilo',
     'start_date': days_ago(0),
     'email': ['milo0@gmail.com'],
     'email_on_failure': False,
     'email_on_retry': False,
     'retries': 1,
     'retry_delay': timedelta(minutes=5),
 }
    
 # defining the DAG
 # define the DAG
dag = DAG(
     dag_id='nasa_dag',
     default_args=default_args,
     schedule_interval='@hourly',
     catchup=False,
     max_active_runs=1,
     concurrency=1
 )

extract_data = BashOperator(
    task_id='extract_data',
    bash_command='python /opt/airflow/tmp/extract_api_nasa.py',
    dag=dag
)

create_database = MongoDBOperator(
        task_id='create_data',
        mongo_conn_id='mongo_default',
        database='etlprocess',
        collection='nasa',
        operation='create_collection',
        
    )

insert_data = MongoDBOperator(
        task_id='insert_data',
        mongo_conn_id='mongo_default',
        database='etl_nasa',
        collection='nasa',
        operation='insert',
        json_file_path='/opt/airflow/tmp/data.json'
        
    )
 

create_database >> extract_data >> insert_data