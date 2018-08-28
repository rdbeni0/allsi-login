#!/usr/bin/python3
import requests
import json
from sys import argv

# argumenty związane z loginem będziemy dodawać przez wiersz poleceń (pięć parametrów)
CLIENT_ID = argv[1]
OAUTH_URL = argv[2]
REDIRECT_URI = argv[3]
CLIENT_SECRET = argv[4]
ACCESS_CODE = argv[5]

# funkcja pobierajaca access_code do formatu json
def sign_in(client_id=CLIENT_ID, oauth_url=OAUTH_URL, redirect_uri=REDIRECT_URI, client_secret=CLIENT_SECRET, access_code=ACCESS_CODE):
    token_url = oauth_url + '/token'
    access_token_data = {'grant_type': 'authorization_code',
                         'code': access_code,
                         'redirect_uri': redirect_uri}
    response = requests.post(url=token_url,
                             auth=requests.auth.HTTPBasicAuth(client_id, client_secret),
                             data=access_token_data)
    return response.json()
    print(response.text)

# funkcja zapisujaca pobrany json do pliku, kod jest wazny przez kilkanascie godzin
def writeToJSONFile(fileName, data):
    filePathNameWExt = './' + fileName + '.json'
    with open(filePathNameWExt, 'w') as fp:
        json.dump(data, fp)

# wywołanie tych funkcji
write_access_token = sign_in()
writeToJSONFile("./cache/allsi_access-token-12godz", write_access_token)
