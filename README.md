# Annotate From File Buildkite Plugin

Annotates the build with the contents of a file

This is intended to be used with other plugins like docker-compose.

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls > /app/output/output.md
    plugins:
      - docker-compose#v3.7.0:
          run: app
          volumes:
            - "./output:/app/output"
      - phcyso/annotate-from-file#v1.0.0:
          path: "./output/output.md"
```

## Configuration

### `path` (Required, string)

The path to the file to show as an annotation. Each files that match this
pattern will create an annotation.

### `must_exist` (Optional, boolean, default: false)

If `must_exist` is set to true then the plugin will exit non zero if the files
given in `path` does not exist

### `style` (Optional, string, default: "info")

One of the allowed annotation
[styles](https://buildkite.com/docs/agent/v3/cli-annotate#annotation-styles)

### `context` (Optional, string, default: it will use the default context)

The context of the annotation used to differentiate this annotation from others,
if no defined it will use default context.

Use `file_name`as context value if you want to specify context value same as
file name.

### `append` (Optional, boolean, default: false)

Append to the body of an existing annotation depending on the given annotation
context.

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
