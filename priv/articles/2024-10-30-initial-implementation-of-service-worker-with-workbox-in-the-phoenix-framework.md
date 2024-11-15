---
title: Initial Implementation of Service Worker with Workbox in the Phoenix Framework
headline: Efficiently Implementing Service Workers in Phoenix Framework Using Workbox — Discover how to boost performance and user experience with a step-by-step guide to caching images with service workers and Workbox integration in Phoenix.
read_time: 10
tags:
  - Phoenix
  - LiveView
author:
  full_name: Shahryar Tavakkoli
  image: shahryar-tavakkoli.jpg
  twitter: https://x.com/shahryar_tbiz
  linkedin: https://www.linkedin.com/in/shahryar-tavakkoli
  github: https://github.com/shahryarjb
description: Initial implementation of Service Worker with Workbox in the Phoenix framework for optimizing image caching and enhancing user experience. Leverage the Cache First strategy to boost image load speeds and reduce costs.
keywords: Phoenix Service Worker, Workbox caching, image caching strategy, Cache First, Workbox strategies, optimize Phoenix performance, Service Worker implementation, TypeScript Service Worker, web app speed improvement, browser optimization, Cache Storage, Service Worker API
image: /images/blog/initial-implementation-of-service-worker-with-workbox-in-the-phoenix-framework.jpg
language: EN
code1: |
  /// <reference lib="webworker" />
  import { clientsClaim } from "workbox-core";
  import { registerRoute } from "workbox-routing";
  import { ExpirationPlugin } from "workbox-expiration";
  import { CacheFirst } from "workbox-strategies";

  declare const self: ServiceWorkerGlobalScope;

  clientsClaim();
  self.skipWaiting();

code2: |
  registerRoute(
    ({ request, url }) => {
      const isImage = request.destination === "image";
      const isInImagesFolder = url.pathname.startsWith("/images/");
      const isNotServiceWorker = !url.pathname.includes("/sw.js");

      return isImage && isInImagesFolder && isNotServiceWorker;
    },
    new CacheFirst({
      cacheName: "images-cache",
      plugins: [
        new ExpirationPlugin({
          maxEntries: 50,
          maxAgeSeconds: 30 * 24 * 60 * 60,
        }),
      ],
    }),
  );

code3: |
  {
    "dependencies": {
      "workbox-build": "^7.1.1",
      "workbox-cli": "^7.1.0",
      "workbox-precaching": "^7.1.0"
    }
  }

code4: |
  def static_paths,
    do: ~w(assets fonts images favicon.ico robots.txt sitemap.xml.gz sitemap-00001.xml.gz sw.js)


code5: |
  config :esbuild,
    version: "0.17.11",
    mishka: [
      args:
        ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ],
    sw: [
      args:
        ~w(js/sw.ts --bundle --target=es2017 --outfile=../priv/static/sw.js --platform=browser --minify --define:process.env.NODE_ENV="production"),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]

code6: |
  config :mishka, MishkaWeb.Endpoint,
    # Binding to loopback ipv4 address prevents access from other machines.
    # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
    http: [ip: {127, 0, 0, 1}, port: 4000],
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    secret_key_base: "Your Token",
    watchers: [
      esbuild: {Esbuild, :install_and_run, [:mishka, ~w(--sourcemap=inline --watch)]},
      tailwind: {Tailwind, :install_and_run, [:mishka, ~w(--watch)]},
      esbuild_sw: {Esbuild, :install_and_run, [:sw, ~w(--sourcemap=inline --watch)]},
      esbuild_sw:
        {Esbuild, :install_and_run,
        [:sw, ~w(--watch --minify --define:process.env.NODE_ENV="production")]}
    ]

code7: |
  defp aliases do
    [
      "assets.sw.build": ["esbuild sw"],
      "assets.sw.deploy": [
        "esbuild sw --minify"
      ]
    ]
  end

code8: |
  <script>
    if ("serviceWorker" in navigator) {
      window.addEventListener("load", () => {
        navigator.serviceWorker
          .register("/sw.js", { scope: '/' })
          .then((registration) => {
            console.log(
              "Service Worker registered with scope:",
              registration.scope,
            );
          })
          .catch((error) => {
            console.error("Service Worker registration failed:", error);
          });
      });
    }
  </script>


