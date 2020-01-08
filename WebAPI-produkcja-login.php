#!/usr/bin/php
<?php

/*
#######################################
autor:         rdbeni0  
strona domowa: http://rdbeni0.github.io/  
#######################################
Skrypt PHP do logowania na Allegro (tylko produkcja) przez WebAPI.
Przed wywołaniem, należy uzupełnić dane do logowania pomiędzy ''
Aktualnie działa tylko na produkcji, a na sandbox nie.
*/

define('ALLEGRO_LOGIN', 'allegro login');
define('ALLEGRO_PASSWORD', 'haslo do loginu allegro, zgodne z tym co na stronie');
define('ALLEGRO_KEY', 'zgodne z kolumna "Client ID / klucz WebAPI"');

//KONIEC WYMAGANEGO UZUPEŁNIANIA.
//WŁAŚCIWY SKRYPT:

class AllegroWebAPISoapClient extends SoapClient
{
    // jedynka to kod kraju dla Polski
    const COUNTRY_PL = 1;
    const QUERY_ALLEGROWEBAPI = 1;

    public function __construct()
    {
        parent::__construct('https://webapi.allegro.pl/uploader.php?wsdl');
    }
}

define('ALLEGRO_COUNTRY', AllegroWebAPISoapClient::COUNTRY_PL);

// klucz wersji, zapisany w pliku
$allegroVerKey = file_get_contents('./cache/.verkey');

// łączymy się z Allegro WebAPI
$client = new AllegroWebAPISoapClient();

// w ten sposób zadbamy, aby ewentualny błąd nie narobił szkód
try
{
    try
    {
        // próba logowania
        $session = $client->doLoginEnc(ALLEGRO_LOGIN, base64_encode( hash('sha256', ALLEGRO_PASSWORD, true) ), ALLEGRO_COUNTRY, ALLEGRO_KEY, $allegroVerKey);
    }
    catch(SoapFault $error)
    {
        // błąd niepoprawnego klucza wersji pozwala nam zauważyć fakt iż coś w serwisie się zmieniło
        if($error->faultcode == 'ERR_INVALID_VERSION_CAT_SELL_FIELDS')
        {
            // pobieramy aktualny klucz wersji
            $version = $client->doQuerySysStatus(AllegroWebAPISoapClient::QUERY_ALLEGROWEBAPI, ALLEGRO_COUNTRY, ALLEGRO_KEY);
            $allegroVerKey = $version['ver-key'];

            /* tutaj wykonujemy swoje operacje uaktualniające */
            /*                                                */

            // zapisujemy klucz wersji do pliku
            file_put_contents('./cache/.verkey', $allegroVerKey);
            // ponowna próba logowania, już z nowym kluczem
            $session = $client->doLoginEnc(ALLEGRO_LOGIN, base64_encode( hash('sha256', ALLEGRO_PASSWORD, true) ), ALLEGRO_COUNTRY, ALLEGRO_KEY, $allegroVerKey);
        }
        // każdy inny błąd to już poważny problem
        else
        {
            throw $error;
        }
    }

    // udało nam się zalogować - wyswietle informacji o kluczu wersji
    echo 'Logowanie poprawne. Uzyskany klucz sesji to: ', $session['session-handle-part'] , "\n";
    $identyfikator_sesji = $session['session-handle-part'];
    file_put_contents('./cache/identyfikator_sesji', $identyfikator_sesji);

}
catch(SoapFault $error)
{
    echo 'Błąd ', $error->faultcode, ': ', $error->faultstring, "\n"; 
}

?>
