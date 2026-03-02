# BE's devcontainer helper features

## Features

### `common-utils`

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/BurningEnlightenment/devcontainer-features/common-utils:1": {}
    }
}
```

see [src/common-utils/README.md](src/common-utils/README.md) for more details.

## Development

### Executing Tests

Use the devcontainer CLI from within the devcontainer, e.g.

```bash
devcontainer features test \
    --features common-utils \
    --skip-scenarios \
    --base-image mcr.microsoft.com/devcontainers/base:ubuntu
```
