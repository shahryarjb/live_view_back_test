defmodule LiveViewBackWeb.CustomCodeWrapper do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias Makeup.Formatters.HTML.HTMLFormatter
  alias Makeup.Lexers.{ElixirLexer, HEExLexer}
  alias Phoenix.HTML
  import Phoenix.LiveView.Utils, only: [random_id: 0]


  @doc type: :component
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :elements_class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :code, :string, default: nil, doc: ""
  attr :code_class, :string, default: nil, doc: ""
  attr :type, :string, values: ["elixir", "heex"], default: "heex", doc: ""

  slot :code_block, required: false
  slot :inner_block, required: false, doc: ""

  def custom_code_wrapper(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> random_id() end)

    ~H"""
    <div class={[@class]}>
      <div :if={@type == "heex"} class="flex justify-end items-center gap-2">
        <button
          :for={item <- ["RTL", "LTR"]}
          phx-click={JS.set_attribute({"dir", String.downcase(item)}, to: "#example-parent-#{@id}")}
          class="bg-[#2c4246] text-[#9cd0d0] dark:bg-[#2c4246]/40 dark:hover:bg-[#2c4246]/50 rounded-[4px] leading-5 size-10 inline-flex justify-center items-center text-[13px]"
        >
          <%= item %>
        </button>
      </div>

      <div
        :if={@inner_block != [] and !is_nil(@inner_block)}
        class={["py-8 w-full", @elements_class]}
        id={"example-parent-#{@id}"}
      >
        <%= render_slot(@inner_block) %>
      </div>

      <div
        :if={code_string = render_slot(@code_block) || @code}
        id={"code-parent-#{@id}"}
        class={["rounded-md mt-4 py-2 group leading-6 relative bg-[#272822]", @code_class]}
      >
        <pre
          :if={@type == "heex"}
          id={@id}
          class="highlight w-full overflow-hidden overflow-x-auto py-5 px-2"
        ><%= format_heex(@code) %></pre>
        <pre
          :if={@type == "elixir"}
          id={@id}
          class="highlight w-full overflow-hidden overflow-x-auto py-5 px-2"
        ><%= format_elixir(code_string) %></pre>
      </div>
    </div>
    """
  end

  defp format_heex(code) do
    code
    |> String.trim()
    |> HEExLexer.lex()
    |> HTMLFormatter.format_inner_as_binary([])
    |> HTML.raw()
  end

  defp format_elixir(code) do
    code
    |> String.trim()
    |> ElixirLexer.lex()
    |> HTMLFormatter.format_inner_as_binary([])
    |> HTML.raw()
  end
end
