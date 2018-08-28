#!/usr/bin/python3
import requests
from http.server import BaseHTTPRequestHandler, HTTPServer
import webbrowser
from sys import argv

# argumenty związane z loginem będziemy dodawać przez wiersz poleceń (trzy parametry)
CLIENT_ID = argv[1]
OAUTH_URL = argv[2]
REDIRECT_URI = argv[3]

# funkcja z trzema parametrami: client_id, oauth_url, redirect_uri
# w razie potrzeby i przypadku zmian; można tutaj dopisać dodatkowe dane do logowania
def get_access_code(client_id=CLIENT_ID, redirect_uri=REDIRECT_URI, oauth_url=OAUTH_URL):
    # zmienna auth_url zawierać będzie zbudowany na podstawie podanych parametrów URL do zdobycia kodu
    auth_url = '{}/authorize' \
               '?response_type=code' \
               '&client_id={}' \
               '&redirect_uri={}'.format(oauth_url, client_id, redirect_uri)
 
    # uzywamy narzędzia z modułu requests - urlparse - służy do sparsowania podanego url 
    # (oddzieli hostname od portu)
    parsed_redirect_uri = requests.utils.urlparse(redirect_uri)

    # definiujemy nasz serwer - który obsłuży odpowiedź allegro (redirect_uri)
    server_address = parsed_redirect_uri.hostname, parsed_redirect_uri.port

    # Ta klasa pomoże obsłużyć zdarzenie GET na naszym lokalnym serwerze
    # - odbierze żądanie (odpowiedź) z serwisu allegro
    class AllegroAuthHandler(BaseHTTPRequestHandler):
        def __init__(self, request, address, server):
            super().__init__(request, address, server)

        def do_GET(self):
            self.send_response(200, 'OK')
            self.send_header('Content-Type', 'text/html')
            self.end_headers()

            self.server.path = self.path
            self.server.access_code = self.path.rsplit('?code=', 1)[-1]

    # Wyświetli nam adres uruchomionego lokalnego serwera
    print('server_address:', server_address)

    # Uruchamiamy przeglądarkę, przechodząc na adres zdefiniowany do uzyskania kodu dostępu
    # wyświetlić się powinien formularz logowania do serwisu Allegro.pl
    webbrowser.open(auth_url)

    # Uruchamiamy nasz lokalny web server na maszynie na której uruchomiony zostanie skrypt
    # taki serwer dostępny będzie pod adresem http://localhost:8000 (server_address)
    httpd = HTTPServer(server_address, AllegroAuthHandler)
    print('Waiting for response with access_code from Allegro.pl (user authorization in progress)...')

    # Oczekujemy tylko jednego żądania
    httpd.handle_request()

    # Po jego otrzymaniu zamykamy nasz serwer (nie obsługujemy już żadnych żądań)
    httpd.server_close()

    # Klasa HTTPServer przechowuje teraz nasz access_code - wyciągamy go
    _access_code = httpd.access_code

    # Dla jasności co się dzieje - można wyświetlić access_code w konsoli
    # print('Got an authorize code: ', _access_code)
    #
    # no i zapisujemy do pliku...
    kod10sek = open("./cache/allsi_kod-autoryzujacy-10sekund","w")
    kod10sek.write(_access_code)
    kod10sek.close()
    # rezultat działania funkcji
    return _access_code
    webbrowser.close(auth_url)
    
get_access_code()
