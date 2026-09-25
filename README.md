# Mayari CLI

A CLI tool for managing and using the Mayari environment.

## Usage

```bash
mayari <command> [...args]
```

## Commands

| Command           | Description                   |
|-------------------|-------------------------------|
| `create`          | Scaffold a new Mayari project |
| `setup`           | Set up the Mayari packages    |
| `build`           | Build the Mayari project      |
| `help`            | Print available commands      |
| `--version`, `-v` | Print the current CLI version |

## Project Types

### Standard

A full-featured scaffold for a Mayari backend app. Includes everything needed to get started and other necessary packages are set up out of the box. During scaffolding, you are prompted to choose a Luau runtime:

- [**Lute**](https://lute.luau.org/)
- [**Lune**](https://lune-org.github.io/docs/)
- [**Zune**](https://zune.sh/)

### Bare

A minimal scaffold that only includes what is needed to work within the Mayari environment — the require resolver, parser, and similar core tooling. It does not include a backend setup. Bare projects are primarily intended for **library development**, where you want a clean base to build on top of for use in Mayari app projects.

## License

MIT
