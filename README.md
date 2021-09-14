# Qrstorage

Qr Codes that link to your server with sound and text information.

### Development

The current [entrypoint](./.docker/entrypoint.sh) will not start the phoenix server. Instead, it will just idle to keep the container running. This is approach helps you to have full control of your dev environment and allows you to start up the container whenever you want.

**Important**: Before you start setting up the container, register a Google Cloud Platform account and download the json configuration file from Google Cloud Platform. Name it '.gcp-config.json' and put it in the root folder.

To start the container:
- Start the development environment with `docker-compose up -d`
- Check the all services are up an runnung `docker-compose ps`
- Open a new terminal window
- Enter the running container: `docker-compose exec app sh`
- Get the latest elixir dependencies: `mix do deps.get`
- Get the latest node packages: `npm install --prefix assets`
- Setup the database: `mix ecto.setup`
- Start the phoenix server: `mix phx.server`
- Go to http://localhost:4000/qrcodes
- Start developing

### Additonal licence

The qrstorage [logo](https://thenounproject.com/icon/860830/) in this repo – created by [Hopkins](https://thenounproject.com/hopkins81) – is licenced under [CC BY 3.0 Unported](https://creativecommons.org/licenses/by/3.0/).
