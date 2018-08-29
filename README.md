# allsi-login

* dokumentacja: <http://collector1871.github.io/other/allsi-login/>   
* autor: collector1871  

allego simple login (PL)

**Dokumentacja** oraz **zbiór skryptów** perl5/python3/PHP, które mają w założeniu pomagać w zalogowaniu się do allegro. Aktualnie skupiam się na RESP API, które lada moment ma zastąpić całkowicie WEBApi. Skrypty są przeważnie polskojęzyczne, chociaż w ramach wolnego czasu możliwe jest przetłumaczenie.  

Repozytorium może być przydatne, ponieważ Allegro lubi się zmieniać. Coś co działało kiedyś, to dzisiaj już nie działa. Zmiany na Allegro pojawiają się często.  
   
Jeżeli więc pojawi się jakaś zmiana dotycząca procesu logowania, to w tym repozytorium powinna zostać szybko zaimplementowana. Całe logowanie możliwe jest do przeprowadzenia "po stronie" desktopu (aplikacja biurkowa), ale również po stronie serwera (back end). Skrypty piszę z perspektywy desktopa na Linuxie (laptopa).  

W skrócie: proste i działające logowanie przy użyciu perl5/python3  

## ZALEŻNOŚCI, WYMAGANIA

* podstawowe narzędzia unixowe (grep, curl, tzw. coreutils; cat, awk, mkdir)
* python3: requests, json, sys i argv, http.server, webbrowser
* PERL5: póki co to tylko **Perl Core**
* moduł pythona3 _webbrowser_ wymaga działającej przeglądarki internetowej, np. Google Chrome (aby przejść przez cały proces autoryzacji)
* (opcjonalnie) dla skryptu do WebAPI : PHP z obsługą SOAP

Jeżeli repo będzie się rozrastać, a proces komplikować, to zależności również.

## OFICJALNA DOKUMENTACJA, KLUCZE I KODY

Całość jest ściśle zgodna z oficjalną dokumentacją:  

* <https://developer.allegro.pl/auth/>  

Kody dla aplikacji wygenerujemy i sprawdzimy tutaj:   

* SANDBOX (testy): <https://apps.developer.allegro.pl.allegrosandbox.pl/>   
* PRODUKCJA: <https://apps.developer.allegro.pl/>   

![Rejestrowanie aplikacji](https://raw.githubusercontent.com/collector1871/allsi-login/master/dokumentacja_screeny/screen001.jpg)

## PLIK KONFIGURACYJNY I CACHE

Plik ten znajduje się domyślnie w folderze z aplikacją jako: `./.alsi_conf_file` . Zawiera dwa podstawowe prefixy: `sandbox_` oraz `produkcja_` . Kody, które trzeba wpisać do pliku to:

* **client_id**  jest zgodny z kolumną ze strony z rejestracją aplikacji: _Client ID / klucz WebAPI_
* **client_secret** to _Client Secret_
* **redirect_uri** to _Adresy Przekierowań_   
Tutaj należy wpisać `http://localhost:8000` (zarówno w pliku konfiguracyjnym jak i na stronie)

W trakcie pierwszego uruchomienia `allsi-login.pl` pojawi się folder **`cache`** w którym będą znajdowały się pobrane dane dotyczące logowania.

## allsi-login.pl

Główny skrypt perlowy do zarządzania loginem na allegro.  
  
Dwa wymagane parametry:  
   
**PARAMETR 1** : położenie pliku konfiguracynnego:   
- dir : wtedy plik konfiguracyjny będzie odczytywany z folderu lokalnego, jako `./.allsi_conf_file`  
- pełna ścieżka unixowa, np. `/var/tmp/moj_plik_konfiguracyjny.txt`  
    
**PARAMETR 2** : określenie środowiska:   
- sandbox : środowisko testowe, pobranie danych do środowiska testowa z pliku konfiguracyjnego  
- produkcja : zalogowanie się na główne allegro...  

## WYNIK PROGRAMU

Główny output programu to **`./cache/allsi_access-token-12godz.json`** : jest to plik ze zdalnie uzyskanym kodem dostępu, który jest ważny przez 12 godzin i może zostać użyty do dalszych requestów. Drugim  plikiem jest **`./cache/allsi_access-token-12godz.txt`** - jest to czysty plik tekstowy z samym access tokenem (może wiec łatwo zostać wczytany w innym skrypcie).

## PRZYKŁADY DZIAŁANIA

Przed jakimkolwiek działaniem, należy uzupełnić plik konfiguracyjny. Będzie on podawany w pierwszym parametrze. Wywołanie jest zawsze z dwoma parametrami (oddzielone 1 spacją):

```text
    ./allsi-login.pl dir sandbox
    
    ./allsi-login.pl /home/lucyna/allsi-plik.konfiguracyjny.txt produkcja

    ./allsi-login.pl $HOME/Documents/.allsi-plik-konf.txt sandbox
```

##  WebAPI (opcjonalnie)

W repozytorium znajduje się również dodatkowy skrypt PHP : `WebAPI-produkcja-login.php`   
Aby skrypt zadziałał, musi być włączona obsługa SOAP w PHP. Można to sprawdzić np. przez:

```text
    php -i | grep -i soap
```

Przed wywołaniem, w liniach 13-15 należy uzupełnić dane do logowania. Np.:

```text
    define('ALLEGRO_LOGIN', '1970janusz987');
    define('ALLEGRO_PASSWORD', 'supertajne123');
    define('ALLEGRO_KEY', '43IKLUGHE3RKLJTSBADT89032453');
```

Wywołanie odbybywa się bez parametrów, czyli `./WebAPI-produkcja-login.php`

Wynik to **`./cache/identyfikator_sesji`** : może on zostać użyty do dalszych requestów. WebAPI jednak będzie wygaszane, a więc repozytorium w tym zakresie nie będzie rozwijane.

## WSPÓŁPRACA

Zachęcam wszystkich do współpracy:   
* proszę zrobić to przez pull requesta: clonujemy repo, robimy nowy branch, a później PR   
* jakiekolwiek usprawnienia, lepsza dokumentacja, nowe języki, czy też pomysły -> wszystko się przyda  

**UWAGA!**  
Przed jakimkolwiek publicznym pull requestem, proszę sprawdzić `.gitignore` - aby znajdował się w nim folder `cache`. Proszę również pilnować, aby nie upubliczniać swojego pliku konfiguracyjnego!
Można więc dodać do `.gitignore` :  

    .allsi_conf_file
    
