#!/bin/bash
# Docker entrypoint script.

mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs

exec mix phx.server