# Qrstorage

Qr Codes that link to your server with sound and text information.

### Development

- **Important**: Before you start setting up the container, register an account with `Deepl` and `Readspeaker` to get the proper API keys for text to speech and translation features. Create a file called `docker-compose.override.yml`and create an override that mount these credentials into the container. Example:

```
services:
 app:
  environment:
   SECRET_KEY_BASE: "your secret key base"
```

Use this only for development and make sure not to commit the file to the repository or build a container with the file.

- Start the development environment with `docker compose up -d app`

- Enter the running container: `docker compose exec app bash`

- Get the latest elixir dependencies: `mix do deps.get, deps.compile`

- Get the latest node packages: `npm --prefix assets install`

- Setup the database: `mix ecto.setup`

- Start the phoenix server: `mix phx.server`

- Go to http://localhost:4000

- Start developing

### Localization

Currently, there are two language files available, german ("de") and english ("en"). To set the default_locale, you can set QR_DEFAULT_LOCALE. The default is german.

You can extract new strings to translate by running:

mix gettext.extract --merge

### Content Security Policy

You can use a content security policy to restrict which resources are being loaded. The app is completely self contained, so you can use quite strict policies. For nginx, this would look like this:

```
 add_header Content-Security-Policy "default-src 'self'; script-src 'self' blob:; img-src 'self' data:; style-src 'self' 'unsafe-inline'; media-src 'self' blob:; connect-src blob:" always;
```

`unsafe-inline` is required for quilljs to work properly.

Watch out that this content security policy will block live reload in development mode!

### Image upload

It is possible to store images base 64 encoded in the database. Since this is not very efficient, this should not be used for large image sizes or for qr codes with a lot of traffic. The default limit for a text qr code is 2MB. To change this, change `QR_CODE_MAX_UPLOAD_LENGTH`. We automatically add a buffer to account for deltas as well as overhead.

### Additonal licence

The qrstorage [logo](https://thenounproject.com/icon/860830/) in this repo – created by [Hopkins](https://thenounproject.com/hopkins81) – is licenced under [CC BY 3.0 Unported](https://creativecommons.org/licenses/by/3.0/).

<img src="https://www.nibis.de/img/nlq-medienbildung.png" align="left" style="margin-right:20px">
<img src="https://kits.blog/wp-content/uploads/2021/03/kits_logo.svg" width=100px align="left" style="margin-right:20px">

[kits](https://kits.blog/) is a project platform hosted by a public institution for quality development in schools (Lower Saxony, Germany) and focusses on digital tools and media in language teaching.

This project uses [LAME](https://lame.sourceforge.net) and [lamejs](https://github.com/zhuker/lamejs/) to convert audio recordings in the browser to mp3.
