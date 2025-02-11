import requests
import os
import json
from dotenv import load_dotenv
from pymongo import MongoClient


load_dotenv()

def send_text(bot_message):                                        #funcion que envia mensajes al chatbot de telegram
    bot_token = os.getenv('API_TELEGRAM')
    chat_ID = os.getenv('CHAT_ID')
    send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + chat_ID + '&parse_mode=Markdown&text=' + bot_message

    res = requests.post(send_text)
    return res

def send_image(image):                                            #funcion que envia imagenes al chatbot de telegram
    bot_token = os.getenv('API_TELEGRAM')
    chat_ID = os.getenv('CHAT_ID')
    send_image='https://api.telegram.org/bot' + bot_token + '/sendPhoto'
    data={'chat_id':chat_ID}
    files={'photo':(image,open(image,'rb'))}
    response=requests.post(send_image, files=files, data=data, verify=False)
    return response

# lat=6.25184
# lon=-75.56359
API_key = os.getenv('NASA_API_KEY')
# url=f'https://api.nasa.gov/planetary/earth/assets?lon={lon}&lat={lat}&date=2024-01-25&dim=0.25&api_key={API_key}' #url para descargar fotos de la tierra
url2=f'https://api.nasa.gov/planetary/apod?api_key={API_key}' #url para obtener imagen del dia de la nasa

response= requests.get(url2)
    # Verificar si la solicitud fue exitosa
if response.status_code == 200:
    # Convertir la respuesta en formato JSON
    response=response.text
    response=json.loads(response)
    print(response)
    img = requests.get(response['url'])
    filename = '/opt/airflow/img/imagen.jpg'
    archivo_json = '/opt/airflow/tmp/data.json'
    
    metadata=f'*Date* :{response["date"]}\n\n*Explanation* :{response["explanation"]}\n\n*Title* :{response["title"]}\n\n*URL* :{response["url"]}'
    
    with open(filename, "wb") as file:
        file.write(img.content)
    if not os.path.exists(archivo_json):
        with open(archivo_json, "w", encoding="utf-8") as archivo:
            json.dump({"items": []}, archivo, indent=4, ensure_ascii=False)

# Leer el archivo JSON existente
    with open(archivo_json, "r", encoding="utf-8") as archivo:
        datos = json.load(archivo)

# Agregar el nuevo objeto a la lista "items"
    datos["items"].append(response)

# Escribir los datos actualizados en el archivo JSON
    with open(archivo_json, "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, indent=4, ensure_ascii=False)

    print(f"Nuevo objeto agregado al archivo {archivo_json}")
    
    send_text(f'{metadata}')
    send_image(filename)
    
else:
        print(f"Error: {response.status_code}")