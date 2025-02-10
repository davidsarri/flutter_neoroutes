# Configuració de Firebase en un projecte Flutter

Aquest projecte utilitza Firebase per gestionar la backend, incloent serveis com l'autenticació, la base de dades en temps real, i altres serveis de Firebase. Segueix els següents passos per configurar Firebase correctament per a aquest projecte.

## Prerequisits

Abans de començar, assegura't de tenir:

- Un compte de Google.
- Accés a [Firebase Console](https://console.firebase.google.com/).
- Flutter instal·lat i configurat a la teva màquina. Si no ho tens, pots seguir la [guia oficial de Flutter](https://flutter.dev/docs/get-started/install).

## Pas 1: Crear un projecte a Firebase

1. Aneu a [Firebase Console](https://console.firebase.google.com/).
2. Feu clic a **"Afegeix projecte"**.
3. Seguiu les instruccions per crear un nou projecte a Firebase.
4. Un cop creat el projecte, es generaran els fitxers de configuració de Firebase per a cada plataforma (iOS i Android).

## Pas 2: Configurar Firebase per a iOS

1. A Firebase Console, seleccioneu el projecte creat i aneu a la secció **"iOS"**.
2. Descarregueu el fitxer de configuració `GoogleService-Info.plist` per a iOS.
3. Col·loqueu el fitxer `GoogleService-Info.plist` dins del directori:

# ios/Runner/GoogleService-Info.plist

4. **Important**: No pugeu aquest fitxer al repositori Git. Assegura't d'afegir-lo al fitxer `.gitignore` per evitar que s'enviï per error al repositori.

## Pas 3: Configurar Firebase per a Android

1. A Firebase Console, seleccioneu el projecte creat i aneu a la secció **"Android"**.
2. Descarregueu el fitxer de configuració `google-services.json` per a Android.
3. Col·loqueu el fitxer `google-services.json` dins del directori:

# android/app/google-services.json

4. **Important**: No pugeu aquest fitxer al repositori Git. Assegura't d'afegir-lo al fitxer `.gitignore` per evitar que s'enviï per error al repositori.

## Pas 4: Afegir Firebase SDK al projecte Flutter

1. Obre el fitxer `pubspec.yaml` al directori arrel del projecte.
2. Afegeix les dependències de Firebase que necessites. Un exemple bàsic seria afegir:

```yaml
dependencies:
  firebase_core: ^1.10.0
  firebase_auth: ^3.3.4
  cloud_firestore: ^3.1.5
```
