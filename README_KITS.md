# kits version of QRStorage

This project includes a few CI changes to the QRStorage software.

## Installation

In this example, we will use an override file. Create a new file called docker compose-kits.override.yml and override the parameters you'd like to override:

```
cp docker compose-kits.yml docker compose-kits.override.yml
docker compose -f docker-compose-kits.yml -f docker-compose-kits.override.yml up
```

To make sure updates to your file are included, force a recreation:

```sh
docker compose -f docker-compose-kits.yml -f docker-compose-kits.override.yml up --build --force-recreate
```

Notes:
- Important: Make sure to exchange passwords with proper ones!
- Check all env variables defined in `docker compose-kits.yml` and adjust them accordingly, e.g. all `DATABASE_*` vars
- Important: Generate a unique key for the `SECRET_KEY_BASE` with `mix phx.gen.secret`
- Download the file `.gcp-config.json` from Google Cloud Platform, see instructions in docker compose-kits.yml

See main README for project specifics.