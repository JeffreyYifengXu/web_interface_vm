defmodule AzureBillingDashboardWeb.Router do
  use AzureBillingDashboardWeb, :router

  import AzureBillingDashboardWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AzureBillingDashboardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AzureBillingDashboardWeb do
    pipe_through :browser

    # get "/", PageController, :index
    # live "/virtualmachines", VirtualMachineLive.Index, :index
    # live "/virtualmachines/new", VirtualMachineLive.Index, :new
    # live "/virtualmachines/:id/edit", VirtualMachineLive.Index, :edit
    # # live "/virtualmachines/:id/start", VirtualMachineLive.Index, :start
    #
    # live "/virtualmachines/:id", VirtualMachineLive.Show, :show
    # live "/virtualmachines/:id/show/edit", VirtualMachineLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", AzureBillingDashboardWeb do
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

      live_dashboard "/dashboard", metrics: AzureBillingDashboardWeb.Telemetry

    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AzureBillingDashboardWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    # get "/users/reset_password", UserResetPasswordController, :new
    # post "/users/reset_password", UserResetPasswordController, :create
    # get "/users/reset_password/:token", UserResetPasswordController, :edit
    # put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", AzureBillingDashboardWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :index

    live "/virtualmachines", VirtualMachineLive.Index, :index
    live "/virtualmachines/new", VirtualMachineLive.Index, :new
    live "/virtualmachines/:id/edit", VirtualMachineLive.Index, :edit
    live "/virtualmachines/:name/start", VirtualMachineLive.Index, :start
    live "/virtualmachines/:name/stop", VirtualMachineLive.Index, :stop

    live "/virtualmachines/:id", VirtualMachineLive.Show, :show
    live "/virtualmachines/:id/show/edit", VirtualMachineLive.Show, :edit

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings/update_password", UserSettingsController, :update_password
    put "/users/settings/update_email", UserSettingsController, :update_email
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/", PageLive, :index
  end

  scope "/", AzureBillingDashboardWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    # get "/users/confirm", UserConfirmationController, :new
    # post "/users/confirm", UserConfirmationController, :create
    # get "/users/confirm/:token", UserConfirmationController, :edit
    # post "/users/confirm/:token", UserConfirmationController, :update
  end
end