code10: |
  defmodule Mishka.Plugs.CSPPolicy do
    @moduledoc false
    import Plug.Conn

    def init(options), do: options

    def call(conn, opts) do
      conn
      |> put_csp(opts)
    end

    def put_csp(conn, _opts) do
      [style_nonce, script_nonce] =
        for _i <- 1..2, do: 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

      conn
      |> put_session(:style_csp_nonce, style_nonce)
      |> put_session(:script_csp_nonce, script_nonce)
      |> assign(:style_csp_nonce, style_nonce)
      |> assign(:script_csp_nonce, script_nonce)
      |> put_header(script_nonce, style_nonce)
    end

    if Application.compile_env(:mishka, :dev_routes) do
      defp put_header(assign, script_nonce, style_nonce) do
        assign
        |> put_resp_header(
          "content-security-policy",
          "default-src 'self'; script-src 'nonce-#{script_nonce}'; " <>
            "style-src 'self' 'nonce-#{style_nonce}'; style-src-elem 'self' 'nonce-#{style_nonce}'; " <>
            "img-src 'self' data: blob:; object-src 'none'; font-src data:; connect-src 'self'; frame-src 'self'; " <>
            "worker-src 'self'"
        )
      end
    else
      defp put_header(assign, script_nonce, style_nonce) do
        assign
        |> put_resp_header(
          "content-security-policy",
          "default-src 'self'; script-src 'nonce-#{script_nonce}'; " <>
            "style-src 'self' 'nonce-#{style_nonce}'; style-src-elem 'self' 'nonce-#{style_nonce}'; " <>
            "img-src 'self' data: blob:; object-src 'none'; font-src data:; connect-src 'self'; frame-src 'none'; " <>
            "worker-src 'self'; base-uri https://mishka.tools;"
        )
      end
    end
  end


code11: |
  <script nonce={assigns[:script_csp_nonce]}>
---

<br />

<p align="center">
<img src="/images/blog/initial-implementation-of-service-worker-with-workbox-in-the-phoenix-framework.jpg" alt="Initial Implementation of Service Worker with Workbox in the Phoenix Framework">
</p>

<br />

<.cp>A <.custom_inline_code>service worker</.custom_inline_code> essentially provides a set of categorized tools offered by the browser to reduce
the costs for both clients and servers in web applications. Additionally, it can enhance user
experience by bringing certain capabilities closer to native apps, such as sending notifications
and temporary data storage (caching), among other features.</.cp>

<.cp>In this brief post, we'll focus specifically on storing images in the user's browser,
while also touching on caching strategies provided by Google's <.custom_inline_code>Workbox</.custom_inline_code> library.</.cp>

<br />

<.heading2>The first question is: Why should we even do this?</.heading2>

<.cp>Most modern browsers that users have been using since 2019 offer highly stable and
reliable features, one of which is caching with your chosen strategy. For example, why should a user
download the same repetitive assets of your website every time—assets that might not change
for months or even years? Instead, with just a simple function, you can load them locally
when the user revisits your application. This approach not only enhances load speed but
also significantly improves the user experience.</.cp>

<br />

<.cp>Of course, it's worth mentioning that the capabilities of service workers go far beyond just this.
They cover a wide range of modern web application needs. For example,
just open Google Chrome, right-click on the page, and select <.custom_inline_code>Inspect</.custom_inline_code>. Among the tabs
you see, click on <.custom_inline_code>Application</.custom_inline_code>, and then select <.custom_inline_code>Service Workers</.custom_inline_code> from the left-hand side.</.cp>

<br />

<.cp>So far, we've summarized why you might need a service worker. We won't delve further into the
details in this post. If you'd like to dive deeper, I recommend checking out two great articles
from Mozilla: <.clink href="https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API" target="_blank">Service Worker API</.clink> and
<.clink href="https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API" target="_blank">Web Workers API</.clink>. Additionally, the Chrome Developers
YouTube channel is an excellent resource, and I’ll be linking one or two of their best playlists below.</.cp>

