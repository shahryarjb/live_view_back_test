---
title: Improving SEO and Enhancing Static Blog Posts with Wallaby + Image + LiveBook for Social Media Sharing
headline: Streamline SEO for Static Blogs with Wallaby, LiveBook, and Image Processing in Elixir — A Step-by-Step Guide to Automate Social Media Optimization Using Screenshots and Meta Tags in Phoenix.
read_time: 8
tags:
  - Phoenix
author:
  full_name: Shahryar Tavakkoli
  image: shahryar-tavakkoli.jpg
  twitter: https://x.com/shahryar_tbiz
  linkedin: https://www.linkedin.com/in/shahryar-tavakkoli
  github: https://github.com/shahryarjb
description: Enhance your static blog's SEO with Wallaby, Image, and LiveBook in Elixir. Automate capturing screenshots, optimizing images, and adding custom SEO tags in Phoenix for improved social media sharing. Discover a step-by-step guide to boost engagement effortlessly!
keywords: Elixir, Phoenix, LiveBook, Wallaby, SEO optimization, static blogs, social media sharing, screenshot automation, E2E testing, web automation, website screenshots
image: /images/blog/improving-seo-and-enhancing-static-blog-posts-with-wallaby-image-livebook-for-social-media-sharing.jpg
language: EN
code1: |
  Mix.install([{:wallaby, "~> 0.30"}, {:image, "~> 0.54.4"}])

code2: |
  Application.put_env(:wallaby, :driver, Wallaby.Chrome)
  Application.put_env(:wallaby, :base_url, "http://localhost:4000")
  Application.put_env(:wallaby, :chromedriver, path: "/usr/local/bin/chromedriver")
  Application.put_env(:wallaby, :screenshot_dir, "/YOUR_SYSTEM_PATH/mishka/priv/static/images")

code3: |
  {:ok, _} = Application.ensure_all_started(:wallaby)
  use Wallaby.DSL

code4: |
  defmodule Docs do
    def list() do
      [
        "/breadcrumb",
        "/dropdown",
        "/mega-menu",
        ...
      ]
    end
  end

  """
  Page count: #{length(Docs.list())}
  """

code5: |
  defmodule Screenshot do
    def run() do
      {:ok, session} =
        Wallaby.start_session(
          window_size: [width: 1280, height: 720],
          headless: false,
          chromeOptions: %{
            args: [],
            useAutomationExtension: false,
            excludeSwitches: ["enable-automation"]
          }
        )


        Enum.reduce(Docs.list(), session, fn item, acc ->
          file_name = if item == "/", do: "get-started", else: String.replace(item, "/", "")

          Wallaby.Browser.visit(acc, item)
          |> Wallaby.Browser.take_screenshot(name: file_name)
          |> Wallaby.Browser.assert_has(Query.css(".footer-custom-component", visible: true))
          |> Wallaby.Browser.find(Query.text("Netherlands", visible: true))
          acc
        end)


      Wallaby.end_session(session)
    end
  end

code6: |
  defmodule ImageProcessor do
    @folder_path Application.compile_env(:wallaby, :screenshot_dir)

    def run() do
      {:ok, files} = File.ls(@folder_path)

      files
      |> Enum.reject(&Path.extname(&1) != ".png")
      |> Enum.each(fn file ->
        file_path = Path.join([@folder_path, file])

        case Image.open(file_path) do
          {:ok, image} ->
            original_width = 1280
            new_width = original_width - 80
            new_height = 428

            {:ok, cropped_image} = Image.crop(image, 40, 0, new_width, new_height)

            output_path = Path.join([@folder_path, "cropped_#{file}"])
            Image.write(cropped_image, output_path)
            File.rm(file_path)

          {:error, reason} ->
            IO.puts("Not processed: #{file}: #{reason}")
        end
      end)
    end
  end

code7: |
  defmodule ExtraJob do
    @folder_path Application.compile_env(:wallaby, :screenshot_dir)

    def run() do
      File.ls!(@folder_path)
      |> Enum.reject(&Path.extname(&1) != ".png" and !String.starts_with?(&1, "cropped_"))
      |> Enum.each(fn file ->
        new_name = String.replace_prefix(file, "cropped_", "")
        old_path = Path.join([@folder_path, file])
        new_path = Path.join([@folder_path, new_name])
        File.rename(old_path, new_path)
      end)
    end
  end

