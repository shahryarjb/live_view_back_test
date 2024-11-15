defmodule LiveViewBack.Blog do
  defmodule HTMLParser do
    require Logger

    defstruct [
      :id,
      :title,
      :headline,
      :draft,
      :excerpt,
      :body,
      :date,
      :tags,
      :author,
      :read_time,
      :description,
      :keywords,
      :image
    ]

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
  end

  defmodule MDExConverter do
    def convert(filepath, body, attrs, _opts) do
      if Path.extname(filepath) in [".md", ".markdown"] do
        to_html!(filepath, body, %{attrs: attrs})
        |> String.replace(
          "<pre class=\"autumn-hl\" style=\"background-color: #282C34; color: #ABB2BF;\">",
          "<pre class=\"highlight\">"
        )
      end
    end

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
      import LiveViewBackWeb.CustomInlineCode, warn: false
      import LiveViewBackWeb.CustomBlock, warn: false
      import LiveViewBackWeb.CustomTypography, warn: false
      import LiveViewBackWeb.CustomCodeWrapper, warn: false
      __ENV__
    end
  end

  use NimblePublisher,
    build: __MODULE__.HTMLParser,
    parser: __MODULE__.HTMLParser,
    from: Application.app_dir(:live_view_back, "priv/articles/**/*.md"),
    as: :articles,
    html_converter: __MODULE__.MDExConverter,
    highlighters: [:makeup_eex, :makeup_elixir]

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  alias LiveViewBack.Blog.NotFoundError

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

  def get_posts_by_tags(tags) do
    Enum.filter(all_articles(), fn post ->
      Enum.any?(post.tags, &(&1 in tags))
    end)
  end

  def get_posts_by_author(author_name) do
    Enum.filter(all_articles(), &(author_name == &1.author["full_name"]))
  end
end
