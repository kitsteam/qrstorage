# Qrstorage

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

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

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
