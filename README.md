# Skaia

[![Built with Crystal 1.0.0](https://img.shields.io/badge/Crystal-1.0.0-%23333333)](https://crystal-lang.org/)
[![Unit Tests](https://github.com/kandayo/skaia/workflows/CI/badge.svg)](https://github.com/kandayo/skaia/actions)

Skaia is a queue processor for Crystal and RabbitMQ, à la Sneakers and Sidekiq.

## Index

- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
  - [Dockerized environment](#dockerized-environment)
  - [Local](#local)
- [Contributing](#contributing)
- [Contributors](#contributors)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     skaia:
       github: kandayo/skaia
   ```

2. Run `shards install`

## Usage

```crystal
require "skaia"
```

TODO: Write usage instructions here

## Development

### Dockerized environment

Dependencies:

 - Docker.
 - Docker compose.
 - Dip, https://github.com/bibendi/dip.

Provision the project by running `dip provision` and then use `dip crystal`,
`dip spec` or `dip runner` to interact with the dockerized development
environment.

### Local

If you prefer developing on your local machine, make sure you have RabbitMQ
installed and running.

## Contributing

1. Fork it (<https://github.com/kandayo/skaia/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kandayo](https://github.com/kandayo) - creator and maintainer
