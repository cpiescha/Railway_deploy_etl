FROM apache/airflow:2.10.2

# Configurar el directorio de trabajo
WORKDIR /opt/airflow

# Configurar variables de entorno
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__FERNET_KEY=AIRFLOW__CORE__FERNET_KEY

# Crear directorios
RUN mkdir -p /opt/airflow/dags \
             /opt/airflow/img \
             /opt/airflow/tmp \
             /opt/airflow/plugins/operators

# Cambiar a usuario airflow antes de instalar dependencias
USER airflow

# Copiar e instalar dependencias
COPY --chown=airflow:airflow requirements.txt /opt/airflow/requirements.txt
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

# Copiar código fuente
COPY --chown=airflow:airflow dags/ /opt/airflow/dags/
COPY --chown=airflow:airflow img/ /opt/airflow/img/
COPY --chown=airflow:airflow tmp/ /opt/airflow/tmp/
COPY --chown=airflow:airflow plugins/operators/ /opt/airflow/plugins/operators/

# Copiar configuración de supervisord
COPY --chown=airflow:airflow supervisord.conf /opt/airflow/supervisord.conf

# Exponer puerto webserver
EXPOSE 8080

# Usar supervisord para ejecutar scheduler y webserver
CMD ["supervisord", "-c", "/opt/airflow/supervisord.conf"]