code8: |
  Screenshot.run()
  ImageProcessor.run()
  ExtraJob.run()

code9: |
  @doc type: :component
  attr :seo_tags, :map

  def custom_seo_tags(assigns) do
    ~H"""
    <meta name="description" content={@seo_tags[:description]} />
    <meta name="keywords" content={@seo_tags[:keywords]} />
    <base href={@seo_tags[:base]} />
    <meta name="author" content="Mishka Software group" />
    <meta name="copyright" content="Mishka Software group" />
    <link rel="canonical" href={@seo_tags[:canonical]} />
    <meta name="robots" content="index, follow" />

    <meta property="og:site_name" content="Mishka" />
    <meta property="og:locale" content="en_US" />
    <meta property="og:image" content={@seo_tags[:og_image]} />
    <meta property="og:image:alt" content={@seo_tags[:og_image_alt]} />
    <meta property="og:image:width" content={@seo_tags[:og_image_width] || "1200"} />
    <meta property="og:image:height" content={@seo_tags[:og_image_height] || "428"} />
    <meta property="og:title" content={@seo_tags[:og_title]} />
    <meta property="og:description" content={@seo_tags[:og_description]} />
    <meta property="og:type" content={@seo_tags[:og_type]} />
    <meta property="og:url" content={@seo_tags[:og_url]} />

    <meta name="twitter:card" content={@seo_tags[:twitter_card] || "summary_large_image"} />
    <meta name="twitter:image" content={@seo_tags[:twitter_image]} />
    <meta name="twitter:image:alt" content={@seo_tags[:twitter_image_alt]} />
    <meta name="twitter:url" content={@seo_tags[:twitter_url]} />
    <meta name="twitter:title" content={@seo_tags[:twitter_title]} />
    <meta name="twitter:description" content={@seo_tags[:twitter_description]} />
    <meta name="twitter:site" content="@shahryar_tbiz" />
    """
  end

---

<br />

<p align="center">
<img src="/images/blog/improving-seo-and-enhancing-static-blog-posts-with-wallaby-image-livebook-for-social-media-sharing.jpg" alt="Initial Implementation of Service Worker with Workbox in the Phoenix Framework">
</p>

<br />

<.cp>Sometimes, small tweaks can have a significant impact on user engagement and SEO,
especially for static blogs (e.g., <.clink navigate="/blog/build-a-static-site-in-elixir-under-5-minutes-with-phoenix-components">Build a Static Site in Elixir Under 5 Minutes with Phoenix Components</.clink>).
For example, if you visit the <.clink navigate="/chelekom">Mishka Chelekom</.clink> documentation and share a section on social media,
instead of just a simple link, you’ll notice a large image along with a title and description appear.
Automating this process for a large volume of content can be challenging and error-prone.</.cp>

<.cp position="left" color="success" class="my-3" border="medium">
In this quick guide, we aim to modernize scripting using the LiveBook project. If you haven't used LiveBook before, it's essentially designed to automate code and data workflows with interactive notebooks. It allows you to run Elixir code seamlessly in a visually appealing environment.
</.cp>


---

<br />

<LiveViewBackWeb.List.list variant="transparent" size="medium" style="list-decimal" class="px-5">
<:item padding="small">
<strong>Step 1: Load All Website Links</strong>: The first step is to open every page of the website to ensure that it loads exactly as a user would see it.
</:item>
<:item padding="small">
<strong>Step 2: Take Screenshots of Pages</strong>: Next, we need to capture a screenshot of each page.
</:item>
<:item padding="small">
<strong>Step 3: Set Screenshot Size and Position</strong>: In this step, we'll define the exact size and area of the page to capture for each screenshot.
</:item>
</LiveViewBackWeb.List.list>

<.cp>Most of the above tasks can be accomplished using **E2E testing** libraries like
**Cypress** or **Playwright**. However, since a good library already exists in Elixir,
and we want to use it within **LiveBook**, we'll opt for **Wallaby**. Finally, we'll adjust the
captured images to fit the appropriate meta tag requirements using the Image library.</.cp>

<br />

<.heading2>Quick Summary of Our Approach</.heading2>

<.cp>We'll visit all website links, load each page, take screenshots, and crop them to the
desired size. These steps mimic a real user experience by launching a Chrome browser
to capture screenshots, with the process partially automated.</.cp>


