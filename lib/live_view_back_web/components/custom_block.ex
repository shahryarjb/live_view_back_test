defmodule LiveViewBackWeb.CustomBlock do
  use Phoenix.Component

  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn"
  ]


  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :padding, :string,
    values: ["extra_small", "small", "medium", "large", "extra_large", "none"],
    default: "small",
    doc: "Determines padding for items"

  attr :variant, :string,
    values: ["default", "outline", "unbordered"],
    default: "default",
    doc: "Determines the style"

  attr :color, :string, values: @colors, default: "primary", doc: "Determines color theme"

  attr :border, :string,
    values: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
    default: "extra_small",
    doc: "Determines border style"

  attr :rounded, :string,
    values: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
    default: "small",
    doc: "Determines the border radius"

  attr :position, :string,
    values: ["right", "left", "full"],
    default: "full",
    doc: "Determines the element's border position"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  slot :title, required: false

  slot :content, required: false
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def custom_block(assigns) do
    ~H"""
    <div class={[
      border_class(@border, @position),
      color_variant(@variant, @color),
      rounded_size(@rounded),
      padding_size(@padding),
      @class
    ]}>
      <div :if={@title} class="">
        <%= render_slot(@title) %>
      </div>

      <div :if={@content} class="">
        <%= render_slot(@content) %>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp border_class(_, "none"), do: "border-0"

  defp border_class("extra_small", position) do
    [
      position == "left" && "border-s",
      position == "right" && "border-e",
      position == "full" && "border"
    ]
  end

  defp border_class("small", position) do
    [
      position == "left" && "border-s-2",
      position == "right" && "border-s-2",
      position == "full" && "border-2"
    ]
  end

  defp border_class("medium", position) do
    [
      position == "left" && "border-s-[3px]",
      position == "right" && "border-e-[3px]",
      position == "full" && "border-[3px]"
    ]
  end

  defp border_class("large", position) do
    [
      position == "left" && "border-s-4",
      position == "right" && "border-e-4",
      position == "full" && "border-4"
    ]
  end

  defp border_class("extra_large", position) do
    [
      position == "left" && "border-s-[5px]",
      position == "right" && "border-e-[5px]",
      position == "full" && "border-[5px]"
    ]
  end

  defp border_class(params, _) when is_binary(params), do: [params]
  defp border_class(nil, _), do: nil

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("full"), do: "rounded-full"

  defp rounded_size(nil), do: "rounded-none"

  defp padding_size("extra_small"), do: "p-1"

  defp padding_size("small"), do: "p-2"

  defp padding_size("medium"), do: "p-3"

  defp padding_size("large"), do: "p-4"

  defp padding_size("extra_large"), do: "p-5"

  defp padding_size("none"), do: "p-0"

  defp padding_size(params) when is_binary(params), do: params

  defp padding_size(_), do: padding_size("small")

  defp color_variant("default", "primary") do
    "bg-white border-[#2441de]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "primary") do
    "border-white"
  end

  defp color_variant("outline", "success") do
    "border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end
end
