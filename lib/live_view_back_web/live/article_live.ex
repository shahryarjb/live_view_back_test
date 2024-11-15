defmodule LiveViewBackWeb.Blog.ArticleLive do
  use LiveViewBackWeb, :live_view

  def mount(%{"id" => id} = _params, _session, socket) do
    article = LiveViewBack.Blog.get_post_by_id!(id)

    socket =
      socket
      |> assign(page_title: article.title, article: article)

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
