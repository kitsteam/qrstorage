# kits version of QRStorage

This project includes a few CI changes to the QRStorage software.

## Installation

Use docker-compose

```sh
docker-compose -f docker-compose-kits.yml up
```

or if you want, you can also use an override file. Create a new file called docker-compose-kits.override.yml and override the parameters you'd like to override:

```
cp docker-compose-kits.yml docker-compose-kits.override.yml
docker-compose -f docker-compose-kits.yml -f docker-compose-kits.override.yml up
```

or to make sure updates will be included:

```sh
docker-compose -f docker-compose-kits.yml -f docker-compose-kits.override.yml up --build --force-recreate
```

Notes:
- Important: Make sure to exchange passwords with proper ones!
- Check all env variables defined in `docker-compose-kits.yml` and adjust them accordingly, e.g. all `DATABASE_*` vars
- Important: Generate a unique key for the `SECRET_KEY_BASE`
- Download the `.gcp-config.json` from google cloud platform, see instructions in docker-compose-kits.yml

See main README for project specifics.
