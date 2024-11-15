defmodule LiveViewBackWeb.CustomInlineCode do
  use Phoenix.Component


  @doc type: :component
  slot :inner_block, doc: "Inner block that renders HEEx content"

  def custom_inline_code(assigns) do
    ~H"""
    <code
      class="px-1 py-px text-white rounded-[3px] inline-block mx-0.5 text-sm leading-5 w-fit bg-[#3B3B3B]"
      dir="ltr"
    >
      <%= render_slot(@inner_block) %>
    </code>
    """
  end
end
