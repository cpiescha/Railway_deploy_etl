FROM apache/airflow:2.10.2

# Cambia a root para instalar dependencias y crear directorios
USER root

# Instala supervisor
RUN apt-get update && apt-get install -y supervisor

# Crea directorios necesarios y ajusta permisos
RUN mkdir -p /opt/airflow/dags /opt/airflow/tmp /opt/airflow/plugins/operators \
    && mkdir -p /var/log/supervisor \
    && chown -R 50000:0 /opt/airflow /var/log/supervisor

# Copia archivos necesarios
COPY requirements.txt /opt/airflow/requirements.txt
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

COPY dags/ /opt/airflow/dags/
COPY tmp/ /opt/airflow/tmp/
COPY plugins/operators/ /opt/airflow/plugins/operators
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Anula el entrypoint de la imagen oficial para que no intente anteponer "airflow"
ENTRYPOINT []

# Usa el usuario correcto
USER 50000

WORKDIR /opt/airflow
EXPOSE 8080

# Ejecuta supervisord directamente
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]