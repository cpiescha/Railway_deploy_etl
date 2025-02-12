FROM apache/airflow:2.10.2

# Cambia a root para realizar tareas de instalación y creación de directorios
USER root

# (Opcional) Instala paquetes del sistema si es necesario
RUN apt-get update && apt-get install -y supervisor \
    && rm -rf /var/lib/apt/lists/*

# Crea los directorios necesarios y asegúrate de que tengan los permisos correctos
RUN mkdir -p /opt/airflow/dags /opt/airflow/tmp /opt/airflow/plugins/operators \
    && mkdir -p /var/log/supervisor \
    && chown -R 50000:0 /opt/airflow /var/log/supervisor

# Establece el directorio de trabajo
WORKDIR /opt/airflow

# Copia el archivo requirements.txt y cambia su propiedad al usuario airflow
COPY --chown=airflow:airflow requirements.txt /opt/airflow/requirements.txt

# Cambia al usuario airflow para instalar las dependencias con pip
USER airflow

# Ejecuta pip install como el usuario airflow
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt

# Copia el resto de los archivos del proyecto con la propiedad correcta
COPY --chown=airflow:airflow dags/ /opt/airflow/dags/
COPY --chown=airflow:airflow tmp/ /opt/airflow/tmp/
COPY --chown=airflow:airflow plugins/operators/ /opt/airflow/plugins/operators/

# Copia el archivo de configuración de supervisord (si usas supervisord para orquestar múltiples servicios)
COPY --chown=airflow:airflow supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# (Opcional) Si deseas que se ejecute supervisord en vez de un comando de Airflow directo, anula el entrypoint de la imagen oficial:
ENTRYPOINT []

# Mantén el usuario airflow (en este caso, el UID 50000)
USER 50000

# Expone el puerto del webserver
EXPOSE 8080

# Define el comando a ejecutar al iniciar el contenedor.
# Si deseas ejecutar directamente un comando de Airflow, puedes usar, por ejemplo:
# CMD ["airflow", "webserver"]

# Si prefieres usar supervisord para manejar múltiples procesos, asegúrate de haber anulado el entrypoint y usa:
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]