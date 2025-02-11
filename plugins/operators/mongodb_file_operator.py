from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from pymongo import MongoClient
import json

class MongoDBOperator(BaseOperator):
    
    @apply_defaults
    def __init__(self, mongo_conn_id: str, database: str, collection: str, operation: str, json_file_path=None, data=None, query=None, **kwargs):
        super().__init__(**kwargs)
        self.mongo_conn_id = mongo_conn_id
        self.database = database
        self.json_file_path = json_file_path
        self.collection = collection  # Cambié de "collection" a "collection_name"
        self.operation = operation
        self.data = data or {}
        self.query = query or {}

    def execute(self, context):
        from airflow.hooks.base import BaseHook
        connection = BaseHook.get_connection(self.mongo_conn_id)
        
        # Recuperar parámetros extra (si existen) para determinar si usamos SRV
        extra = connection.extra_dejson
        srv = extra.get("srv", False)
        tls = extra.get("tls", False)

        user = connection.login
        password = connection.password
        host = connection.host
        schema = self.database  # O connection.schema si lo configuraste así

        if srv:
            # Construir URI para clúster SRV
            uri = f"mongodb+srv://{user}:{password}@{host}/{schema}?retryWrites=true&w=majority"
        else:
            # Construir URI convencional
            port = connection.port or 27017
            uri = f"mongodb://{user}:{password}@{host}:{port}/{schema}"

        self.log.info(f"Connecting to MongoDB with URI: {uri}")
        
        # Crear el cliente de MongoDB
        client = MongoClient(uri)
        db = client[schema]

        if self.operation == 'create_collection':
            if self.collection not in db.list_collection_names():
                db.create_collection(self.collection)
                self.log.info(f"Created collection: {self.collection}")
            else:
                self.log.info(f"Collection {self.collection} already exists")
            return  # Salir después de la creación

        # Obtener la colección
        collection = db[self.collection]

        # Ejecutar la operación especificada
        if self.operation == 'insert':
            if self.json_file_path:
                try:
                    with open(self.json_file_path, 'r') as file:
                        self.data = json.load(file)
                except FileNotFoundError:
                    self.log.error(f"JSON file not found: {self.json_file_path}")
                    raise

            if isinstance(self.data, list):
                doc = self.data[-1]  # Solo inserta el último documento de la lista
                if isinstance(doc, dict):
                    result = collection.insert_one(doc)
                    self.log.info(f"Inserted document ID: {result.inserted_id}")
                else:
                    self.log.warning(f"Skipped non-dictionary item: {doc}")
            elif isinstance(self.data, dict):
                result = collection.insert_one(self.data)
                self.log.info(f"Inserted document ID: {result.inserted_id}")
            else:
                raise TypeError("Data must be a dictionary or a list of dictionaries.")

        elif self.operation == 'find':
            result = list(collection.find(self.query))
            self.log.info(f"Found documents: {result}")
            return result

        elif self.operation == 'update':
            result = collection.update_many(self.query, {"$set": self.data})
            self.log.info(f"Updated {result.modified_count} documents")

        elif self.operation == 'delete':
            result = collection.delete_many(self.query)
            self.log.info(f"Deleted {result.deleted_count} documents")
        else:
            raise ValueError(f"Unsupported operation: {self.operation}")

        client.close()