---
title: Build a Static Site in Elixir Under 5 Minutes with Phoenix Components
headline: Discover how to transform markdown into dynamic HTML using Phoenix components for a seamless static site experience.
read_time: 5
tags:
  - Phoenix
  - LiveView
author:
  full_name: Shahryar Tavakkoli
  image: shahryar-tavakkoli.jpg
  twitter: https://x.com/shahryar_tbiz
  linkedin: https://www.linkedin.com/in/shahryar-tavakkoli
  github: https://github.com/shahryarjb
description: Learn how to quickly build a static blog site using Elixir and Phoenix components. This guide covers converting markdown files to HTML, using MDEx, Nimble Publisher and rendering Phoenix components for a dynamic yet static blog experience.
keywords: static site, Elixir, Nimble Publisher, MDEx, Markdown in Elixir, Elixir Static blog, Build a blog in Elixir, Phoenix framework
image: /images/blog/build-a-static-site-in-elixir-under-5-minutes-with-phoenix-components.png
language: EN
code1: |
  def deps do
    [{:nimble_publisher, "~> 1.1"}]
  end

code2: |
  def deps do
    [{:mdex, "~> 0.2.0"}]
  end

code3: |
  def deps do
    [{:yaml_elixir, "~> 2.11"}]
  end

code4: |
  def deps do
    [{:html_entities, "~> 0.5.2"}]
    # or
    [{:floki, "~> 0.36.2"}]
  end

code5: |
  use NimblePublisher,
    build: __MODULE__.HTMLParser,
    parser: __MODULE__.HTMLParser,
    from: Application.app_dir(:mishka, "priv/articles/**/*.md"),
    as: :articles,
    html_converter: __MODULE__.MDExConverter,
    highlighters: [:makeup_eex, :makeup_elixir]

code6: |
  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  alias Mishka.Blog.NotFoundError

  # The @articles variable is first defined by NimblePublisher.
  # Let's further modify it by sorting all articles by descending date.
  @articles Enum.sort_by(@articles, & &1.date, {:desc, Date})

  # Let's also get all tags
  @tags @articles |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # And finally export them
  def all_articles, do: @articles
  def all_tags, do: @tags

  def get_post_by_id!(id) do
    Enum.find(all_articles(), &(&1.id == id)) ||
      raise NotFoundError,
            "Unfortunately, the article you are looking for is not available on the Mishka website."
  end

  def get_posts_by_tag(tag) do
    Enum.filter(all_articles(), &(tag in &1.tags))
  end

  def get_posts_by_author(author_name) do
    Enum.filter(all_articles(), &(author_name == &1.author["full_name"]))
  end

code7: |
  # I got this code from: https://github.com/LostKobrakai/kobrakai_elixir
  def parse(_path, contents) do
    ["---\n" <> yaml, body] =
      contents
      |> String.replace("\r\n", "\n")
      |> :binary.split(["\n---\n"])

    {:ok, attrs} = YamlElixir.read_from_string(yaml)
    attrs = Map.new(attrs, fn {k, v} -> {String.to_atom(k), v} end)

    attrs =
      case :binary.split(body, ["\n<!-- excerpt -->\n"]) do
        [excerpt | [_ | _]] -> Map.put(attrs, :excerpt, String.trim(excerpt))
        _ -> attrs
      end

    {attrs, body}
  end

code8: |
  def build(filename, attrs, body) do
    [year, month, day, id] = filename |> Path.basename(".md") |> String.split("-", parts: 4)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    body =
      body
      |> String.replace("<pre>", "<pre class=\"highlight\">")

    Logger.debug(
      "The desired content was copied with ID #{inspect(id)} for Mishka static Blog section."
    )

    %__MODULE__{
      id: id,
      headline: Map.get(attrs, :headline),
      title: attrs[:title],
      date: date,
      excerpt: attrs[:excerpt],
      draft: !!attrs[:draft],
      tags: Map.get(attrs, :tags, []),
      author: Map.get(attrs, :author, %{}),
      read_time: attrs[:read_time],
      description: attrs[:description],
      keywords: attrs[:keywords],
      image: attrs[:image],
      body: body
    }
  end

