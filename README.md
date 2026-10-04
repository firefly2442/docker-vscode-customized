# docker-vscode-customized

A slightly customized version of VSCode with additional packages for deployment to Kubernetes.

## Building

```shell
docker compose build --pull
```

## Deployment

```shell
docker compose up -d
```

Open [http://localhost:8443](http://localhost:8443)

## Teardown

```shell
docker compose down
```

## Development

Linting

```shell
helm lint ./chart
```

Check output

```shell
helm template vscode ./chart
```

## References

* [VSCode from LinuxServer](https://hub.docker.com/r/linuxserver/code-server)
