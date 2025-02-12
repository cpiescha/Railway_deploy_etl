FROM apache/airflow:2.10.2

# Crea los directorios necesarios
RUN mkdir -p /opt/airflow/dags /opt/airflow/tmp /opt/airflow/plugins/operators /var/log/supervisor

# Instala dependencias
COPY requirements.txt /opt/airflow/requirements.txt
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

# Copia los archivos necesarios
COPY dags/ /opt/airflow/dags/
COPY tmp/ /opt/airflow/tmp/
COPY plugins/operators/ /opt/airflow/plugins/operators
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Establece el directorio de trabajo
WORKDIR /opt/airflow

# Expone el puerto del webserver
EXPOSE 8080

# Usa supervisord para manejar los procesos
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]