defmodule QrstorageWeb.Router do
  use QrstorageWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", QrstorageWeb do
    pipe_through :browser

    get "/", QrCodeController, :new
    resources "/qrcodes", QrCodeController, only: [:new, :create, :show]
    get "/qrcodes/download/:id", QrCodeController, :download
    get "/qrcodes/preview/:id", QrCodeController, :preview
    get "/qrcodes/admin/:admin_url_id", QrCodeController, :admin
    delete "/qrcodes/delete/:admin_url_id", QrCodeController, :delete
    get "/audio_file/:id", QrCodeController, :audio_file
  end

  # Other scopes may use custom stacks.
  # scope "/api", QrstorageWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: QrstorageWeb.Telemetry
    end
  end
end