<br />

<.heading2>Cache First Strategy for Loading Images from the User's Local Storage:</.heading2>

<.cp>As you may have noticed, I mentioned the strategy name in the title of this section.
This is because the amazing Workbox library offers several strategies for managing internet
connectivity and caching. Each of these strategies can be easily configured and
customized to fit your needs.</.cp>

<br />

<.heading2>But what is the Cache First strategy?</.heading2>

<.cp>This strategy helps ensure that, for example, if an image is already stored in the
user's browser, it doesn’t need to be downloaded from the server again. Instead, it
will only be downloaded for the first time if it doesn’t already exist, and then it’s
stored in the browser’s Cache Storage. The great part is that Workbox handles all of
this for you in a very straightforward way, which we’ll explore further.</.cp>

<br />

<.cp>If you'd like to learn more about the strategies, click on
<.clink href="https://developer.chrome.com/docs/workbox/modules/workbox-strategies" target="_blank">workbox-strategies</.clink> or
check out this YouTube playlist: <.clink href="https://www.youtube.com/playlist?list=PLNYkxOF6rcIC3BwCw--jvZNN7obH4QUlH" target="_blank">Unpacking the Workbox</.clink>.</.cp>

<br />

<.heading2>How to Enable a Service Worker?</.heading2>

<.cp>Before we start, I need to explain a simple concept about service workers.
Imagine you have a series of EventListeners in your code, each representing a stage
of communication with the client (i.e., the browser). In practice, most of this is managed
by Workbox, but not understanding these stages might make everything seem a bit 'magical',
which could make this tutorial harder to follow.</.cp>

<LiveViewBackWeb.List.list variant="transparent" size="medium" style="list-decimal" class="px-5">
<:item padding="small">
<.custom_inline_code>install</.custom_inline_code>: This listener is activated when the service worker is installed for the first time. It is typically used for caching the initial resources of the application.
</:item>
<:item padding="small">
  <.custom_inline_code>activate</.custom_inline_code>: This listener runs when a new service worker has been installed and is ready to take control. It is usually used to clean up old caches.
</:item>
<:item padding="small">
  <.custom_inline_code>fetch</.custom_inline_code>: This listener is triggered every time the browser makes a network request. It is commonly used to handle cached responses and network requests.
</:item>
<:item padding="small">
  <.custom_inline_code>message</.custom_inline_code>: This listener is activated when a message is sent from the web page to the service worker. It can be used for handling specific actions like triggering a <.custom_inline_code>skip waiting</.custom_inline_code> command.
</:item>
<:item padding="small">
  <.custom_inline_code>push</.custom_inline_code>: This listener activates when the service worker receives a push notification from the server. It is used for displaying notifications.
</:item>
<:item padding="small">
  <.custom_inline_code>sync</.custom_inline_code>: This listener is used for background synchronization and activates when an internet connection is established. It can be useful for sending data after a connection loss, for instance.
</:item>
</LiveViewBackWeb.List.list>


<.cp>These listeners collectively enable service workers to effectively manage requests,
caching, notifications, and data synchronization. However, thanks to Workbox, you don't need to
write code for each of these aspects manually—it simplifies everything for you.</.cp>

<.cp>I've tried to keep the descriptions concise and clear while retaining the original points.</.cp>
<br />

<.cp>Let's write some code! First, create a file named <.custom_inline_code>sw.ts</.custom_inline_code> in the js folder of your project.
Yes, we are going to use TypeScript. The path for the file will be <.custom_inline_code>assets/js/sw.ts</.custom_inline_code>.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code1}/>
<br />

<.cp>In the code above, we imported some items and, to get started, called the following two functions
during the activation and installation phases:</.cp>

<br />

<.cp><.custom_inline_code>clientsClaim();</.custom_inline_code></.cp>

<.cp><.custom_inline_code>self.skipWaiting();</.custom_inline_code></.cp>

<br />

<.cp>With just these two lines, you've completed all the steps required to activate the
service worker in the browser—it's that simple. Also, one line of declare solves the
TypeScript issue with calling self.</.cp>

