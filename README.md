# Qrstorage

Qr Codes that link to your server with sound and text information.

### Development

The current [entrypoint](./.docker/entrypoint.sh) will not start the phoenix server. Instead, it will just idle to keep the container running. This is approach helps you to have full control of your dev environment and allows you to start up the container whenever you want.

**Important**: Before you start setting up the container, register a Google Cloud Platform account and download the json configuration file from Google Cloud Platform. Reference the file by setting the GCP_CONFIG_PATH environment variable in your docker-compose file. You must not commit this file to a repository! You should use volumes to make the file accessible to the container.

To start the container:
- Create a file called docker-compose.override.yml and fill in at least the `GCP_CONFIG_PATH`, `SECRET_KEY_BASE` and a correct path to a volume for the GCP credentials file. E.g.:

```
version: "3.8"

services:
  app:
    environment:
      SECRET_KEY_BASE: "generate me with mix phx.gen.secret"
      GCP_CONFIG_PATH: "/app/.gcp-config.json"
      ...
    volumes:
      - /path-to-your-credentials/gcp/.gcp-config.json:/app/.gcp-config.json
```

- Start the development environment with `docker compose up -d app`
- Check the all services are up an runnung `docker compose ps`
- Open a new terminal window
- Enter the running container: `docker compose exec app sh`
- Get the latest elixir dependencies: `mix do deps.get`
- Get the latest node packages: `cd assets && npm install`
- Setup the database: `mix ecto.setup`
- Start the phoenix server: `mix phx.server`
- Go to http://localhost:4000/qrcodes
- Start developing

### Localisation

Currently, there are two language files available, german ("de") and english ("en"). To set the default_locale, you can set QR_DEFAULT_LOCALE. The default is german.

You can extract new strings to translate by running:

 mix gettext.extract --merge

### Content Security Policy

You can use a content security policy to restrict which resources are being loaded. The app is completely self contained, so you can use quite strict policies. For nginx, this would look like this:

```
 add_header Content-Security-Policy "default-src 'self'; script-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline';" always;
```

`unsafe-inline` is required for quilljs to work properly.

Watch out that this content security policy will block live reload in development mode!

### Image upload

It is possible to store images base 64 encoded in the database. Since this is not very efficient, this should not be used for large imsage sizes or for qr codes with a lot of traffic. The default limit for a text qr code is 2MB. To change this, change ```QR_CODE_MAX_UPLOAD_LENGTH```. We automatically add a buffer to account for deltas as well as overhead.

### Additonal licence

The qrstorage [logo](https://thenounproject.com/icon/860830/) in this repo – created by [Hopkins](https://thenounproject.com/hopkins81) – is licenced under [CC BY 3.0 Unported](https://creativecommons.org/licenses/by/3.0/).

<img src="https://www.nibis.de/img/nlq-medienbildung.png" align="left" style="margin-right:20px">
<img src="https://kits.blog/wp-content/uploads/2021/03/kits_logo.svg" width=100px align="left" style="margin-right:20px">

[kits](https://kits.blog/) is a project platform hosted by a public institution for quality development in schools (Lower Saxony, Germany) and focusses on digital tools and media in language teaching.