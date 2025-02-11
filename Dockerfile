# Usa la imagen oficial de Airflow (ajusta la versión según tus necesidades)
FROM apache/airflow:2.10.2

# Configura algunas variables de entorno para Airflow (ajusta según tu configuración)
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
# (Opcional) Genera o define una clave Fernet para encriptar conexiones/variables
ENV AIRFLOW__CORE__FERNET_KEY=AIRFLOW__CORE__FERNET_KEY

# Crea los directorios necesarios dentro del contenedor
RUN mkdir -p /opt/airflow/dags \
             /opt/airflow/img \
             /opt/airflow/tmp \
             /opt/airflow/plugins/operators \

# (Opcional) Si tienes dependencias adicionales, cópialas e instálalas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia el contenido de cada carpeta de tu repositorio al directorio correspondiente en la imagen
COPY dags/ /opt/airflow/dags/
COPY img/ /opt/airflow/img/
# Aunque la carpeta logs normalmente se genere en tiempo de ejecución, se puede copiar una estructura base
COPY tmp/ /opt/airflow/tmp/
COPY plugins/operators/ /opt/airflow/plugins/operators

# Establece el directorio de trabajo
WORKDIR /opt/airflow

# Expone el puerto para el Airflow Webserver (ajusta si es necesario)
EXPOSE 8080

# Configura el entrypoint y el comando por defecto.
# La imagen oficial ya trae el script de entrada "docker-entrypoint.sh"
ENTRYPOINT ["docker-entrypoint.sh"]

# Define el comando por defecto. Puedes iniciar el scheduler, el webserver o ambos a través de supervisord.
# Ejemplo para iniciar el scheduler:
CMD ["airflow", "scheduler"]

# Si prefieres iniciar el webserver, podrías cambiar CMD a:
CMD ["airflow", "webserver"]