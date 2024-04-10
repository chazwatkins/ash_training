defmodule TwitterWeb.JsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Twitter.Tweets"])],
    json_schema: "/json_schema",
    open_api: "/open_api"
end
