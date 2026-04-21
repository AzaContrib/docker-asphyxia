## Usage

```sh
docker compose up -d
```

## Arguments
You can pass arguments directly to Asphyxia by appending them to the `command` in your `compose.yml`:

```yaml
command: /app/bootstrap.sh --dev --ping-addr 127.0.0.1
```

## Environment Variables

- **ASPHYXIA_PLUGIN_REPLACE** - Setting this will cause it to ONLY use the custom plugins provided from the mounted plugins directory.

## Mount Point

The local mount point for overrides within the container is /app/custom. If you wish to store additional plugins, config and savedata outside the container you should specify a volume such as:

```yaml
volumes:
  - "./data/custom:/app/custom"
```

You can replace "./data/custom" with any directory on your machine that contains your config.ini/plugins/savedata directories.

## Config Override ##
Place an Asphyxia config.ini file in the directory you have mounted to /app/custom

## Plugin Override ##
Place a plugins directory in the directory you have mounted to /app/custom. By default, the image contains the 0.5 release version of the [official plugins](https://github.com/asphyxia-core/plugins). Any plugins that get mounted into /app/custom will be copied (and override) the community plugins within the image. If ASPHYXIA_PLUGIN_REPLACE is defined, then the community plugins will not be included, and it will rely on the plugins provided in custom.

## Savedata ##
By default, game data is stored in `./data` on your host.

## Notes ##
Always ensure you map both the listening port (8083) and the matching port (5700) in your compose file.
Example:
```
ports:
  - "8083:8083"
  - "5700:5700"
```

The container is configured to automatically bind to "**0.0.0.0**" to ensure it's accessible from the host.
