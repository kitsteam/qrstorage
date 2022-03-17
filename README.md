# Qrstorage

Qr Codes that link to your server with sound and text information.

### Development

The current [entrypoint](./.docker/entrypoint.sh) will not start the phoenix server. Instead, it will just idle to keep the container running. This is approach helps you to have full control of your dev environment and allows you to start up the container whenever you want.

**Important**: Before you start setting up the container, register a Google Cloud Platform account and download the json configuration file from Google Cloud Platform. Reference the file by setting the GCP_CONFIG_PATH environment variable in your docker-compose file. You must not commit this file to a repository!

To start the container:
- Create a file called docker-compose.override.yml and fill in at least the `GCP_CONFIG_PATH` and a `SECRET_KEY_BASE` for app. E.g.:

```
version: "3.8"

services:
  app:
    environment:
      SECRET_KEY_BASE: "generate me with mix phx.gen.secret"
      GCP_CONFIG_PATH: "/somewhere/.gcp-config.json"
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
add_header Content-Security-Policy "default-src 'self' img-src 'self' data:; style-src 'self' 'unsafe-inline'" always;
```

There are couple of inline styles that will be removed in the future, so that ```unsafe-inline``` can be removed as well.


### Additonal licence

The qrstorage [logo](https://thenounproject.com/icon/860830/) in this repo – created by [Hopkins](https://thenounproject.com/hopkins81) – is licenced under [CC BY 3.0 Unported](https://creativecommons.org/licenses/by/3.0/).

<img src="https://www.nibis.de/img/nlq-medienbildung.png" align="left" style="margin-right:20px">
<img src="https://kits.blog/wp-content/uploads/2021/03/kits_logo.svg" width=100px align="left" style="margin-right:20px">

[kits](https://kits.blog/) is a project platform hosted by a public institution for quality development in schools (Lower Saxony, Germany) and focusses on digital tools and media in language teaching.