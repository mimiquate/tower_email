# TowerEmail

[![ci](https://github.com/mimiquate/tower_email/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/tower_email/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/tower_email.svg)](https://hex.pm/packages/tower_email)
[![Documentation](https://img.shields.io/badge/Documentation-purple.svg)](https://hexdocs.pm/tower_email)

Error tracking and reporting to your e-mail inbox.

Simple send-me-an-email reporter for [Tower](https://github.com/mimiquate/tower) error handler.

## Installation

The package can be installed by adding `tower_email` to your list of dependencies in `mix.exs`:

```elixir
# mix.exs

def deps do
  [
    {:tower_email, "~> 0.5.2"}
  ]
end
```

## Usage

Register the reporter with Tower.

```elixir
# config/config.exs

config(
  :tower,
  :reporters,
  [
    # along any other possible reporters
    TowerEmail
  ]
)
```

And make any additional configurations specific to this reporter.

```elixir
# Build-time config (config/{config, dev, test, prod}.exs)

config :tower_email,
  otp_app: :your_app,
  from: {"Tower", "tower@<your_domain>"},
  to: "<recipient email address>"

# config/runtime.exs
config :tower_email,
  environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
```

Configuring `Swoosh` adapter for `TowerEmail.Mailer`:

```elixir
# config/dev.exs
config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapters.Local

# config/prod.exs
config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapters.Postmark,

# config/runtime.exs
config :tower_email, TowerEmail.Mailer, api_key: System.fetch_env!("POSTMARK_API_KEY")
```

Configuring `TowerEmail.Mailer` is analogous on how to configure any `Swoosh.Mailer` https://hexdocs.pm/swoosh/Swoosh.Mailer.html.

## License

Copyright 2024 Mimiquate

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