<.cp>In the next step, we need to implement the Cache First strategy, specifically targeting only images.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code2}/>
<br />

<.cp>In a simple way, we've registered a route that initially targets only images, ensuring that
it starts with <.custom_inline_code>/images/</.custom_inline_code> because that's where the images we want to cache are located.
We also added an extra control line (which is a good practice) to prevent caching <.custom_inline_code>/sw.js</.custom_inline_code>, as
this file needs to always be executed and serves as the cache controller itself.</.cp>

<br />

<.cp>Finally, if all these conditions are met, we move on to the next step, which is applying the
<.custom_inline_code>CacheFirst strategy</.custom_inline_code>. In the line cacheName: <.custom_inline_code>images-cache</.custom_inline_code>, we give this section a name to keep it
well-organized in the browser storage. After that, we call the <.custom_inline_code>ExpirationPlugin</.custom_inline_code> plugin to manage the
cache's expiration date.</.cp>

<br />

<.cp>This is a feature of Workbox that manages both the expiration time and the maximum number
of cached images in the user's browser automatically. Imagine you've cached 50 images,
and you visit a page with a new image—let's say image 51. The library will remove the
oldest image to make room for the new one. Isn't that amazing?</.cp>

<br />

<.cp>Our work with the sw.ts file is now complete, but it's not yet implemented in Phoenix.
Before moving on to the configuration, I need to mention a few things. The goal of this tutorial
is to avoid adding <.custom_inline_code>node_modules</.custom_inline_code>. In other words, we won't be introducing dependencies into our release
version—we'll keep everything in the production phase. So, if you want to take a few extra
steps, you'll need to install <.custom_inline_code>NodeJS</.custom_inline_code> and npm during the <.custom_inline_code>Docker</.custom_inline_code> build created by Phoenix,
and then download and use <.custom_inline_code>package.json</.custom_inline_code> during the build process.</.cp>

<br />

<.cp>For instance, when might you need this extra setup? One scenario where I think you might
need it is when working with the <.custom_inline_code>Precaching</.custom_inline_code> strategy. This is because you need to adjust some settings
in esbuild and also create a manifest file. However, for the strategy we're currently using,
this isn't necessary.</.cp>

<br />

<.cp>Step one is to navigate to the project's Phoenix assets directory. You can either install these
items as development dependencies or have the script installed globally on your system. The path
to look for is <.custom_inline_code>assets/package.json</.custom_inline_code>.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code3}/>
<br />

<.cp>All of the above should only be in the dev environment, as there's no need for them in production.
The service worker must remain very low-level, avoiding the use of new <.custom_inline_code>JavaScript</.custom_inline_code> features, and should
be completely isolated and independent.</.cp>

<br />

<.cp>After creating the package.json file, you can install it using bun i, npm i, or similar commands.
Personally, I recommend using bun.sh. At this point, you've set up nearly all the dependencies
you need for the production environment. Now, it's time to transpile the sw.ts file into JavaScript
at the appropriate location: <.custom_inline_code>priv/static/sw.js</.custom_inline_code>.</.cp>

<br />

<.cp>The first step is to find the def static_paths function in your project and add <.custom_inline_code>sw.js</.custom_inline_code> to its list.
For example:</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code4}/>
<br />

<.cp>This allows you to, for example, serve this file directly from your domain,
like <.custom_inline_code>https://mishka.tools/sw.js</.custom_inline_code>. Try not to change the path, as doing so can lead
to a multitude of errors related to <.custom_inline_code>CSP</.custom_inline_code> settings and the service worker itself. While
you may have access to new features, the core nature of service workers remains based on
older structures, including strict mode.</.cp>

<br />

<.cp>At this point, you've defined the path, but now you need to set up a build process. First,
open the <.custom_inline_code>config.exs</.custom_inline_code> file and find the settings related to esbuild. For example, in the latest
version of Phoenix, it looks something like this:</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code5}/>
<br />

