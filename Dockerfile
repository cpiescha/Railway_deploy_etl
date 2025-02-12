FROM apache/airflow:2.10.2

# Cambia a root para crear los directorios
USER root

# Crea los directorios con permisos adecuados
RUN mkdir -p /opt/airflow/dags /opt/airflow/tmp /opt/airflow/plugins/operators \
    && mkdir -p /var/log/supervisor \
    && chown -R airflow:airflow /opt/airflow /var/log/supervisor

# Cambia de vuelta al usuario airflow
USER airflow

# Copia los archivos necesarios
COPY requirements.txt /opt/airflow/requirements.txt
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

COPY dags/ /opt/airflow/dags/
COPY tmp/ /opt/airflow/tmp/
COPY plugins/operators/ /opt/airflow/plugins/operators
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Establece el directorio de trabajo
WORKDIR /opt/airflow

# Expone el puerto del webserver
EXPOSE 8080

# Ejecuta supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]