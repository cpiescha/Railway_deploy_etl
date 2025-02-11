FROM apache/airflow:2.10.2

# Configura el directorio de trabajo
WORKDIR /opt/airflow

# Configura variables de entorno necesarias
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__FERNET_KEY=AIRFLOW__CORE__FERNET_KEY

# Instalar dependencias del sistema (necesarias para algunas bibliotecas de Python)
USER root
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios dentro del contenedor
RUN mkdir -p /opt/airflow/dags \
             /opt/airflow/img \
             /opt/airflow/tmp \
             /opt/airflow/plugins/operators

# Copiar archivos necesarios
COPY requirements.txt /opt/airflow/requirements.txt
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

COPY dags/ /opt/airflow/dags/
COPY img/ /opt/airflow/img/
COPY tmp/ /opt/airflow/tmp/
COPY plugins/operators/ /opt/airflow/plugins/operators/

# Copiar configuración de supervisord para manejar múltiples procesos
COPY supervisord.conf /opt/airflow/supervisord.conf

# Exponer puerto para la interfaz web de Airflow
EXPOSE 8080

# Establecer usuario por defecto
USER airflow

# Iniciar supervisord para ejecutar el scheduler, webserver y otros servicios
CMD ["supervisord", "-c", "/opt/airflow/supervisord.conf"]