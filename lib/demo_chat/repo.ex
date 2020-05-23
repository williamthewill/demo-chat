defmodule DemoChat.Repo do
  use Ecto.Repo,
    otp_app: :demo_chat,
    adapter: Ecto.Adapters.Postgres
end
