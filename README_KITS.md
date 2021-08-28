# kits version of mindwendel

This project includes a few CI changes to the mindwendel software.

## Installation

Use docker-compose

```sh
docker-compose -f docker-compose-kits.yml up
```

or to make sure updates will be included:

```sh
docker-compose -f docker-compose-kits.yml --force-recreate up
```

Notes:

- Important: Make sure to exchange passwords with proper ones!
- Check all env variables defined in `docker-compose-kits.yml` and adjust them accordingly, e.g. all `DATABASE_*` vars
- Important: Generate a unique key for the `SECRET_KEY_BASE`
- Download the `.gcp-config.json` from google cloud platform, see instructions in docker-compose-kits.yml

See main README for project specifics.
