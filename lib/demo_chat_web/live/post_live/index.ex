defmodule DemoChatWeb.PostLive.Index do
  use DemoChatWeb, :live_view

  alias DemoChat.Timeline
  alias DemoChat.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    {:ok, assign(socket, :posts, fetch_posts()), temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Timeline.get_post!(id) |> Timeline.delete_post() do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post deleted successfully")
         |> push_redirect(to: "/posts")}

      {:error, _} ->
        {:noreply,
         socket
         |> push_redirect(to: "/posts")}
    end
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  def handle_info({:post_deleted, _post}, socket) do
    {:noreply, redirect(socket, to: "/posts")}
  end

  defp fetch_posts do
    Timeline.list_posts()
  end
end
