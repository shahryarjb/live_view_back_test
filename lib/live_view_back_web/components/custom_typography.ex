defmodule LiveViewBackWeb.CustomTypography do
  use Phoenix.Component

  @doc """
  Custom responsive table component with flexible columns and rows.
  It accepts slots for header, rows, and individual table cells (td and th), which come with default styling.
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: "color1", doc: "color of element"
  attr :size, :string, default: "text-3xl", doc: "text size of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading1(assigns) do
    ~H"""
    <h1
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: "color2", doc: "color of element"
  attr :size, :string, default: "text-2xl", doc: "text size of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading2(assigns) do
    ~H"""
    <h2
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: "color3", doc: "color of element"
  attr :size, :string, default: "text-xl", doc: "text size of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading3(assigns) do
    ~H"""
    <h3
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: nil, doc: "color of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :size, :string, default: "text-lg", doc: "text size of element"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading4(assigns) do
    ~H"""
    <h4
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h4>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: nil, doc: "color of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :size, :string, default: "text-base", doc: "text size of element"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading5(assigns) do
    ~H"""
    <h5
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h5>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: nil, doc: "color of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :size, :string, default: "text-sm", doc: "text size of element"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def heading6(assigns) do
    ~H"""
    <h6
      id={@id}
      class={[
        "font-bold",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </h6>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier used to manage state and interaction"

  attr :color, :string, default: nil, doc: "color of element"
  attr :class, :string, default: nil, doc: "extra styles"
  attr :margin, :string, default: "my-1.5", doc: "extra styles"
  attr :size, :string, default: nil, doc: "text size of element"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def cp(assigns) do
    ~H"""
    <p
      id={@id}
      class={[
        "leading-[1.875rem]",
        color_class(@color),
        @size,
        @margin,
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :navigate, :string,
    default: nil,
    doc: "Defines the path for navigation within the application using a `navigate` attribute."

  attr :patch, :string,
    default: nil,
    doc: "Specifies the path for navigation using a LiveView patch."

  attr :color, :string, default: "color4", doc: "color of element"

  attr :href, :string, default: nil, doc: "Sets the URL for an external link."
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global, doc: ""

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def clink(assigns) do
    ~H"""
    <.link
      href={@href}
      navigate={@navigate}
      patch={@patch}
      class={[
        color_class(@color),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  defp color_class("color1") do
    "text-[#448d96]"
  end


  defp color_class("color2") do
    "text-[#7b9b83]"
  end

  defp color_class("color3") do
    "text-[#444444] dark:text-[#cacfd2]"
  end

  defp color_class("color4") do
    "text-[#65BEC9]"
  end

  defp color_class(params) when is_binary(params), do: [params]
  defp color_class(_), do: nil
end