<br />

<.heading3>Prerequisites</.heading3>

<.cp>The only requirement to start is having Chromium installed on your system.
It’s best to follow online guides to install it and ensure you know its path.
This tutorial is demonstrated on macOS, but it should also work similarly on Linux.</.cp>

<br />

<.heading3>Let’s Dive into the Code!</.heading3>

<.cp>Before coding, note that due to simplicity and minimal requirements, we haven’t
fully automated all steps. Feel free to optimize this workflow.</.cp>

<br />

<.heading4 color="color1">Install Dependencies</.heading4>
<.custom_code_wrapper type="elixir" code={@attrs.code1}/>

<br />

<.heading4 color="color1">Initial Setup</.heading4>
<.custom_code_wrapper type="elixir" code={@attrs.code2}/>

<.cp>In the above configuration, we set the Chromedriver path and specify the base URL
for capturing screenshots, along with the directory to save the images.</.cp>


<br />

<.heading4 color="color1">Ensure Dependencies are Loaded</.heading4>
<.cp>In the next section, it’s simply to double-check whether we've implemented everything we need,
and it also serves as an extra space in case we want to use additional functions.</.cp>
<.custom_code_wrapper type="elixir" code={@attrs.code3}/>

<br />

<.heading4 color="color1">Define Website URLs</.heading4>
<.cp>Almost everything we needed to install and configure is complete, and now we should move
on to setting up the website URLs.</.cp>
<.custom_code_wrapper type="elixir" code={@attrs.code4}/>
<.cp>In the above code, I’ve included all the URLs from my website that I need to capture screenshots of.</.cp>
<.cp>Now, it's time to write the Wallaby code snippet for taking screenshots.
We'll create a separate module with minimal lines of code, keeping it very clear and readable.</.cp>

<br />

<.heading4 color="color1">Capture Screenshots Using Wallaby</.heading4>
<.custom_code_wrapper type="elixir" code={@attrs.code5}/>
<.cp>**Let’s break down the code a bit:**</.cp>
<.cp>First, a set of options is passed to Chrome, specifying the desired window size and
capabilities for it to run with. Next, the list of routes is obtained,
which are then adjusted based on the specific needs of my website for proper routing.
Finally, you can see that I've targeted the text in my footer to ensure the entire webpage
has fully loaded.</.cp>

<br />

<.heading4 color="color1">Crop the Screenshots</.heading4>
<.cp>Now that the screenshots have been taken, we need to crop them. This is where this module can be extremely useful.</.cp>
<.custom_code_wrapper type="elixir" code={@attrs.code6}/>

<br />

<.heading4 color="color1">Clean Up Unneeded Files</.heading4>
<.cp>You've covered about 80% of the process so far. You’ve cropped the images to the
required size and position, saving them with a new name alongside the original ones.
At this point, your work is nearly complete, but there's one final, very simple step
we can take: deleting any unnecessary images.</.cp>
<.custom_code_wrapper type="elixir" code={@attrs.code7}/>

<br />

<.heading4 color="color1">Run the Process</.heading4>
<.custom_code_wrapper type="elixir" code={@attrs.code8}/>

<.cp>All of these steps were completed in about an hour with a focus on getting the
job done quickly rather than perfection. In just a few minutes, we were able to
generate around 120 images for our website and use them for meta tags.</.cp>

<br />

<.heading4 color="color1">Adding Custom SEO Tags in Phoenix</.heading4>
<.custom_code_wrapper code={@attrs.code9}/>

<br />


---

<br />

<.heading4 color="color1">Conclusion</.heading4>

<.cp position="left" color="success" class="my-3" border="medium">
All the code snippets mentioned above are available for <.clink href="https://gist.github.com/shahryarjb/5399cf669991c6b72f7fe9947f4d251b" target="_blank">download</.clink>. Feel free to enhance and automate the process further as needed.
If you found this tutorial helpful, please share it on social media!
</.cp>

<.cp position="left" color="success" class="my-3" border="medium">
Discover more by supporting me on <.clink href="https://github.com/sponsors/mishka-group" target="_blank">Github Support</.clink> / <.clink href="https://buymeacoffee.com/mishkagroup" target="_blank">BuyMeACoffee</.clink>
</.cp>
