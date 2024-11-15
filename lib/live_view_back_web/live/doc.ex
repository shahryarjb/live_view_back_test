defmodule LiveViewBackWeb.Doc do
  use LiveViewBackWeb, :live_view

  def mount(%{"id" => id} = _params, _session, socket) do
    article = data(id)

    socket =
      socket
      |> assign(page_title: article.title, article: article)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p class="w-full mb-10 font-semibold text-red-400"><%= @article.title %></p>
    <div class="border border-gray-400 p-10">
      <%= raw(@article.body) %>
    </div>

    <hr class="my-4" />
    <.link navigate="/doc/2">Click here to navigate Page B</.link>
    <hr class="my-4" />
    <.link navigate="/doc/1">Click here to navigate Page A</.link>
    """
  end

  # If you comment this handle_params you got an error
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def data("1") do
    %{title: "This is test Title one", body: "<strong>This is test Content one</strong>"}
  end

  def data("2") do
    %{title: "This is test Title two", body: "<two>This is test Content two</two>"}
  end
end