<.cp>The difference compared to your web application setup is that I've added a new list with the key sw,
which compiles the sw.ts file, targeting <.custom_inline_code>ECMAScript 2017</.custom_inline_code>, and outputs it to the desired location
along with other arguments.</.cp>

<br />

<.cp>Our dev environment still doesn't support real-time changes yet. So far, we've just defined
the development setup. Since we want to avoid running the build process in production,
there's no need to go into <.custom_inline_code>mix.exs</.custom_inline_code> and add a lot of options. However, we will add a few
aliases for the development environment to make things easier, which we'll cover next.
Now, open the <.custom_inline_code>dev.exs</.custom_inline_code> file in the project's config folder.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code6}/>
<br />

<.cp>If you want to see changes in real time, add another key to this list named <.custom_inline_code>esbuild_sw</.custom_inline_code>.
Just adding this key is enough. Essentially, with the <.custom_inline_code>--watch</.custom_inline_code> mode, any change you make in sw.ts
will automatically be transformed into <.custom_inline_code>sw.js</.custom_inline_code>, along with a source map. We don't need a source
map in production, so before each Git commit, run the <.custom_inline_code>mix</.custom_inline_code> command that we are about to create.
I know it’s a bit manual, but you can automate all of this if you prefer. Since we didn'
t want to modify the <.custom_inline_code>Dockerfile</.custom_inline_code>, we adopted this approach.</.cp>

<br />

<.cp>Open the <.custom_inline_code>mix.exs</.custom_inline_code> file and follow these instructions. Note that we're only showing the
newly added elements, so be careful not to accidentally remove your existing aliases.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code7}/>
<br />

<.cp>It’s that simple. Before committing to Git, you only need to run one or both of these commands</.cp>

<.cp><.custom_inline_code>mix assets.sw.build</.custom_inline_code></.cp>

<.cp><.custom_inline_code>mix assets.sw.deploy</.custom_inline_code></.cp>


<br />

<.cp>Now, why do we need to run mix <.custom_inline_code>assets.sw.deploy</.custom_inline_code> if we're
already building on each change in developer mode? This command helps you produce a production-ready version,
removing the source map at the end of the file, which isn't needed in production.</.cp>

<br />

<.cp>And the final step is simply to add sw.js to the <.custom_inline_code>lib/yourapp_web/components/layouts/root.html.heex</.custom_inline_code>
file so that it gets called when the project loads.</.cp>

<br />

<.cp>Why not add it to app.js? You could do that, but due to the <.custom_inline_code>CSP</.custom_inline_code> (Content Security Policy)
settings applied to our website, it made things a bit challenging, so we decided to place the code here.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code8}/>
<br />

<.cp>That's it! Now open your project, go to the <.custom_inline_code>Network</.custom_inline_code> tab, and you'll see that all images are downloaded
the first time. But after refreshing the page, you'll notice that next to each image,
it says <.custom_inline_code>service worker</.custom_inline_code>, meaning these images are no longer being downloaded.</.cp>

<br />

<.heading3 color="color1">Enabling CSP</.heading3>

<.cp>You might also want to enable <.custom_inline_code>CSP</.custom_inline_code> (Content Security Policy)
on your website. Here are all the headers that we implemented based on our needs.
You can modify them as necessary. Please note that if you apply these settings, you'll need to adjust the script tag accordingly,
for example:</.cp>

<.custom_code_wrapper code={@attrs.code11}/>
<br />

<.cp>Make sure to change the module names and domains in this file to suit your own setup.
You should also call this file in your router—simply <.custom_inline_code>plug Mishka.Plugs.CSPPolicy</.custom_inline_code>.
This is how we've implemented CSP in the Phoenix framework.</.cp>

<br />

<.cp>It's worth mentioning that these settings have been thoroughly implemented and tested for all
<.clink navigate="/chelekom">Phoenix and LiveView components</.clink> created by Mishka, and you can easily use them in
both Phoenix and LiveView.</.cp>

<.custom_code_wrapper type="elixir" code={@attrs.code10}/>


<br />

---

<.cp position="left" color="success" class="my-8" border="medium">
If you enjoyed this article, please feel free to share it on social media.
</.cp>
