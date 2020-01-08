#!/usr/bin/perl -w

my $uzycie_skryptu = <<DOKUMENTACJA;
#######################################
autor:         rdbeni0  
strona domowa: http://rdbeni0.github.io/  
#######################################
Główny skrypt perlowy do zarządzania loginem na allegro.  
  
Wymagane są dwa parametry:  
   
**PARAMETR 1** : położenie pliku konfiguracynnego:   
- dir : wtedy plik konfiguracyjny będzie odczytywany z folderu lokalnego, jako `./.allsi_conf_file`
- pełna ścieżka unixowa, np. `/var/tmp/moj_plik_konfiguracyjny.txt`  
    
**PARAMETR 2** : określenie środowiska:   
- sandbox : środowisko testowe, pobranie danych do środowiska testowa z pliku konfiguracyjnego  
- produkcja : zalogowanie się na główne allegro... 
#######################################
DOKUMENTACJA

#######################################

use strict;
use warnings;
use JSON;

my $numer_parametrow = @ARGV;

sub usage
{
    print($uzycie_skryptu);
    exit();
}

#######################################
### stworz folder cache, jesli nie istnieje
#######################################

my $utworz_folder_cache = 'mkdir -p ./cache';
system($utworz_folder_cache);

#######################################
### plik konfiguracyjny, położenie na dysku (unix/linux):
#######################################

my $plik_konfiguracyjny;
if ( $numer_parametrow ne '2' )
{
    usage();
}
elsif ( $ARGV[0] eq 'dir' )
{
    $plik_konfiguracyjny = './.allsi_conf_file';
}
else
{
    $plik_konfiguracyjny = $ARGV[0];
}

#######################################
### funkcja do odczytywania parametrów z $plik_konfiguracyjny
### odczytanie niezbednych zmiennych
#######################################

my $client_id;
my $oauth_url;
my $redirect_uri;
my $client_secret;

sub czytaj_config_file
{
    my ($zmienna_config) = @_;
    if ( -e $plik_konfiguracyjny )
    {
        chomp( my $zmienna_output
                = `cat $plik_konfiguracyjny | grep "^$zmienna_config" | awk -F\'=\' \'\{print \$2\}\'`
        );
        if ($zmienna_output)
        {
            return ($zmienna_output);
        }
        else
        {
            print(    "Poszukiwana zmienna (parametr): \""
                    . $zmienna_config
                    . "\" jest pusta lub niepoprawna!\nPrzejrzyj plik konfiguracyjny: $plik_konfiguracyjny ! \n"
            );
            exit;
        }
    }
    else
    {
        print(    "UWAGA - plik konfiguracyjny \""
                . $plik_konfiguracyjny
                . "\" jest niepoprawny lub pusty! Przejrzyj komponenty tego pliku, plik sam w sobie!"
                . "\n" );
        print("Mozesz rowniez podac parametr: dir\n");
        exit();
    }
}

if ( $ARGV[1] eq 'sandbox' )
{
    $client_id     = ( czytaj_config_file("sandbox_client_id") );
    $oauth_url     = ( czytaj_config_file("sandbox_oauth_url") );
    $redirect_uri  = ( czytaj_config_file("sandbox_redirect_uri") );
    $client_secret = ( czytaj_config_file("sandbox_client_secret") );
}
elsif ( $ARGV[1] eq 'produkcja' )
{
    $client_id     = ( czytaj_config_file("produkcja_client_id") );
    $oauth_url     = ( czytaj_config_file("produkcja_oauth_url") );
    $redirect_uri  = ( czytaj_config_file("produkcja_redirect_uri") );
    $client_secret = ( czytaj_config_file("produkcja_client_secret") );
}
else
{
    usage();
}

#######################################
### wywołanie pythona logującego się do REST api i pobierajacego 10 sekundowy kod autoryzujacy
#######################################

my $pobierz_kod_autoryzujacy
    = "./kod-autoryzujacy-10sekund.py $client_id $oauth_url $redirect_uri $client_secret";
system($pobierz_kod_autoryzujacy);

#######################################
### zczytanie 10sekundowego kodu autoryzujacego z pliku
#######################################

my $pobrany_kod_autoryzujacy = './cache/allsi_kod-autoryzujacy-10sekund';
my $kod_autoryzujacy_10sekund;
open( my $fh, '<', $pobrany_kod_autoryzujacy )
    or die
    "Nie mozna otworzyc pliku z 10 sekundowym kodem autoryzujacym !! Sprawdz 1os kod i ten plik: $pobrany_kod_autoryzujacy!";
{
    local $/;
    $kod_autoryzujacy_10sekund = <$fh>;
}
close($fh);

#######################################
### pobranie access tokena, użycie 10 sekundowego kodu autoryzujacego,
### zapisanie nowego kodu do pliku json
#######################################

my $pobierz_access_token
    = "./access-token-12godz.py $client_id $oauth_url $redirect_uri $client_secret $kod_autoryzujacy_10sekund";
system($pobierz_access_token);

#######################################
### przetworzenie jsona, do pliku tekstowego
### zapisanie tego pliku w folderze cache
#######################################

my $allsi_access_token_12godz_txt = './cache/allsi_access-token-12godz.txt';
my $file_with_json                = './cache/allsi_access-token-12godz.json';

my $json_text_z_pliku = do
{
    open( my $json_fh, "<:encoding(UTF-8)", $file_with_json )
        or die("Can't open \$file_whith_json\": $!\n");
    local $/;
    <$json_fh>;
};

my $json_przetworz = JSON->new;
my %dane_json      = %{ $json_przetworz->decode($json_text_z_pliku) };

open my $txt, ">", $allsi_access_token_12godz_txt or die("Could not open file. $!");
print $txt $dane_json{"access_token"};
close $txt;