code9: |
  def convert(filepath, body, attrs, _opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      to_html!(filepath, body, %{attrs: attrs})
      |> String.replace(
        "<pre class=\"autumn-hl\" style=\"background-color: #282C34; color: #ABB2BF;\">",
        "<pre class=\"highlight\">"
      )
    end
  end

code10: |
  # I got code from https://gist.github.com/leandrocp/e65fd43e58640b0cc0cfa02a03d36718
  def to_html!(filepath, markdown, assigns \\ %{}) do
    opts = [
      extension: [
        strikethrough: true,
        tagfilter: true,
        table: true,
        tasklist: true,
        footnotes: true,
        shortcodes: true
      ],
      parse: [
        relaxed_tasklist_matching: true
      ],
      render: [
        unsafe_: true
      ],
      features: [syntax_highlight_inline_style: false]
    ]

    markdown
    |> MDEx.to_html!(opts)
    |> unescape()
    |> render_heex!(filepath, assigns)
  end

  defp unescape(html) do
    ~r/(<pre.*?<\/pre>)/s
    |> Regex.split(html, include_captures: true)
    |> Enum.map(fn part ->
      if String.starts_with?(part, "<pre") do
        part
      else
        Floki.parse_document!(part)
        |> Floki.raw_html(encode: false)
      end
    end)
    |> Enum.join()
  end

  defp render_heex!(html, filepath, assigns) do
    env = env()

    opts = [
      source: html,
      engine: Phoenix.LiveView.TagEngine,
      tag_handler: Phoenix.LiveView.HTMLEngine,
      file: filepath,
      caller: env,
      line: 1,
      indentation: 0
    ]

    {rendered, _} =
      html
      |> EEx.compile_string(opts)
      |> Code.eval_quoted([assigns: assigns], env)

    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp env do
    import Phoenix.Component, warn: false
    import MishkaWeb.Components.Typography, warn: false
    ...
    __ENV__
  end

code11: |
  Floki.parse_document!(part)
  |> Floki.raw_html(encode: false)

code12: |
  HtmlEntities.decode(part)

code13: |
  defp env do
    import Phoenix.Component, warn: false
    import MishkaWeb.Components.Typography, warn: false
    __ENV__
  end

code14: |
  defmodule CustomContent do
    use Phoenix.Component
    # import MishkaWeb.Components.Typography, only: [h2: 1]

    @doc type: :component
    # For example: <!-- [YourComponentModule] -->
    # Component should be like:
    # https://github.com/LostKobrakai/kobrakai_elixir/blob/main/lib/kobrakai_web/live/one_to_many_form.ex
    # It should call <.custom_content conn={@conn} content={@post.body} />
    def custom_content(assigns) do
      stream = Stream.cycle([:html, :live])
      parts = :binary.split(assigns.content, ["<!-- [", "] -->"], [:global])
      assigns = assigns |> assign(:parts, Enum.zip([stream, parts]))

      ~H"""
      <%= for p <- @parts do %>
        <%= case p do %>
          <% {:live, live} -> %>
            <%= live_render(@conn, Module.concat([live])) %>
          <% {:html, html} -> %>
            <%= Phoenix.HTML.raw(html) %>
        <% end %>
      <% end %>
      """
    end
  end

code15: |
  <!-- [YourComponentModule] -->
---

<br />

<p align="center">
<img src="/images/blog/build-a-static-site-in-elixir-under-5-minutes-with-phoenix-components.png" alt="Build a Static Site in Elixir Under 5 Minutes with Phoenix Components">
</p>

<br />

<.heading2>Build a Static Site in Elixir Under 5 Minutes with Phoenix Components</.heading2>

<.cp>In this tutorial, you'll learn how to quickly build a static blog site using Elixir.
This guide will walk you through converting <.custom_inline_code>.md</.custom_inline_code>
files into in-memory content that can be rendered as a blog on your Elixir Phoenix website.
You'll see how to use <.custom_inline_code>Phoenix components</.custom_inline_code>
within your markdown files, which makes for rapid implementation and an impressive mix of
static content and Phoenix components.</.cp>

If you’re as excited as I am, then yes, you can execute <.clink navigate="/chelekom">Phoenix components</.clink> —both stateless components and
LiveView module the middle of an <.custom_inline_code>.md</.custom_inline_code> file, and then
convert and keep them as HTML in memory.

<br />

---

<br />

**Libraries We'll Use in this article**

<LiveViewBackWeb.List.list variant="transparent" size="medium" style="list-decimal" class="px-5">
  <:item padding="small">
    <.clink href="https://github.com/dashbitco/nimble_publisher" target="_blank">Nimble_publisher</.clink>
  </:item>
  <:item padding="small">
    <.clink href="https://github.com/leandrocp/mdex" target="_blank">Mdex</.clink>
  </:item>
  <:item padding="small">
    <.clink href="https://github.com/KamilLelonek/yaml-elixir" target="_blank">Yaml_elixir</.clink> (optional)
  </:item>
  <:item padding="small">
    <.clink href="https://github.com/martinsvalin/html_entities" target="_blank">Html_entities</.clink> or
    <.clink href="https://github.com/philss/floki" target="_blank">Floki</.clink>
  </:item>
</LiveViewBackWeb.List.list>


<.custom_block position="left" color="success" class="my-8" border="medium">
**Note:** All these libraries are needed when importing <.custom_inline_code>.md</.custom_inline_code> files into system memory.
After importing, they are no longer needed, similar to compile-time dependencies—unless you're
planning to handle runtime user input or <.custom_inline_code>.md</.custom_inline_code> sources from less secure locations.
</.custom_block>

<.custom_block position="left" color="success" class="my-8" border="medium">
**Note:** Our entire blog is built this way, so you can expect to see Phoenix components throughout.
The full code for the sections covered in this guide is provided at the end.
</.custom_block>

<br />

---

<br />

<.heading2>Step 1: Install Required Dependencies</.heading2>

If you’ve already installed these libraries or are familiar with their use, feel free to skip to the
next section to save some time.

- **Nimble Publisher**: This library is a macro that lets you stack a module to hold converted <.custom_inline_code>.md</.custom_inline_code> files.
It also provides callbacks to separate responsibilities such as parsing, converting, and
building—all of which we will explore.

  For this tutorial, we are using version 1.1.0. Simply add it to your `mix.exs` as shown:

  <.custom_code_wrapper type="elixir" code={@attrs.code1}/>

- **MDEx**: This is the real star of the show—it provides excellent features for converting <.custom_inline_code>.md</.custom_inline_code>
files for use in your Elixir project, including the ability to call stateless Phoenix components directly.

  We're using version 0.2.0. Just add it as follows in `mix.exs`:

  <.custom_code_wrapper type="elixir" code={@attrs.code2}/>

- **Yaml Elixir**: We use this library (optional) to create variables for HTML and SEO settings.
You could use other approaches—even regex would work—but we use it because our blog has lots of code
snippets and metadata like author information. Version 2.11.0 is what we use:

  <.custom_code_wrapper type="elixir" code={@attrs.code3}/>

- **Makeup**: This optional library is great if you want a technical blog that displays code snippets nicely.
If you’re using MDEx, you could skip Makeup, as MDEx can implement highlighting
(we only mention it briefly here).

- **Html Entities and Floki**: Choose either one for HTML encoding. It's used just once during
conversion and not needed afterward. We used versions 0.5.2 and 0.36.2 respectively:

  <.custom_code_wrapper type="elixir" code={@attrs.code4}/>

<br />

---


<.custom_block position="left" color="success" class="my-8" border="medium">
For the complete code used in this tutorial, <.clink href="https://gist.github.com/shahryarjb/03cb925d790ae6d6e6e3cf4dc95e220e" target="_blank">click here.</.clink>
</.custom_block>

<.heading2>Step 2: Building the Blog</.heading2>

<LiveViewBackWeb.List.list variant="transparent" size="medium" style="list-decimal" class="px-5">
  <:item padding="small">
  **Specify the Path and Fetch <.custom_inline_code>.md</.custom_inline_code> Files**
  Define where to find the <.custom_inline_code>.md</.custom_inline_code> files and create an
  environment to process each file independently.
  <.custom_code_wrapper type="elixir" code={@attrs.code5}/>
  </:item>
  <:item padding="small">
   **Parse Each <.custom_inline_code>.md</.custom_inline_code> File**
   Create helper functions and an error-specific module as below:
   <.custom_code_wrapper type="elixir" code={@attrs.code6} class="mb-2"/>
   Now you have the <.custom_inline_code>.md</.custom_inline_code> files loaded into memory,
   and you can call them easily using the provided helper functions.
  </:item>
  <:item padding="small">
   **Build and Parse**
   Next, create the <.custom_inline_code>build</.custom_inline_code> and <.custom_inline_code>parser</.custom_inline_code> modules.
   The parser handles the initial conversion,
   while the builder turns the raw data into a structured map.
   **Parse**
   <.custom_code_wrapper type="elixir" code={@attrs.code7} class="mb-2"/>
   **Build**
   <.custom_code_wrapper type="elixir" code={@attrs.code8}/>
  </:item>
  <:item padding="small">
   **Convert Body to HTML**
   Use MDEx to convert the <.custom_inline_code>.md</.custom_inline_code> content to HTML:
   <.custom_code_wrapper type="elixir" code={@attrs.code9}/>
  </:item>
  <:item padding="small">
   **Convert Phoenix Components**
   Create a module to convert Phoenix components into HTML, allowing you to use components
   like Phoenix's <.custom_inline_code>link</.custom_inline_code> to navigate pages.
   <.custom_code_wrapper type="elixir" code={@attrs.code10} class="mb-2"/>
   This code may look complicated because it handles various tasks, such as listing components
   used in <.custom_inline_code>.md</.custom_inline_code> files, compiling them, and handling core
   elements from Phoenix and LiveView before encoding them into HTML.
  </:item>
  <:item padding="small">
  **Replace Floki (if needed)**
  If you don't want to use Floki, replace the following code snippet:
  <.custom_code_wrapper type="elixir" code={@attrs.code11} class="mb-2"/>
  with:
  <.custom_code_wrapper type="elixir" code={@attrs.code12}/>
  </:item>
</LiveViewBackWeb.List.list>

<br />

---

<br />

<.heading3 color="color1">Bonus: Importing LiveView Components</.heading3>

Sometimes you may want to only call the function within Phoenix's components rather than their full
module name—like with Phoenix's core components. Simply import them in the
<.custom_inline_code>env</.custom_inline_code> function to achieve this.

<.custom_code_wrapper type="elixir" code={@attrs.code13}/>

Beyond the basics, you could even use LiveView modules within the middle of your content—think of
displaying a dynamic form inside a blog post. The answer is yes, this is possible!

Below is an example of using the component to convert your HTML content into an array based on the
presence of live content or not (<.custom_inline_code><%= @attrs.code15 %></.custom_inline_code>).

<.custom_code_wrapper type="elixir" code={@attrs.code14}/>

<.custom_block position="left" color="danger" class="my-8" border="medium">
Notice that for live content, it uses <.custom_inline_code>live_render</.custom_inline_code>, whereas for simple HTML, it uses <.custom_inline_code>Phoenix.HTML.raw</.custom_inline_code>.
</.custom_block>

<.custom_block position="left" color="warning" class="my-8" border="medium">
**Note:** This component/module should be of the <.custom_inline_code>:live_view</.custom_inline_code> type.
</.custom_block>

<.custom_block position="left" color="success" class="my-8" border="medium">
For the complete code used in this tutorial, <.clink href="https://gist.github.com/shahryarjb/03cb925d790ae6d6e6e3cf4dc95e220e" target="_blank">click here.</.clink>.
By the way, <.clink href="https://gist.github.com/shahryarjb/b279801e056f04b4a812f09d88ba5962" target="_blank">click to see the .md file</.clink> of this article
</.custom_block>

<.custom_block position="left" color="warning" class="my-8" border="medium">
**Note:** Each <.custom_inline_code>.md</.custom_inline_code> file should be named like
<.custom_inline_code>2024-08-11-mishka-chelekom-0.0.1.md</.custom_inline_code>.
If you need a different structure, modify the code accordingly. In this guide,
the <.custom_inline_code>.md</.custom_inline_code> files are
located in <.custom_inline_code>priv/articles</.custom_inline_code>,
but you can change this path if needed.
</.custom_block>

If you enjoyed this post, please share it on social media!
