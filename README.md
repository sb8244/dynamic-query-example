# Sql Builder

This repo is an example of how to build dynamic queries from user-provided logic. I tried to be as "by the books" as I could—I didn't want to write a bunch of custom code that Ecto/Phoenix already handles.

I am amazed at how little code is needed to build this. A lot of that is due to the Ecto / Changeset abstractions. Phoenix's HTML form capabilities (specifically for managing embedded schemas) is also a big contributor to this. LiveView sits on top of it all perfectly, so it all comes together well in the end.

## Instructions

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
