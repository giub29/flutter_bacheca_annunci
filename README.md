\# Bacheca lavoro



App sviluppata per il compito di Enterprise Mobile Application Development. Permette alle aziende di pubblicare offerte di lavoro e ai candidati di rispondere allegando il proprio curriculum.



Questa repository contiene il front-end Flutter. Il server si trova nella repository \[dart\_bacheca\_annunci\_server](https://github.com/giub29/dart\_bacheca\_annunci\_server).



\## Funzionalità



L’app può essere utilizzata da due tipi di utenti:



\- Le aziende si registrano, effettuano il login, pubblicano annunci e consultano le candidature ricevute per le proprie offerte. Possono visualizzare i dati del candidato e aprire il curriculum.

\- I candidati consultano la bacheca senza registrarsi. Per candidarsi inseriscono nome, cognome ed email e selezionano un curriculum in formato PDF, fino a 5 MiB.



Dopo il logout, l’azienda torna alla bacheca pubblica.



\## Come funziona



L’app comunica tramite richieste HTTP con un server Dart eseguito sul computer. Account, annunci, candidature e curriculum vengono conservati dal server e restano disponibili dopo la chiusura dell’app.



Il client gestisce le schermate, i form e lo stato dell’autenticazione. Il server controlla le credenziali e verifica che ogni azienda possa consultare soltanto le candidature dei propri annunci.



Il curriculum viene selezionato dal dispositivo e inviato al server. Per aprirlo, l’app lo scarica con una richiesta autenticata, ne salva una copia temporanea e richiama un lettore PDF presente sul telefono.



\## Avvio



Servono Flutter, gli strumenti Android e un emulatore o un telefono Android con debug USB attivo. Il back-end deve essere avviato prima di utilizzare l’app.



Dalla cartella del progetto:



```sh

flutter pub get

flutter devices

```



\### Emulatore Android



L’indirizzo predefinito del server è `http://10.0.2.2:8080`, che permette all’emulatore Android di raggiungere il computer.



```sh

flutter run -d ID\_EMULATORE

```



Sostituire `ID\_EMULATORE` con l’identificatore mostrato da `flutter devices`.



\### Telefono Android collegato tramite USB



Autorizzare il debug USB sul telefono e inoltrare la porta del server:



```sh

adb -s ID\_TELEFONO reverse tcp:8080 tcp:8080

flutter run -d ID\_TELEFONO --dart-define=API\_BASE\_URL=http://127.0.0.1:8080

```



Sostituire `ID\_TELEFONO` con l’identificatore del proprio dispositivo. `adb` si trova nella cartella `platform-tools` dell’Android SDK; se non è nel PATH, occorre richiamarlo tramite il percorso completo.



Durante l’utilizzo mantenere il server acceso e il cavo collegato. Dopo una disconnessione o un riavvio può essere necessario ripetere `adb reverse`.



L’indirizzo del server è configurabile tramite `API\_BASE\_URL`, senza modificare il codice.



\## Organizzazione del progetto



Dentro `lib`:



\- `config`: indirizzo del server e timeout;

\- `models`: modelli di azienda, annuncio e candidatura;

\- `providers`: stato dell’autenticazione;

\- `screens`: schermate dell’app;

\- `services`: richieste HTTP, selezione e apertura dei PDF;

\- `main.dart`: avvio dell’app e bacheca pubblica.



I pacchetti principali sono `http`, `provider`, `file\_picker`, `path\_provider` e `open\_filex`.



\## Scenari dimostrati



\- \*\*S1:\*\* registrazione aziendale, login e pubblicazione di un annuncio.

\- \*\*S2:\*\* consultazione della bacheca e invio di una candidatura senza autenticazione.

\- \*\*S3:\*\* consultazione delle candidature, apertura del curriculum e logout.



L’app è stata provata su emulatore Android e su un Samsung SM-A715F con Android 13.



Per controllare il codice:



```sh

flutter analyze

```

