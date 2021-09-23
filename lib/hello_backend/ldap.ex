defmodule HelloBackend.Ldap do
  use GenServer
  require Logger

  @spec get_user(atom | pid, String.t) :: Paddle.ldap_entry | :error
  def get_user(server, username) do
    try do
      GenServer.call(server, {:get_user, username})
    catch _kind, _error ->
      :error
    end
  end

  def start_link(opts) do
    Logger.info("Starting LDAP proxy...")
    Paddle.reconnect()

    Paddle.authenticate(
      Application.get_env(:hello_backend, :ldap_user),
      Application.get_env(:hello_backend, :ldap_pw)
    )

    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast(:keys, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:get_user, username}, _from, state) do
    {:ok, [user_data | _]} = Paddle.get(filter: [uid: username])
    {:reply, user_data, state}
  end
end
